import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitSchema20251007090000 implements MigrationInterface {
  name = 'InitSchema20251007090000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`SET NAMES utf8mb4`);
    await queryRunner.query(`SET time_zone = '+00:00'`);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS roles (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS employees (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        full_name VARCHAR(150) NOT NULL,
        role_title VARCHAR(100) NULL,
        gender ENUM('M','F') NULL,
        phone VARCHAR(30) NULL,
        address TEXT NULL,
        email VARCHAR(150) NULL UNIQUE,
        birth_date DATE NULL,
        religion VARCHAR(50) NULL,
        join_date DATE NULL,
        is_active TINYINT(1) NOT NULL DEFAULT 1,
        base_salary_rate DECIMAL(12,2) NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_emp_name (full_name),
        INDEX idx_emp_active (is_active)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS users (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        employee_id BIGINT UNSIGNED NULL,
        email VARCHAR(150) NOT NULL UNIQUE,
        username VARCHAR(80) NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        last_login_at DATETIME NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_users_employee FOREIGN KEY (employee_id) REFERENCES employees(id)
          ON UPDATE CASCADE ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS user_roles (
        user_id BIGINT UNSIGNED NOT NULL,
        role_id INT UNSIGNED NOT NULL,
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, role_id),
        CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id)
          ON UPDATE CASCADE ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS locations (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(120) NOT NULL,
        address TEXT NULL,
        lat DECIMAL(10,7) NULL,
        lng DECIMAL(10,7) NULL,
        radius_m INT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS shifts (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(80) NOT NULL,
        start_time TIME NOT NULL,
        end_time TIME NOT NULL,
        grace_minutes INT NOT NULL DEFAULT 10,
        min_check_out_after_minutes INT NOT NULL DEFAULT 60,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS schedules (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        employee_id BIGINT UNSIGNED NOT NULL,
        shift_id INT UNSIGNED NOT NULL,
        location_id INT UNSIGNED NULL,
        work_date DATE NOT NULL,
        status ENUM('planned','completed','absent') NOT NULL DEFAULT 'planned',
        notes VARCHAR(255) NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY uq_schedule (employee_id, work_date, shift_id),
        CONSTRAINT fk_sched_emp FOREIGN KEY (employee_id) REFERENCES employees(id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT fk_sched_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
          ON UPDATE CASCADE ON DELETE RESTRICT,
        CONSTRAINT fk_sched_loc FOREIGN KEY (location_id) REFERENCES locations(id)
          ON UPDATE CASCADE ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS qr_tokens (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        location_id INT UNSIGNED NULL,
        shift_id INT UNSIGNED NULL,
        jti CHAR(36) NOT NULL,
        issued_at DATETIME NOT NULL,
        expires_at DATETIME NOT NULL,
        meta JSON NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_qr_active (expires_at),
        UNIQUE KEY uq_qr_jti (jti),
        CONSTRAINT fk_qr_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
          ON UPDATE CASCADE ON DELETE SET NULL,
        CONSTRAINT fk_qr_loc FOREIGN KEY (location_id) REFERENCES locations(id)
          ON UPDATE CASCADE ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS attendance_logs (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        employee_id BIGINT UNSIGNED NOT NULL,
        schedule_id BIGINT UNSIGNED NULL,
        work_date DATE NOT NULL,
        shift_id INT UNSIGNED NULL,
        check_in_at DATETIME NOT NULL,
        check_in_source ENUM('qr','manual') NOT NULL DEFAULT 'qr',
        check_out_at DATETIME NULL,
        work_minutes INT NULL,
        late_minutes INT NULL,
        status ENUM('on_time','late','absent_partial') NULL,
        used_nonce CHAR(36) NULL,
        lat DECIMAL(10,7) NULL,
        lng DECIMAL(10,7) NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY uq_att_unique (employee_id, work_date, shift_id),
        INDEX idx_att_emp_date (employee_id, work_date),
        CONSTRAINT fk_att_emp FOREIGN KEY (employee_id) REFERENCES employees(id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT fk_att_sched FOREIGN KEY (schedule_id) REFERENCES schedules(id)
          ON UPDATE CASCADE ON DELETE SET NULL,
        CONSTRAINT fk_att_shift FOREIGN KEY (shift_id) REFERENCES shifts(id)
          ON UPDATE CASCADE ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS payroll_runs (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        period_start DATE NOT NULL,
        period_end DATE NOT NULL,
        status ENUM('draft','finalized') NOT NULL DEFAULT 'draft',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS payroll_items (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        payroll_run_id BIGINT UNSIGNED NOT NULL,
        employee_id BIGINT UNSIGNED NOT NULL,
        base_pay DECIMAL(12,2) NOT NULL DEFAULT 0,
        late_deduction DECIMAL(12,2) NOT NULL DEFAULT 0,
        overtime_pay DECIMAL(12,2) NOT NULL DEFAULT 0,
        allowances DECIMAL(12,2) NOT NULL DEFAULT 0,
        total_pay DECIMAL(12,2) NOT NULL DEFAULT 0,
        meta JSON NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_pi_run FOREIGN KEY (payroll_run_id) REFERENCES payroll_runs(id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        CONSTRAINT fk_pi_emp FOREIGN KEY (employee_id) REFERENCES employees(id)
          ON UPDATE CASCADE ON DELETE CASCADE,
        INDEX idx_pi_emp_run (employee_id, payroll_run_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS leave_requests (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        employee_id BIGINT UNSIGNED NOT NULL,
        start_date DATE NOT NULL,
        end_date DATE NOT NULL,
        type VARCHAR(50) NOT NULL,
        status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
        reason TEXT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        CONSTRAINT fk_leave_emp FOREIGN KEY (employee_id) REFERENCES employees(id)
          ON UPDATE CASCADE ON DELETE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS holidays (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        date DATE NOT NULL UNIQUE,
        name VARCHAR(120) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS audit_logs (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        actor_user_id BIGINT UNSIGNED NULL,
        action VARCHAR(120) NOT NULL,
        resource VARCHAR(120) NULL,
        details JSON NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_audit_time (created_at),
        CONSTRAINT fk_audit_user FOREIGN KEY (actor_user_id) REFERENCES users(id)
          ON UPDATE CASCADE ON DELETE SET NULL
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    `);

    await queryRunner.query(`
      INSERT INTO roles (name) VALUES ('ADMIN'), ('EMPLOYEE')
      ON DUPLICATE KEY UPDATE name = name;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS audit_logs`);
    await queryRunner.query(`DROP TABLE IF EXISTS holidays`);
    await queryRunner.query(`DROP TABLE IF EXISTS leave_requests`);
    await queryRunner.query(`DROP TABLE IF EXISTS payroll_items`);
    await queryRunner.query(`DROP TABLE IF EXISTS payroll_runs`);
    await queryRunner.query(`DROP TABLE IF EXISTS attendance_logs`);
    await queryRunner.query(`DROP TABLE IF EXISTS qr_tokens`);
    await queryRunner.query(`DROP TABLE IF EXISTS schedules`);
    await queryRunner.query(`DROP TABLE IF EXISTS shifts`);
    await queryRunner.query(`DROP TABLE IF EXISTS locations`);
    await queryRunner.query(`DROP TABLE IF EXISTS user_roles`);
    await queryRunner.query(`ALTER TABLE users DROP FOREIGN KEY fk_users_employee`);
    await queryRunner.query(`DROP TABLE IF EXISTS users`);
    await queryRunner.query(`DROP TABLE IF EXISTS employees`);
    await queryRunner.query(`DROP TABLE IF EXISTS roles`);
  }
}