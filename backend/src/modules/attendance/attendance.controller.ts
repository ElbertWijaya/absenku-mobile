import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AttendanceService } from './attendance.service';
import { CheckInDto } from './dto/check-in.dto';
import { CheckOutDto } from './dto/check-out.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly att: AttendanceService) {}

  @Post('check-in')
  checkIn(@Req() req: any, @Body() dto: CheckInDto) {
    return this.att.checkIn(req.user, dto.qr_token, dto.lat, dto.lng);
  }

  @Post('check-out')
  checkOut(@Req() req: any, @Body() dto: CheckOutDto) {
    return this.att.checkOut(req.user, dto.lat, dto.lng);
  }

  @Get('my')
  my(@Req() req: any, @Query('start') start?: string, @Query('end') end?: string) {
    return this.att.myHistory(req.user, start, end);
  }
}