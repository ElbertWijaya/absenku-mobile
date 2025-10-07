# Aturan Payroll Harian

Tujuan
- Menghitung gaji per hari berdasarkan kehadiran, potongan keterlambatan, dan lembur.

Terminologi
- base_pay: tarif gaji harian karyawan (`employees.base_salary_rate`).
- scheduled_minutes: durasi shift (end - start) dalam menit.
- grace_minutes: toleransi keterlambatan (ENV `ATTENDANCE_GRACE_MINUTES` atau `shifts.grace_minutes`).
- late_minutes: menit keterlambatan aktual (max(0, check_in - shift.start - grace)).
- work_minutes: menit kerja efektif (check_out - check_in), auto check-out pada end_of_shift jika lupa.

Parameter (ENV)
- PAYROLL_LATE_UNIT_MIN: ukuran blok telat (mis. 15 menit).
- PAYROLL_LATE_UNIT_DEDUCTION_PERCENT: potongan per blok terhadap base_pay (mis. 1% per 15 menit).
- PAYROLL_OVERTIME_RATE_MULTIPLIER: koefisien lembur (mis. 1.5x dari tarif jam normal).
- PAYROLL_MINUTES_PER_DAY: menit kerja standar per hari (mis. 480 = 8 jam).

Rumus
1) Tarif jam normal:
   hourly_rate = base_pay / (PAYROLL_MINUTES_PER_DAY / 60)

2) Potongan keterlambatan per blok:
   lateness_blocks = ceil( max(0, late_minutes) / PAYROLL_LATE_UNIT_MIN )
   late_deduction = base_pay * (PAYROLL_LATE_UNIT_DEDUCTION_PERCENT / 100) * lateness_blocks

3) Lembur:
   overtime_minutes = max(0, work_minutes - scheduled_minutes)
   overtime_hours = overtime_minutes / 60
   overtime_pay = hourly_rate * PAYROLL_OVERTIME_RATE_MULTIPLIER * overtime_hours

4) Total gaji hari itu:
   total_pay = base_pay - late_deduction + overtime_pay + allowances

Catatan & edge cases
- Jika karyawan izin/cuti/absen, `base_pay` dapat 0 atau mengikuti kebijakan.
- Jika tidak ada check-out, `work_minutes` dihitung hingga end_of_shift (lembur = 0).
- Potongan telat tidak boleh melebihi `base_pay`.
- Kebijakan minimum gaji harian bisa diterapkan (opsional): total_pay >= base_pay_minimum.
- Semua nilai disimpan dalam `payroll_items.meta` untuk audit detail.

Audit & Laporan
- Simpan: base_pay, late_minutes, lateness_blocks, late_deduction, overtime_minutes, overtime_pay.
- Laporan periode men-sum nilai per karyawan.

Konfigurasi Lanjutan (opsional)
- Diferensiasi potongan per jabatan.
- Batas maksimum potongan telat per hari (mis. 30% dari base_pay).
- Batas maksimum lembur per hari (mis. 2 jam).