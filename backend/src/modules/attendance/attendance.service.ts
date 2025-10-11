import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, IsNull, Repository } from 'typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';
import { User } from '../../entities/user.entity';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceLog)
    private readonly logsRepo: Repository<AttendanceLog>,
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
}
