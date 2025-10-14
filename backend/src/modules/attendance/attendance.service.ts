import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, IsNull, Repository } from 'typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';
import { User } from '../../entities/user.entity';
import { Role } from '../../entities/role.entity';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceLog)
    private readonly logsRepo: Repository<AttendanceLog>,
    @InjectRepository(User)
    private readonly usersRepo: Repository<User>,
    @InjectRepository(Role)
    private readonly rolesRepo: Repository<Role>,
    private readonly jwt: JwtService,
  ) {}

  async checkIn(userId: string, body: any) {
    const { qr_token } = body ?? {};
    if (!qr_token) throw new BadRequestException('qr_token is required');
    const now = new Date();
    // Validate qr_token
    try {
      const payload: any = this.jwt.verify(qr_token);
      if (payload?.typ !== 'qr') throw new UnauthorizedException('Invalid token');
      // ensure token's work_date matches today
      if (payload?.wd) {
        const todayStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
        if (payload.wd !== todayStr) throw new UnauthorizedException('QR expired for today');
      }
    } catch (e) {
      if (e instanceof UnauthorizedException) throw e;
      throw new UnauthorizedException('QR invalid or expired');
    }
    const work_date = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

    // Prevent duplicate open check-in for same user & date
    const existingOpen = await this.logsRepo.findOne({ where: { user_id: userId, work_date, check_out_at: IsNull() }, order: { id: 'DESC' } });
    if (existingOpen) {
      return {
        message: 'Already checked in',
        status: existingOpen.status,
        work_date: existingOpen.work_date,
        shift_id: existingOpen.shift_id,
        location_id: existingOpen.location_id,
      };
    }
    const log = this.logsRepo.create({
      user_id: userId,
      employee_id: null,
      work_date,
  shift_id: 1,
  location_id: 1,
      check_in_at: now as any,
      status: 'on_time',
      late_minutes: 0,
    });
    await this.logsRepo.save(log);
    return { status: log.status, work_date: log.work_date, shift_id: log.shift_id, location_id: log.location_id, message: 'Checked in' };
  }

  async checkOut(userId: string) {
    const open = await this.logsRepo.findOne({ where: { user_id: userId, check_out_at: IsNull() }, order: { id: 'DESC' } });
    if (!open) return { message: 'No open attendance' };
    open.check_out_at = new Date() as any;
    // Calculate minutes between check-in and check-out
    try {
      const ms = (open.check_out_at as any as Date).getTime() - (open.check_in_at as any as Date).getTime();
      open.work_minutes = Math.max(0, Math.round(ms / 60000));
    } catch {
      open.work_minutes = null;
    }
    await this.logsRepo.save(open);
    return open;
  }

  async my(userId: string, q: { start?: string; end?: string }) {
    const where: any = { user_id: userId };
    if (q?.start && q?.end) {
      where.work_date = Between(q.start, q.end);
    } else if (q?.start) {
      where.work_date = Between(q.start, '9999-12-31');
    } else if (q?.end) {
      where.work_date = Between('0001-01-01', q.end);
    }
    return this.logsRepo.find({ where, order: { id: 'DESC' } });
  }

  async reportByDay(date: string) {
    if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException('date is required (yyyy-MM-dd)');
    }
    const qb = this.logsRepo.createQueryBuilder('log')
      .leftJoin(User, 'u', 'u.id = log.user_id')
      .where('log.work_date = :date', { date })
      .orderBy('log.check_in_at', 'ASC')
      .select([
        'log.id as id',
        'log.user_id as user_id',
        'u.email as user_email',
        'log.work_date as work_date',
        'log.shift_id as shift_id',
        'log.location_id as location_id',
        'log.check_in_at as check_in_at',
        'log.check_out_at as check_out_at',
        'log.late_minutes as late_minutes',
        'log.work_minutes as work_minutes',
        'log.status as status',
      ]);
    return qb.getRawMany();
  }

  async monthSummary(year: number, month: number) {
    if (!year || !month || month < 1 || month > 12) {
      throw new BadRequestException('year and month are required');
    }
    const pad2 = (n: number) => String(n).padStart(2, '0');
    const start = `${year}-${pad2(month)}-01`;
    // compute end-of-month by going to the first day of next month, minus one day
    const nextMonth = month === 12 ? 1 : month + 1;
    const nextYear = month === 12 ? year + 1 : year;
    const endDate = new Date(Date.UTC(nextYear, nextMonth - 1, 1));
    endDate.setUTCDate(endDate.getUTCDate() - 1);
    const end = `${endDate.getUTCFullYear()}-${pad2(endDate.getUTCMonth() + 1)}-${pad2(endDate.getUTCDate())}`;
  // Today string (local)
  const today = new Date();
  const todayStr = `${today.getFullYear()}-${pad2(today.getMonth() + 1)}-${pad2(today.getDate())}`;

    // Total employees with role EMPLOYEE
    const employees = await this.usersRepo
      .createQueryBuilder('u')
      .leftJoin('u.roles', 'r')
      .where('r.name = :rn', { rn: 'EMPLOYEE' })
      .getMany();
    const employeeTotal = employees.length;
    const employeeIds = employees.map((u) => u.id);

    // Aggregate based on the latest log per user per date to avoid mixed duplicates
    // If there are no EMPLOYEEs, skip heavy query and just return empty rows
    const rows = employeeTotal === 0
      ? []
      : await this.logsRepo.createQueryBuilder('log')
      .innerJoin(
        (qb) =>
          qb
            .from(AttendanceLog, 'l2')
            .select('l2.user_id', 'user_id')
            .addSelect('l2.work_date', 'work_date')
            .addSelect('MAX(l2.id)', 'max_id')
            .where('l2.work_date BETWEEN :start AND :end', { start, end })
            .andWhere('l2.user_id IN (:...empIds)', { empIds: employeeIds })
            .groupBy('l2.user_id')
            .addGroupBy('l2.work_date'),
        'last',
        'last.max_id = log.id',
      )
      .where('log.work_date BETWEEN :start AND :end', { start, end })
      .andWhere('log.user_id IN (:...empIds)', { empIds: employeeIds })
      .select('log.work_date', 'work_date')
      .addSelect('COUNT(DISTINCT last.user_id)', 'present_count')
      .addSelect("SUM(CASE WHEN log.check_out_at IS NOT NULL THEN 1 ELSE 0 END)", 'with_out')
      .addSelect("SUM(CASE WHEN log.check_out_at IS NULL THEN 1 ELSE 0 END)", 'open_count')
      .addSelect("SUM(CASE WHEN log.status = 'late' THEN 1 ELSE 0 END)", 'late_count')
      .addSelect("SUM(CASE WHEN log.status = 'on_time' THEN 1 ELSE 0 END)", 'on_time_count')
      .groupBy('log.work_date')
      .orderBy('log.work_date', 'ASC')
      .getRawMany();

    // Defensive: also compute distinct present per date (EMPLOYEE only)
    const presentDistinctRows = employeeTotal === 0
      ? []
      : await this.logsRepo.createQueryBuilder('log')
        .select('log.work_date', 'work_date')
        .addSelect('COUNT(DISTINCT log.user_id)', 'present_distinct')
        .where('log.work_date BETWEEN :start AND :end', { start, end })
        .andWhere('log.user_id IN (:...empIds)', { empIds: employeeIds })
        .groupBy('log.work_date')
        .getRawMany();
    const normDate = (v: any): string => {
      if (!v) return '';
      if (typeof v === 'string') {
        return v.length >= 10 ? v.substring(0, 10) : v;
      }
      if (v instanceof Date) {
        // Use UTC to avoid timezone shifts; DB DATE has no tz
        const y = v.getUTCFullYear();
        const m = String(v.getUTCMonth() + 1).padStart(2, '0');
        const d = String(v.getUTCDate()).padStart(2, '0');
        return `${y}-${m}-${d}`;
      }
      return String(v);
    };
    const presentDistinctMap = new Map<string, number>();
    for (const r of presentDistinctRows) {
      const k = normDate(r.work_date);
      presentDistinctMap.set(k, Number(r.present_distinct ?? 0));
    }

    // Map raw rows by date
    const byDate = new Map<string, any>();
    for (const r of rows) {
      const dd = normDate(r.work_date);
      const merged: any = { ...r };
      const pc = Number(merged.present_count ?? 0);
      const pd = presentDistinctMap.get(dd) ?? 0;
      if (pc === 0 && pd > 0) merged.present_count = pd;
      byDate.set(dd, merged);
    }
    // Include days present only in distinct set (no last-join rows)
    for (const [dd, pd] of presentDistinctMap.entries()) {
      if (!byDate.has(dd)) {
        byDate.set(dd, {
          work_date: dd,
          present_count: pd,
          with_out: 0,
          open_count: 0,
          late_count: 0,
          on_time_count: 0,
        });
      }
    }

    // Build full list of days in month (including those with zero logs)
    const out: any[] = [];
    const daysInMonth = new Date(Date.UTC(nextYear, nextMonth - 1, 0)).getUTCDate();
    for (let d = 1; d <= daysInMonth; d++) {
      const dd = `${year}-${pad2(month)}-${pad2(d)}`;
      const r = byDate.get(dd) ?? {
        work_date: dd,
        present_count: 0,
        with_out: 0,
        open_count: 0,
        late_count: 0,
        on_time_count: 0,
      };
      const presentJoin = Number(r.present_count ?? 0);
      const presentDistinct = presentDistinctMap.get(dd) ?? 0;
      const present = presentJoin > 0 ? presentJoin : presentDistinct;
      const late = Number(r.late_count ?? 0);
      const ontime = Number(r.on_time_count ?? 0);
      const allAbsent = employeeTotal > 0 && present === 0;
      const anyLate = late > 0;
      const allOnTimeStrict = employeeTotal > 0 && ontime === employeeTotal && late === 0;
      const isFuture = dd > todayStr;
      out.push({
        work_date: dd,
        present_count: present,
        with_out: Number(r.with_out ?? 0),
        open_count: Number(r.open_count ?? 0),
        late_count: late,
        on_time_count: ontime,
        employee_total: employeeTotal,
        all_absent: allAbsent,
        any_late: anyLate,
        all_on_time_strict: allOnTimeStrict,
        is_future: isFuture,
        // debug fields to help diagnose aggregation on client
        _present_join: presentJoin,
        _present_distinct: presentDistinct,
        _debug_fill: presentJoin > 0 ? 'join' : (presentDistinct > 0 ? 'distinct' : 'zero'),
      });
    }

    return out;
  }

  async rollcall(date: string) {
    if (!date || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new BadRequestException('date is required (yyyy-MM-dd)');
    }
    // Determine if the requested date is in the future (relative to today local time)
    const today = new Date();
    const pad2 = (n: number) => String(n).padStart(2, '0');
    const todayStr = `${today.getFullYear()}-${pad2(today.getMonth() + 1)}-${pad2(today.getDate())}`;
    const isFuture = date > todayStr;
    // Get all users with role EMPLOYEE
    const employees = await this.usersRepo
      .createQueryBuilder('u')
      .leftJoinAndSelect('u.roles', 'r')
      .leftJoinAndSelect('u.employee', 'e')
      .where('r.name = :rn', { rn: 'EMPLOYEE' })
      .getMany();

    if (employees.length === 0) return [];

    // Fetch attendance per user for that date
    const userIds = employees.map((u) => u.id);
    // Pick latest log per user for the day to represent attendance
    const logs = await this.logsRepo
      .createQueryBuilder('log')
      .innerJoin(
        (qb) =>
          qb
            .from(AttendanceLog, 'l2')
            .select('l2.user_id', 'user_id')
            .addSelect('MAX(l2.id)', 'max_id')
            .where('l2.user_id IN (:...ids)', { ids: userIds })
            .andWhere('l2.work_date = :date', { date })
            .groupBy('l2.user_id'),
        'last',
        'last.max_id = log.id',
      )
      .getMany();
    const logByUser = new Map<string, AttendanceLog | undefined>();
    for (const l of logs) logByUser.set(l.user_id, l);

    // Compose rollcall items
    const items = employees.map((u) => {
      const log = logByUser.get(u.id);
      let status: 'ABSEN' | 'HADIR' | 'TELAT' | '-' = 'ABSEN';
      if (isFuture) {
        status = '-';
      } else if (log) {
        if (log.status === 'late' || (log.late_minutes ?? 0) > 0) status = 'TELAT';
        else status = 'HADIR';
      }
      return {
        user_id: u.id,
        name: u.employee?.full_name ?? u.username ?? u.email,
        email: u.email,
        status,
        check_in_at: log?.check_in_at ?? null,
        check_out_at: log?.check_out_at ?? null,
        late_minutes: log?.late_minutes ?? 0,
        work_minutes: log?.work_minutes ?? null,
        is_future: isFuture,
      };
    });
    // Sort by name asc
    items.sort((a, b) => (a.name || '').localeCompare(b.name || ''));
    return items;
  }
}
