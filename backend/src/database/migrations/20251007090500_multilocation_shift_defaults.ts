import { MigrationInterface, QueryRunner } from 'typeorm';

export class MultilocationShiftDefaults20251007090500 implements MigrationInterface {
  name = 'MultilocationShiftDefaults20251007090500';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE employees
        ADD COLUMN default_location_id INT UNSIGNED NULL AFTER is_active,
        ADD COLUMN default_shift_id INT UNSIGNED NULL AFTER default_location_id;
    `);

    await queryRunner.query(`
      ALTER TABLE employees
        ADD CONSTRAINT fk_emp_default_loc FOREIGN KEY (default_location_id) REFERENCES locations(id)
          ON UPDATE CASCADE ON DELETE SET NULL,
        ADD CONSTRAINT fk_emp_default_shift FOREIGN KEY (default_shift_id) REFERENCES shifts(id)
          ON UPDATE CASCADE ON DELETE SET NULL;
    `);

    await queryRunner.query(`
      ALTER TABLE attendance_logs
        ADD COLUMN location_id INT UNSIGNED NULL AFTER shift_id;
    `);

    await queryRunner.query(`
      ALTER TABLE attendance_logs
        ADD CONSTRAINT fk_att_loc FOREIGN KEY (location_id) REFERENCES locations(id)
          ON UPDATE CASCADE ON DELETE SET NULL;
    `);

    await queryRunner.query(`
      CREATE INDEX idx_att_emp_date_loc ON attendance_logs (employee_id, work_date, location_id);
    `);

    // Backfill location_id from schedules if exists
    await queryRunner.query(`
      UPDATE attendance_logs a
      JOIN schedules s ON a.schedule_id = s.id
      SET a.location_id = s.location_id
      WHERE a.location_id IS NULL;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS idx_att_emp_date_loc ON attendance_logs`);
    await queryRunner.query(`ALTER TABLE attendance_logs DROP FOREIGN KEY fk_att_loc`);
    await queryRunner.query(`ALTER TABLE attendance_logs DROP COLUMN location_id`);
    await queryRunner.query(`ALTER TABLE employees DROP FOREIGN KEY fk_emp_default_loc`);
    await queryRunner.query(`ALTER TABLE employees DROP FOREIGN KEY fk_emp_default_shift`);
    await queryRunner.query(`ALTER TABLE employees DROP COLUMN default_location_id`);
    await queryRunner.query(`ALTER TABLE employees DROP COLUMN default_shift_id`);
  }
}