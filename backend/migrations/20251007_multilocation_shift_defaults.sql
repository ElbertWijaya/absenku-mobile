-- Tambahan untuk mendukung multi-lokasi sejak awal dan shift tetap

ALTER TABLE employees
  ADD COLUMN default_location_id INT UNSIGNED NULL AFTER is_active,
  ADD COLUMN default_shift_id INT UNSIGNED NULL AFTER default_location_id,
  ADD CONSTRAINT fk_emp_default_loc FOREIGN KEY (default_location_id) REFERENCES locations(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  ADD CONSTRAINT fk_emp_default_shift FOREIGN KEY (default_shift_id) REFERENCES shifts(id)
    ON UPDATE CASCADE ON DELETE SET NULL;

-- Simpan lokasi pada attendance_logs untuk jejak yang eksplisit
ALTER TABLE attendance_logs
  ADD COLUMN location_id INT UNSIGNED NULL AFTER shift_id,
  ADD CONSTRAINT fk_att_loc FOREIGN KEY (location_id) REFERENCES locations(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  ADD INDEX idx_att_emp_date_loc (employee_id, work_date, location_id);

-- Backfill location_id dari schedule jika ada
UPDATE attendance_logs a
JOIN schedules s ON a.schedule_id = s.id
SET a.location_id = s.location_id
WHERE a.location_id IS NULL;

-- Opsional: pastikan QR selalu punya shift & lokasi (sudah ada FK di schema.sql)
-- Tidak ada perubahan tambahan untuk qr_tokens karena kolom sudah tersedia.