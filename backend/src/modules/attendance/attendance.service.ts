import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceLog)
    private readonly logsRepo: Repository<AttendanceLog>,
  ) {}

  async checkIn(userId: string, body: any) {
    const { qr_token } = body ?? {};
    if (!qr_token) throw new BadRequestException('qr_token is required');
    // For dev: pretend token contains loc/sh like jwt from QrService
    const now = new Date();
    const work_date = now.toISOString().slice(0, 10);
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
    open.work_minutes = 480; // fake 8h for dev
    await this.logsRepo.save(open);
    return open;
  }

  async my(userId: string, _q: { start?: string; end?: string }) {
    return this.logsRepo.find({ where: { user_id: userId }, order: { id: 'DESC' } });
  }
}
