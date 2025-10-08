import 'dotenv/config';
import 'ts-node/register';
import { DataSource } from 'typeorm';
import { User } from '../entities/user.entity';
import { Role } from '../entities/role.entity';
import { Employee } from '../entities/employee.entity';

const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  username: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'rootpass',
  database: process.env.DB_NAME || 'absensi_db',
  charset: 'utf8mb4',
  timezone: 'Z',
  synchronize: true, // Enable untuk development - auto sync schema
  logging: ['error', 'warn'],
  entities: [User, Role, Employee],
  migrations: ['src/database/migrations/*.ts'],
});

export default AppDataSource;