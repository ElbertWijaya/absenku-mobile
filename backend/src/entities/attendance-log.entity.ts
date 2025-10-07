import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, UpdateDateColumn } from 'typeorm';
import { Employee } from './employee.entity';
import { Shift } from './shift.entity';
import { Location } from './location.entity';

@Entity('attendance_logs')
export class AttendanceLog {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id: string;

  @ManyToOne(() => Employee, { nullable: false })
  @JoinColumn({ name: 'employee_id' })
  employee: Employee;

  @ManyToOne(() => Shift, { nullable: true })
  @JoinColumn({ name: 'shift_id' })
  shift?: Shift | null;

  @ManyToOne(() => Location, { nullable: true })
  @JoinColumn({ name: 'location_id' })
  location?: Location | null;

  @Column({ type: 'date' })
  work_date: string;

  @Column({ type: 'datetime' })
  check_in_at: Date;

  @Column({ type: 'enum', enum: ['qr', 'manual'], default: 'qr' })
  check_in_source: 'qr' | 'manual';

  @Column({ type: 'datetime', nullable: true })
  check_out_at?: Date | null;

  @Column({ type: 'int', nullable: true })
  work_minutes?: number | null;

  @Column({ type: 'int', nullable: true })
  late_minutes?: number | null;

  @Column({ type: 'enum', enum: ['on_time', 'late', 'absent_partial'], nullable: true })
  status?: 'on_time' | 'late' | 'absent_partial' | null;

  @Column({ type: 'char', length: 36, nullable: true })
  used_nonce?: string | null;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  lat?: number | null;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  lng?: number | null;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @UpdateDateColumn({ type: 'timestamp', nullable: true })
  updated_at: Date | null;
}