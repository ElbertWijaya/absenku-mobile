import { Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Location } from './location.entity';
import { Shift } from './shift.entity';

@Entity('qr_tokens')
export class QrToken {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id: string;

  @ManyToOne(() => Location, { nullable: true })
  @JoinColumn({ name: 'location_id' })
  location?: Location | null;

  @ManyToOne(() => Shift, { nullable: true })
  @JoinColumn({ name: 'shift_id' })
  shift?: Shift | null;

  @Column({ type: 'char', length: 36, unique: true })
  jti: string;

  @Column({ type: 'datetime' })
  issued_at: Date;

  @Column({ type: 'datetime' })
  expires_at: Date;

  @Column({ type: 'json', nullable: true })
  meta?: Record<string, any> | null;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}