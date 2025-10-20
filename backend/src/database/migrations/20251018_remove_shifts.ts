import { MigrationInterface, QueryRunner } from 'typeorm';

export class RemoveShifts20251018123000 implements MigrationInterface {
  name = 'RemoveShifts20251018123000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // attendance_logs: drop shift_id and related constraints/indexes if any
    await queryRunner.query(`ALTER TABLE attendance_logs DROP COLUMN shift_id`);
    // employees: drop default_shift_id if present
    try {
      await queryRunner.query(`ALTER TABLE employees DROP COLUMN default_shift_id`);
    } catch {}
    // schedules table may reference shift_id; drop constraints/columns if exist
    try {
      await queryRunner.query(`ALTER TABLE schedules DROP FOREIGN KEY fk_sched_shift`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE schedules DROP COLUMN shift_id`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE schedules DROP INDEX uq_schedule`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE schedules ADD UNIQUE KEY uq_schedule_emp_date (employee_id, work_date)`);
    } catch {}
    // qr_codes or related: if there was a shift_id in other schema versions, ensure removed
    try {
      await queryRunner.query(`ALTER TABLE qr_codes DROP COLUMN shift_id`);
    } catch {}
    // attendance unique: if there was a unique with shift_id, rework
    try {
      await queryRunner.query(`ALTER TABLE attendance_logs DROP INDEX uq_att_unique`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE attendance_logs ADD UNIQUE KEY uq_att_unique (employee_id, work_date)`);
    } catch {}
    // finally, drop shifts table if exists
    try {
      await queryRunner.query(`DROP TABLE IF EXISTS shifts`);
    } catch {}
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Not fully reversible without full shift schema; recreate minimal columns to allow down migration
    await queryRunner.query(`ALTER TABLE attendance_logs ADD COLUMN shift_id INT UNSIGNED NULL`);
    try {
      await queryRunner.query(`ALTER TABLE employees ADD COLUMN default_shift_id INT UNSIGNED NULL`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE schedules ADD COLUMN shift_id INT UNSIGNED NULL`);
    } catch {}
    try {
      await queryRunner.query(`ALTER TABLE attendance_logs DROP INDEX uq_att_unique`);
      await queryRunner.query(`ALTER TABLE attendance_logs ADD UNIQUE KEY uq_att_unique (employee_id, work_date, shift_id)`);
    } catch {}
  }
}
