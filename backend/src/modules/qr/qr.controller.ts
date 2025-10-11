import { Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { QrService } from './qr.service';

@Controller('qr')
export class QrController {
  constructor(private readonly qr: QrService) {}

  @UseGuards(AuthGuard('jwt'))
  @Get('active')
  getActive() { return this.qr.getActive(); }

  @UseGuards(AuthGuard('jwt'))
  @Post('issue')
  issue() { return this.qr.issue(); }
}
