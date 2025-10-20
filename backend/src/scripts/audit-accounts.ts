import 'reflect-metadata';
import AppDataSource from '../database/data-source';
import { User } from '../entities/user.entity';
import { Role } from '../entities/role.entity';
import { Employee } from '../entities/employee.entity';

type Issue = {
  type:
    | 'MISSING_ROLE'
    | 'MISSING_EMPLOYEE_FOR_EMPLOYEE_ROLE'
    | 'DUPLICATE_USER_EMAIL'
    | 'DUPLICATE_USERNAME'
    | 'MISSING_ROLES_TABLE_ENTRY'
    | 'MULTIPLE_USERS_SHARE_EMPLOYEE'
    | 'EMPLOYEE_MISSING_FULL_NAME';
  userId?: string;
  username?: string | null;
  email?: string;
  details?: string;
};

function nameFromEmail(email: string): string {
  const local = email.split('@')[0] ?? 'User';
  // Capitalize words split by dots/underscores
  return local
    .split(/[._-]+/)
    .filter(Boolean)
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join(' ');
}

async function ensureRole(name: string) {
  const roleRepo = AppDataSource.getRepository(Role);
  let role = await roleRepo.findOne({ where: { name } });
  if (!role) {
    role = roleRepo.create({ name });
    role = await roleRepo.save(role);
    console.log(`✅ Created role ${name}`);
  }
  return role;
}

