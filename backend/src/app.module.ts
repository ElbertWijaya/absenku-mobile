import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HealthModule } from './health/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { QrModule } from './modules/qr/qr.module';
import { AttendanceModule } from './modules/attendance/attendance.module';

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
        timezone: 'Z',
      }),
    }),
    HealthModule,
    UsersModule,
    AuthModule,
    QrModule,
    AttendanceModule,
  ],
})
export class AppModule {}