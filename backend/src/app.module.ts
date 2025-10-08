import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthModule } from './health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { QrModule } from './modules/qr/qr.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { Role } from './entities/role.entity';
import { User } from './entities/user.entity';
import { Employee } from './entities/employee.entity';
import { AttendanceLog } from './entities/attendance-log.entity';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'mysql',
        host: cfg.get<string>('DB_HOST', '127.0.0.1'),
        port: Number(cfg.get<string>('DB_PORT', '3306')),
        username: cfg.get<string>('DB_USER', 'absensi_user'),
        password: cfg.get<string>('DB_PASS', 'supersecret'),
        database: cfg.get<string>('DB_NAME', 'absensi_db'),
        synchronize: false,
        autoLoadEntities: true,
  entities: [Role, User, Employee, AttendanceLog],
        timezone: 'Z',
      }),
    }),
    HealthModule,
    UsersModule,
  QrModule,
  AttendanceModule,
    AuthModule,
  ],
})
export class AppModule {}