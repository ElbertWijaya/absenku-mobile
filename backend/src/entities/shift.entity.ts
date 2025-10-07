import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('shifts')
export class Shift {
  @PrimaryGeneratedColumn({ type: 'int', unsigned: true })
  id: number;

  @Column({ type: 'varchar', length: 80 })
  name: string;

  @Column({ type: 'time' })
  start_time: string; // HH:MM:SS

  @Column({ type: 'time' })
  end_time: string; // HH:MM:SS

  @Column({ type: 'int', default: 10 })
  grace_minutes: number;

  @Column({ type: 'int', default: 60 })
  min_check_out_after_minutes: number;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}