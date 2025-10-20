import 'reflect-metadata';
import AppDataSource from './database/data-source';
import { User } from './entities/user.entity';
import { Role } from './entities/role.entity';
import { Employee } from './entities/employee.entity';
import { AttendanceLog } from './entities/attendance-log.entity';
import { QrCode } from './entities/qr-code.entity';
import * as bcrypt from 'bcryptjs';

function randInt(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function pick<T>(arr: T[]): T {
  return arr[randInt(0, arr.length - 1)];
}

function pad2(n: number) {
  return n < 10 ? `0${n}` : `${n}`;
}

function dateStr(d: Date) {
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
}

async function ensureRole(name: string) {
  const roles = AppDataSource.getRepository(Role);
  let role = await roles.findOne({ where: { name } });
  if (!role) {
    role = roles.create({ name });
    role = await roles.save(role);
    console.log(`✅ Created role ${name}`);
  }
  return role;
}

async function ensureAdmin() {
  const users = AppDataSource.getRepository(User);
  const admin = await users.findOne({ where: { email: 'admin@example.com' } });
  if (admin) return admin;
  const adminRole = await ensureRole('ADMIN');
  const password_hash = await bcrypt.hash('Admin@123', 10);
  const entity = users.create({ email: 'admin@example.com', username: 'admin', password_hash, roles: [adminRole] });
  const saved = await users.save(entity);
  console.log('✅ Seeded admin@example.com (Admin@123)');
  return saved;
}

async function run() {
  await AppDataSource.initialize();
  console.log('✅ Connected');

  const userRepo = AppDataSource.getRepository(User);
  const empRepo = AppDataSource.getRepository(Employee);
  const logRepo = AppDataSource.getRepository(AttendanceLog);
  const qrRepo = AppDataSource.getRepository(QrCode);

  const EMPLOYEE = await ensureRole('EMPLOYEE');
  await ensureAdmin();

  // 1) Create ~20 employees + users
  const firstNames = ['Asep','Budi','Citra','Dewi','Eka','Fajar','Gita','Hadi','Indah','Joko','Kiki','Lia','Mira','Nanda','Oki','Putra','Rani','Sari','Tono','Wulan'];
  const lastNames = ['Saputra','Wijaya','Santoso','Halim','Pratama','Siregar','Sitohang','Maulana','Nuraini','Utami'];

  const password_hash = await bcrypt.hash('Password@123', 10);
  const createdUsers: { user: User; employee: Employee }[] = [];

  for (let i = 1; i <= 20; i++) {
    const full = `${pick(firstNames)} ${pick(lastNames)}`;
    const email = `employee${i}@example.com`;
    const username = `employee${i}`;

    let employee = await empRepo.findOne({ where: { email } });
    if (!employee) {
      employee = empRepo.create({
        full_name: full,
        role_title: 'Staff',
        gender: Math.random() > 0.5 ? 'M' : 'F',
        phone: `08${randInt(100000000, 999999999)}`,
        address: null,
        email,
        birth_date: `19${randInt(80, 99)}-${pad2(randInt(1, 12))}-${pad2(randInt(1, 28))}`,
        religion: null,
        join_date: `20${pad2(randInt(20, 25))}-${pad2(randInt(1, 12))}-${pad2(randInt(1, 28))}`,
        is_active: true,
        base_salary_rate: '5000000.00',
        default_location_id: randInt(1, 3),
      });
      employee = await empRepo.save(employee);
      console.log(`👤 Employee: ${employee.full_name}`);
    }

    let user = await userRepo.findOne({ where: { email }, relations: ['roles'] });
    if (!user) {
      user = userRepo.create({ email, username, password_hash, employee, roles: [EMPLOYEE] });
      user = await userRepo.save(user);
      console.log(`   ↳ User: ${user.username}`);
    } else {
      // ensure link to employee + EMPLOYEE role
      user.employee = employee;
      const names = (user.roles ?? []).map((r) => r.name);
      if (!names.includes('EMPLOYEE')) {
        user.roles = [...(user.roles ?? []), EMPLOYEE];
      }
      user = await userRepo.save(user);
    }

    createdUsers.push({ user, employee });
  }

  // 2) Create ~80 attendance logs spread over last ~30 days
  let logsCreated = 0;
  const today = new Date();
  for (let d = 0; d < 30 && logsCreated < 80; d++) {
    const day = new Date(today.getFullYear(), today.getMonth(), today.getDate() - d);
    const work_date = dateStr(day);
    // choose a random subset of employees to create logs for this day
    for (const { user, employee } of createdUsers) {
      if (logsCreated >= 80) break;
      if (Math.random() < 0.5) continue; // about half of employees present

      const location_id = employee.default_location_id ?? randInt(1, 3);
      // Random check-in around 08:30-09:45 WIB, with mix of on_time/late
      const hour = 8 + randInt(0, 1); // 8 or 9
      const minute = hour === 8 ? randInt(30, 59) : randInt(0, 45);
      const checkIn = new Date(day.getFullYear(), day.getMonth(), day.getDate(), hour, minute, randInt(0, 59));
      const checkOut = Math.random() < 0.85 ? new Date(checkIn.getTime() + randInt(7 * 60, 9 * 60) * 60000) : null; // 7-9h later

      // status & late minutes (threshold 09:15)
      const threshold = new Date(day.getFullYear(), day.getMonth(), day.getDate(), 9, 15, 0);
      const late = checkIn.getTime() > threshold.getTime();
      const status: 'on_time' | 'late' = late ? 'late' : 'on_time';
      const reference = new Date(day.getFullYear(), day.getMonth(), day.getDate(), 9, 0, 0);
      const lateMinutes = late ? Math.max(0, Math.round((checkIn.getTime() - reference.getTime()) / 60000)) : 0;
      const workMinutes = checkOut ? Math.max(0, Math.round((checkOut.getTime() - checkIn.getTime()) / 60000)) : null;

      const exists = await logRepo.findOne({ where: { user_id: user.id, work_date } });
      if (exists) continue;

      const entity = logRepo.create({
        user_id: user.id,
        employee_id: employee.id,
        work_date,
        location_id,
        check_in_at: checkIn,
        check_out_at: checkOut,
        late_minutes: lateMinutes,
        work_minutes: workMinutes,
        status,
      });
      await logRepo.save(entity);
      logsCreated++;
    }
  }
  console.log(`✅ Created ${logsCreated} attendance logs`);

  // 3) Create QR codes for recent 7 days
  for (let i = 0; i < 7; i++) {
    const day = new Date(today.getFullYear(), today.getMonth(), today.getDate() - i);
    const work_date = dateStr(day);
    const existing = await qrRepo.findOne({ where: { work_date } });
    if (existing) continue;
    const valid_until = new Date(day.getFullYear(), day.getMonth(), day.getDate(), 23, 59, 59);
    const token = `dummy-token-${work_date}-${randInt(100000, 999999)}`;
    const qr = qrRepo.create({ work_date, token, valid_until });
    await qrRepo.save(qr);
  }
  console.log('✅ QR codes prepared for 7 recent days');

  await AppDataSource.destroy();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
