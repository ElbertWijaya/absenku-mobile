import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AttendanceService } from './attendance.service';

@UseGuards(AuthGuard('jwt'))
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly svc: AttendanceService) {}

  @Post('check-in')
  checkIn(@Req() req: any, @Body() body: any) {
    // req.user is populated by JwtStrategy.validate and contains the safe user
    const userId: string = req?.user?.id;
    return this.svc.checkIn(userId, body);
  }

  @Post('check-out')
  checkOut(@Req() req: any) {
    const userId: string = req?.user?.id;
    return this.svc.checkOut(userId);
  }

  @Get('my')
  my(@Req() req: any, @Query('start') start?: string, @Query('end') end?: string) {
    const userId: string = req?.user?.id;
    return this.svc.my(userId, { start, end });
  }
}
