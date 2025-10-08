import 'reflect-metadata';
import AppDataSource from './database/data-source';
import * as bcrypt from 'bcryptjs';
import { User } from './entities/user.entity';

const users = [
  { email: 'elbert@example.com', username: 'Elbert' },
  { email: 'fernando@example.com', username: 'Fernando' },
  { email: 'thoro@example.com', username: 'Thoro' },
  { email: 'howard@example.com', username: 'Howard' },
];

async function run() {
  await AppDataSource.initialize();
  const repo = AppDataSource.getRepository(User);
  const password = await bcrypt.hash('Password@123', 10);

  for (const u of users) {
    const exists = await repo.findOne({ where: { email: u.email } });
    if (exists) {
      console.log(`Skip existing: ${u.email}`);
      continue;
    }
    const entity = repo.create({
      email: u.email,
      username: u.username,
      password_hash: password,
    });
    await repo.save(entity);
    console.log(`Created user: ${u.username} <${u.email}>`);
  }

  await AppDataSource.destroy();
}

run().catch((e) => {
  console.error(e);
  process.exit(1);
});
