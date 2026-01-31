import 'reflect-metadata';
import AppDataSource from '../database/data-source';
import { User } from '../entities/user.entity';
import * as bcrypt from 'bcryptjs';

async function main() {
  const NEW_PASSWORD = 'Pass@123';
  console.log('🔐 Resetting all user passwords to a single value...');

  await AppDataSource.initialize();
  const repo = AppDataSource.getRepository(User);

  const users = await repo.find();
  console.log(`Found ${users.length} users.`);
  if (users.length === 0) {
    await AppDataSource.destroy();
    console.log('No users to update.');
    return;
  }

  const hashed = await bcrypt.hash(NEW_PASSWORD, 10);

  // Use transaction for consistency
  await repo.manager.transaction(async (tx) => {
    for (const u of users) {
      (u as any).password_hash = hashed;
      await tx.getRepository(User).save(u);
    }
  });

  console.log(`✅ Updated ${users.length} users to new password.`);
  await AppDataSource.destroy();
}

main().catch(async (e) => {
  console.error('Failed to reset passwords:', e);
  try { await AppDataSource.destroy(); } catch {}
  process.exit(1);
});
