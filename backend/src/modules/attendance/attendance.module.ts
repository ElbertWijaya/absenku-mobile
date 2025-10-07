import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AttendanceLog } from '../../entities/attendance-log.entity';
import { AttendanceService } from './attendance.service';
import { AttendanceController } from './attendance.controller';
import { Shift } from '../../entities/shift.entity';
import { Location } from '../../entities/location.entity';
import { Employee } from '../../entities/employee.entity';

@Module({
  imports: [TypeOrmModule.forFeature([AttendanceLog, Shift, Location, Employee])],
  providers: [AttendanceService],
  controllers: [AttendanceController],
})
export class AttendanceModule {}