import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AttendanceController } from './attendance.controller';
import { AttendanceService } from './attendance.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';
import { User } from '../../entities/user.entity';
import { Role } from '../../entities/role.entity';
import { Employee } from '../../entities/employee.entity';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'dev-secret',
      signOptions: { algorithm: 'HS256' },
    }),
  TypeOrmModule.forFeature([AttendanceLog, User, Role, Employee]),
  ],
  controllers: [AttendanceController],
  providers: [AttendanceService],
})
export class AttendanceModule {}
