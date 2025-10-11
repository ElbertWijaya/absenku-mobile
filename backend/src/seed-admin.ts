import 'reflect-metadata';
import * as bcrypt from 'bcryptjs';
import { User } from './entities/user.entity';
import { Role } from './entities/role.entity';
import AppDataSource from './database/data-source';

async function seedAdmin() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connection initialized');

  const userRepository = AppDataSource.getRepository(User);
  const roleRepository = AppDataSource.getRepository(Role);
    
    // Check if admin user already exists
    const existingAdmin = await userRepository.findOne({
      where: { email: 'admin@example.com' }
    });

    if (existingAdmin) {
      console.log('ℹ️  Admin user already exists');
      return;
    }

    // Ensure ADMIN role exists
    let adminRole = await roleRepository.findOne({ where: { name: 'ADMIN' } });
    if (!adminRole) {
      adminRole = roleRepository.create({ name: 'ADMIN' });
      adminRole = await roleRepository.save(adminRole);
      console.log('✅ Created role ADMIN');
    }

    // Create admin user
    const hashedPassword = await bcrypt.hash('Admin@123', 10);
    
    const adminUser = userRepository.create({
      email: 'admin@example.com',
      username: 'admin',
      password_hash: hashedPassword,
      roles: [adminRole],
    });

    await userRepository.save(adminUser);
    console.log('✅ Admin user created successfully');
    console.log('   Email: admin@example.com');
    console.log('   Password: Admin@123');

  } catch (error) {
    console.error('❌ Error seeding admin user:', error);
  } finally {
    await AppDataSource.destroy();
  }
}

seedAdmin();