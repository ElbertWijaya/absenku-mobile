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

  @Get('my-today')
  myToday(@Req() req: any) {
    const userId: string = req?.user?.id;
    return this.svc.myToday(userId);
  }

  // Admin report: list all attendance activity for a specific date (yyyy-MM-dd)
  @Get('report/day')
  reportByDay(@Query('date') date: string) {
    return this.svc.reportByDay(date);
  }

  // Admin rollcall: returns all EMPLOYEE users with attendance status for a date
  @Get('report/rollcall')
  rollcall(@Query('date') date: string) {
    return this.svc.rollcall(date);
  }

  // Admin summary for today: returns counts and lists for dashboard
  @Get('admin-summary')
  adminSummary(@Query('date') date: string) {
    return this.svc.adminSummary(date);
  }

  // Admin month summary: return list of days with counts for a given month
  @Get('report/month-summary')
  monthSummary(@Query('year') year: string, @Query('month') month: string) {
    const y = parseInt(year as any, 10);
    const m = parseInt(month as any, 10);
    return this.svc.monthSummary(y, m);
  }
}