async function run() {
  const args = process.argv.slice(2);
  const doFix = args.includes('--fix');

  await AppDataSource.initialize();
  const userRepo = AppDataSource.getRepository(User);
  const roleRepo = AppDataSource.getRepository(Role);
  const employeeRepo = AppDataSource.getRepository(Employee);

  const issues: Issue[] = [];

  // Ensure roles exist (admin/employee)
  const neededRoles = ['ADMIN', 'EMPLOYEE'];
  const existingRoles = await roleRepo.find();
  const existingRoleNames = new Set(existingRoles.map((r) => r.name));
  for (const r of neededRoles) {
    if (!existingRoleNames.has(r)) {
      issues.push({ type: 'MISSING_ROLES_TABLE_ENTRY', details: r });
      if (doFix) await ensureRole(r);
    }
  }

  // Refresh roles after potential creation
  const ADMIN = await roleRepo.findOne({ where: { name: 'ADMIN' } });
  const EMPLOYEE = await roleRepo.findOne({ where: { name: 'EMPLOYEE' } });

  // Load all users with roles and employee
  const users = await userRepo.find({ relations: ['roles', 'employee'] });

  // Check duplicates (should be prevented by unique constraints, but we verify defensively)
  const emailMap = new Map<string, string[]>();
  const usernameMap = new Map<string, string[]>();
  for (const u of users) {
    emailMap.set(u.email, [...(emailMap.get(u.email) ?? []), u.id]);
    if (u.username) {
      usernameMap.set(u.username, [...(usernameMap.get(u.username) ?? []), u.id]);
    }
  }
  for (const [email, ids] of emailMap.entries()) {
    if (ids.length > 1) {
      issues.push({ type: 'DUPLICATE_USER_EMAIL', details: `${email} -> ${ids.join(',')}` });
    }
  }
  for (const [uname, ids] of usernameMap.entries()) {
    if (ids.length > 1) {
      issues.push({ type: 'DUPLICATE_USERNAME', details: `${uname} -> ${ids.join(',')}` });
    }
  }

  // Detect multiple users referencing the same employee (logical 1:1 expectation)
  const employeeToUsers = new Map<string, string[]>();
  for (const u of users) {
    if (u.employee?.id) {
      const list = employeeToUsers.get(u.employee.id) ?? [];
      list.push(u.id);
      employeeToUsers.set(u.employee.id, list);
    }
  }
  for (const [empId, ids] of employeeToUsers.entries()) {
    if (ids.length > 1) {
      issues.push({ type: 'MULTIPLE_USERS_SHARE_EMPLOYEE', details: `employee_id=${empId} used by users: ${ids.join(',')}` });
    }
  }

  // Validate each user
  for (const u of users) {
    const roleNames = new Set((u.roles ?? []).map((r) => r.name));
    if (roleNames.size === 0) {
      issues.push({ type: 'MISSING_ROLE', userId: u.id, email: u.email, username: u.username ?? null });
      if (doFix) {
        // Default: admin@example.com => ADMIN, others => EMPLOYEE
        const addRoles: Role[] = [];
        if (u.email === 'admin@example.com' && ADMIN) addRoles.push(ADMIN);
        else if (EMPLOYEE) addRoles.push(EMPLOYEE);
        u.roles = [...(u.roles ?? []), ...addRoles];
        await userRepo.save(u);
        console.log(`🔧 Assigned default role(s) to ${u.email}`);
      }
    }

    if (roleNames.has('EMPLOYEE') && !u.employee) {
      issues.push({
        type: 'MISSING_EMPLOYEE_FOR_EMPLOYEE_ROLE',
        userId: u.id,
        email: u.email,
        username: u.username ?? null,
      });
      if (doFix) {
        // Try to link by employee email if exists; else create
        let emp = await employeeRepo.findOne({ where: { email: u.email } });
        if (!emp) {
          emp = employeeRepo.create({
            full_name: u.username ?? nameFromEmail(u.email),
            email: u.email,
            is_active: true,
            role_title: null,
            gender: null,
            phone: null,
            address: null,
            birth_date: null,
            religion: null,
            join_date: null,
            base_salary_rate: null,
            default_location_id: null,
            // default_shift_id removed
          });
          emp = await employeeRepo.save(emp);
          console.log(`🔧 Created employee for ${u.email} (id=${emp.id})`);
        } else {
          console.log(`🔧 Linked existing employee (id=${emp.id}) for ${u.email}`);
        }
        u.employee = emp;
        await userRepo.save(u);
      }
    }

    if (u.employee && (!u.employee.full_name || u.employee.full_name.trim() === '')) {
      issues.push({
        type: 'EMPLOYEE_MISSING_FULL_NAME',
        userId: u.id,
        email: u.email,
        details: `employee_id=${u.employee.id}`,
      });
      if (doFix) {
        const fullName = u.username ?? nameFromEmail(u.email);
        await employeeRepo.update({ id: u.employee.id }, { full_name: fullName });
        console.log(`🔧 Set employee full_name for ${u.email} to '${fullName}'`);
      }
    }
  }

  // Output report
  const grouped = issues.reduce<Record<string, Issue[]>>((acc, it) => {
    (acc[it.type] = acc[it.type] ?? []).push(it);
    return acc;
  }, {});

  const order: Issue['type'][] = [
    'MISSING_ROLES_TABLE_ENTRY',
    'DUPLICATE_USER_EMAIL',
    'DUPLICATE_USERNAME',
    'MULTIPLE_USERS_SHARE_EMPLOYEE',
    'MISSING_ROLE',
    'MISSING_EMPLOYEE_FOR_EMPLOYEE_ROLE',
    'EMPLOYEE_MISSING_FULL_NAME',
  ];

  console.log('');
  console.log('===== Account Data Audit =====');
  let total = 0;
  for (const t of order) {
    const arr = grouped[t] ?? [];
    if (arr.length === 0) continue;
    total += arr.length;
    console.log(`\n${t}: ${arr.length}`);
    for (const it of arr) {
      console.log(` - userId=${it.userId ?? '-'} email=${it.email ?? '-'} username=${it.username ?? '-'} ${it.details ?? ''}`);
    }
  }
  if (total === 0) {
    console.log('\n✅ No issues detected. All account-related tables look consistent.');
  } else {
    console.log(`\n⚠️  Found ${total} issue(s).${doFix ? ' Fixes were applied where possible.' : ' Run with --fix to auto-resolve common issues.'}`);
  }

  await AppDataSource.destroy();
}

run().catch(async (e) => {
  console.error('❌ Audit failed:', e);
  try { await AppDataSource.destroy(); } catch {}
  process.exit(1);
});
