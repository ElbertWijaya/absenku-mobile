import 'reflect-metadata';
import * as bcrypt from 'bcryptjs';
import AppDataSource from '../database/data-source';
import { User } from '../entities/user.entity';

async function run() {
  const newPassword = process.env.ADMIN_NEW_PASSWORD || 'Admin@123';
  await AppDataSource.initialize();
  const userRepo = AppDataSource.getRepository(User);
  const admin = await userRepo.findOne({ where: { email: 'admin@example.com' }, relations: ['roles'] });
  if (!admin) {
    console.log('❌ Admin user not found (admin@example.com).');
    await AppDataSource.destroy();
    process.exit(2);
  }
  const hashed = await bcrypt.hash(newPassword, 10);
  (admin as any).password_hash = hashed;
  await userRepo.save(admin);
  console.log(`✅ Admin password reset. Email=admin@example.com, NewPassword=${newPassword}`);
  await AppDataSource.destroy();
}

run().catch(async (e) => {
  console.error('❌ Failed to reset admin password:', e);
  try { await AppDataSource.destroy(); } catch {}
  process.exit(1);
});
