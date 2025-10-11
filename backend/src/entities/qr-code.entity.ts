import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, Unique } from 'typeorm';

@Entity('qr_codes')
@Unique(['work_date'])
export class QrCode {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id: string;

  // yyyy-MM-dd, unique per day
  @Column({ type: 'date' })
  work_date: string;

  @Column({ type: 'varchar', length: 1024 })
  token: string;

  @Column({ type: 'datetime' })
  valid_until: Date;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}
