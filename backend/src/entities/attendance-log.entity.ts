import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('attendance_logs')
export class AttendanceLog {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id: string;

  @Column({ type: 'bigint', unsigned: true })
  user_id: string;

  @Column({ type: 'bigint', unsigned: true, nullable: true })
  employee_id: string | null;

  @Column({ type: 'date' })
  work_date: string; // yyyy-MM-dd

  @Column({ type: 'int', unsigned: true })
  location_id: number;

  @Column({ type: 'datetime' })
  check_in_at: Date;

  @Column({ type: 'datetime', nullable: true })
  check_out_at: Date | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  late_minutes: number | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  work_minutes: number | null;

  @Column({ type: 'varchar', length: 32, nullable: true })
  status: 'on_time' | 'late' | 'absent_partial' | null;
}
