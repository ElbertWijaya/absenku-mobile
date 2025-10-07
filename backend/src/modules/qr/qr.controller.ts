import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { QrService } from './qr.service';
import { IssueQrDto } from './dto/issue-qr.dto';

@UseGuards(AuthGuard('jwt'))
@Controller('qr')
export class QrController {
  constructor(private readonly qr: QrService) {}

  @Get('active')
  getActive(@Query('location_id') location_id?: string, @Query('shift_id') shift_id?: string) {
    return this.qr.issue(location_id ? Number(location_id) : undefined, shift_id ? Number(shift_id) : undefined);
  }

  @Post('issue')
  issue(@Body() dto: IssueQrDto) {
    return this.qr.issue(dto.location_id, dto.shift_id);
  }
}