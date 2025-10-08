import 'reflect-metadata';
import * as bcrypt from 'bcryptjs';
import { User } from './entities/user.entity';
import AppDataSource from './database/data-source';

async function seedAdmin() {
  try {
    await AppDataSource.initialize();
    console.log('✅ Database connection initialized');

    const userRepository = AppDataSource.getRepository(User);
    
    // Check if admin user already exists
    const existingAdmin = await userRepository.findOne({
      where: { email: 'admin@example.com' }
    });

    if (existingAdmin) {
      console.log('ℹ️  Admin user already exists');
      return;
    }

    // Create admin user
    const hashedPassword = await bcrypt.hash('Admin@123', 10);
    
    const adminUser = userRepository.create({
      email: 'admin@example.com',
      username: 'admin',
      password_hash: hashedPassword,
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