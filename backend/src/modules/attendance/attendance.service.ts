import { BadRequestException, ConflictException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Shift } from '../../entities/shift.entity';
import { Location } from '../../entities/location.entity';
import { Employee } from '../../entities/employee.entity';

function ymdUtc(now: Date) {
  return now.toISOString().slice(0, 10); // YYYY-MM-DD
}

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceLog) private readonly attRepo: Repository<AttendanceLog>,
    @InjectRepository(Shift) private readonly shiftRepo: Repository<Shift>,
    @InjectRepository(Location) private readonly locRepo: Repository<Location>,
    @InjectRepository(Employee) private readonly empRepo: Repository<Employee>,
    private readonly jwt: JwtService,
    private readonly cfg: ConfigService,
  ) {}

  async checkIn(user: { id: string; employee?: { id: string } | null }, qr_token: string, lat?: number, lng?: number) {
    const secret = this.cfg.get<string>('JWT_ACCESS_SECRET');
    let decoded: any;
    try {
      decoded = await this.jwt.verifyAsync(qr_token, { secret });
    } catch {
      throw new BadRequestException('Invalid or expired QR token');
    }

    const { jti, location_id, shift_id, exp } = decoded || {};
    if (!jti || !exp) throw new BadRequestException('Malformed QR token');

    const now = new Date();
    const work_date = ymdUtc(now);

    // Prevent duplicate check-in for same employee/day/shift
    const exists = await this.attRepo.findOne({
      where: {
        employee: { id: user.employee?.id as any },
        work_date,
        ...(shift_id ? { shift: { id: shift_id } as any } : {}),
      },
      relations: ['employee', 'shift', 'location'],
    });
    if (exists) throw new ConflictException('Already checked in for this shift/day');

    const employee = await this.empRepo.findOneByOrFail({ id: user.employee?.id as any });
    const shift = shift_id ? await this.shiftRepo.findOneBy({ id: Number(shift_id) }) : undefined;
    const location = location_id ? await this.locRepo.findOneBy({ id: Number(location_id) }) : undefined;

    const rec = this.attRepo.create({
      employee,
      shift: shift || null,
      location: location || null,
      work_date,
      check_in_at: now,
      check_in_source: 'qr',
      used_nonce: jti,
      lat: lat ?? null,
      lng: lng ?? null,
      status: 'on_time',
      late_minutes: 0,
    });
    await this.attRepo.save(rec);

    return {
      status: rec.status,
      work_date: rec.work_date,
      shift_id: shift?.id ?? null,
      location_id: location?.id ?? null,
      message: 'Check-in recorded',
    };
  }

  async checkOut(user: { id: string; employee?: { id: string } | null }, lat?: number, lng?: number) {
    const now = new Date();
    const today = ymdUtc(now);

    const log = await this.attRepo.findOne({
      where: {
        employee: { id: user.employee?.id as any },
        work_date: today,
      },
      order: { check_in_at: 'DESC' },
      relations: ['employee', 'shift', 'location'],
    });
    if (!log) throw new BadRequestException('No check-in found for today');

    if (log.check_out_at) {
      throw new ConflictException('Already checked out');
    }

    log.check_out_at = now;
    if (lat) log.lat = lat;
    if (lng) log.lng = lng;

    // naive work minutes calc
    const diffMin = Math.max(0, Math.round((now.getTime() - log.check_in_at.getTime()) / 60000));
    log.work_minutes = diffMin;

    await this.attRepo.save(log);
    return log;
  }

  async myHistory(user: { id: string; employee?: { id: string } | null }, start?: string, end?: string) {
    const where: any = { employee: { id: user.employee?.id as any } };
    if (start) where.work_date = { ...(where.work_date || {}), ...MoreThanOrEqual(start) };
    if (end) where.work_date = { ...(where.work_date || {}), ...LessThanOrEqual(end) };

    return this.attRepo.find({
      where,
      order: { work_date: 'DESC', check_in_at: 'DESC' },
      relations: ['shift', 'location'],
    });
  }
}