import { Injectable, BadRequestException } from '@nestjs/common';

type AttendanceLog = {
  id: number;
  employee_id: number;
  work_date: string; // yyyy-MM-dd
  shift_id: number;
  location_id: number;
  check_in_at: string; // ISO
  check_out_at?: string | null;
  late_minutes?: number | null;
  work_minutes?: number | null;
  status?: 'on_time' | 'late' | 'absent_partial' | null;
};

@Injectable()
export class AttendanceService {
  private logs: AttendanceLog[] = [];
  private seq = 1;

  checkIn(body: any) {
    const { qr_token } = body ?? {};
    if (!qr_token) throw new BadRequestException('qr_token is required');
    // For dev: pretend token contains loc/sh like jwt from QrService
    const now = new Date();
    const work_date = now.toISOString().slice(0, 10);
    const log: AttendanceLog = {
      id: this.seq++,
      employee_id: 1,
      work_date,
      shift_id: 1,
      location_id: 1,
      check_in_at: now.toISOString(),
      status: 'on_time',
      late_minutes: 0,
    };
    this.logs.push(log);
    return { status: log.status, work_date: log.work_date, shift_id: log.shift_id, location_id: log.location_id, message: 'Checked in' };
  }

  checkOut(_body: any) {
    const open = [...this.logs].reverse().find((l) => !l.check_out_at);
    if (!open) return { message: 'No open attendance' };
    open.check_out_at = new Date().toISOString();
    open.work_minutes = 480; // fake 8h for dev
    return open;
  }

  my(_q: { start?: string; end?: string }) {
    return this.logs;
  }
}
