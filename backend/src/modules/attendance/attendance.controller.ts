import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AttendanceService } from './attendance.service';

@UseGuards(AuthGuard('jwt'))
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly svc: AttendanceService) {}

  @Post('check-in')
  checkIn(@Body() body: any) {
    return this.svc.checkIn(body);
  }

  @Post('check-out')
  checkOut(@Body() body: any) {
    return this.svc.checkOut(body);
  }

  @Get('my')
  my(@Query('start') start?: string, @Query('end') end?: string) {
    return this.svc.my({ start, end });
  }
}
