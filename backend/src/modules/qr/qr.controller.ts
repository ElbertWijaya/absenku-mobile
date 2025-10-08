import { Controller, Get, Post, Query, Body, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { QrService } from './qr.service';

@Controller('qr')
export class QrController {
  constructor(private readonly qr: QrService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('active')
  getActive(@Query('location_id') location_id: number, @Query('shift_id') shift_id: number) {
    return this.qr.getActive(Number(location_id), Number(shift_id));
  }

  @UseGuards(AuthGuard('jwt'))
  @Post('issue')
  issue(@Body() body: any) {
    const { location_id, shift_id } = body ?? {};
    return this.qr.issue(Number(location_id), Number(shift_id));
  }
}
