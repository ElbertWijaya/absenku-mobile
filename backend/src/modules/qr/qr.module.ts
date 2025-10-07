import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QrToken } from '../../entities/qr-token.entity';
import { QrService } from './qr.service';
import { QrController } from './qr.controller';

@Module({
  imports: [TypeOrmModule.forFeature([QrToken])],
  providers: [QrService],
  controllers: [QrController],
  exports: [QrService],
})
export class QrModule {}