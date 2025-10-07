import 'dotenv/config';
import 'ts-node/register';
import { DataSource } from 'typeorm';

const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  username: process.env.DB_USER || 'absensi_user',
  password: process.env.DB_PASS || 'supersecret',
  database: process.env.DB_NAME || 'absensi_db',
  charset: 'utf8mb4',
  timezone: 'Z',
  synchronize: false,
  logging: false,
  entities: [], // add entity classes here as you create them
  migrations: ['src/database/migrations/*.ts'],
});

export default AppDataSource;