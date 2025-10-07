import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('employees')
export class Employee {
  @PrimaryGeneratedColumn({ type: 'bigint', unsigned: true })
  id: string;

  @Column({ type: 'varchar', length: 150 })
  full_name: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  role_title: string | null;

  @Column({ type: 'enum', enum: ['M', 'F'], nullable: true })
  gender: 'M' | 'F' | null;

  @Column({ type: 'varchar', length: 30, nullable: true })
  phone: string | null;

  @Column({ type: 'text', nullable: true })
  address: string | null;

  @Column({ type: 'varchar', length: 150, nullable: true, unique: true })
  email: string | null;

  @Column({ type: 'date', nullable: true })
  birth_date: string | null;

  @Column({ type: 'varchar', length: 50, nullable: true })
  religion: string | null;

  @Column({ type: 'date', nullable: true })
  join_date: string | null;

  @Column({ type: 'tinyint', width: 1, default: 1 })
  is_active: boolean;

  @Column({ type: 'decimal', precision: 12, scale: 2, nullable: true })
  base_salary_rate: string | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  default_location_id: number | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  default_shift_id: number | null;
}