import { Column, CreateDateColumn, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('locations')
export class Location {
  @PrimaryGeneratedColumn({ type: 'int', unsigned: true })
  id: number;

  @Column({ type: 'varchar', length: 120 })
  name: string;

  @Column({ type: 'text', nullable: true })
  address?: string | null;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  lat?: number | null;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  lng?: number | null;

  @Column({ type: 'int', nullable: true })
  radius_m?: number | null;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}