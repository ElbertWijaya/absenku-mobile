import 'reflect-metadata';
import AppDataSource from './database/data-source';
import { Role } from './entities/role.entity';
import { User } from './entities/user.entity';

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
  await AppDataSource.initialize();
  const userRepo = AppDataSource.getRepository(User);

  const ADMIN = await ensureRole('ADMIN');
  const EMPLOYEE = await ensureRole('EMPLOYEE');

  // Assign ADMIN to admin@example.com
  const admin = await userRepo.findOne({ where: { email: 'admin@example.com' }, relations: ['roles'] });
  if (admin) {
    const names = (admin.roles ?? []).map((r) => r.name);
    if (!names.includes('ADMIN')) {
      admin.roles = [...(admin.roles ?? []), ADMIN];
      await userRepo.save(admin);
      console.log('✅ Assigned ADMIN role to admin@example.com');
    } else {
      console.log('ℹ️  Admin already has ADMIN role');
    }
  } else {
    console.log('⚠️  admin@example.com not found');
  }

  // Assign EMPLOYEE to known sample users if missing
  const emails = [
    'elbert@example.com',
    'fernando@example.com',
    'thoro@example.com',
    'howard@example.com',
  ];
  for (const email of emails) {
    const u = await userRepo.findOne({ where: { email }, relations: ['roles'] });
    if (!u) continue;
    const names = (u.roles ?? []).map((r) => r.name);
    if (!names.includes('EMPLOYEE')) {
      u.roles = [...(u.roles ?? []), EMPLOYEE];
      await userRepo.save(u);
      console.log(`✅ Assigned EMPLOYEE role to ${email}`);
    }
  }

  await AppDataSource.destroy();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
