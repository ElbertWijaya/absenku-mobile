import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QrCode } from '../../entities/qr-code.entity';
import { QrController } from './qr.controller';
import { QrService } from './qr.service';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'dev-secret',
      signOptions: { algorithm: 'HS256' },
    }),
    TypeOrmModule.forFeature([QrCode]),
  ],
  controllers: [QrController],
  providers: [QrService],
})
export class QrModule {}
