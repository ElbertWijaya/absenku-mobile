import 'reflect-metadata';
import AppDataSource from '../database/data-source';
import { User } from '../entities/user.entity';

async function main() {
  await AppDataSource.initialize();
  try {
    const repo = AppDataSource.getRepository(User);
    const users = await repo.find({ relations: ['roles', 'employee'] });
    if (users.length === 0) {
      console.log('No users found.');
      return;
    }
    for (const u of users) {
      const roles = (u.roles || []).map((r: any) => r.name || r).join(', ');
      const emp = u.employee;
      console.log(
        `- id=${u.id} | email=${u.email} | username=${u.username ?? '-'} | roles=[${roles}] | full_name=${emp?.full_name ?? '-'} | phone=${emp?.phone ?? '-'} `,
      );
    }
  } finally {
    await AppDataSource.destroy();
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
