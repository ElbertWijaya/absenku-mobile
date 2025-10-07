import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QrToken } from '../../entities/qr-token.entity';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'crypto';

@Injectable()
export class QrService {
  constructor(
    @InjectRepository(QrToken) private readonly qrRepo: Repository<QrToken>,
    private readonly jwt: JwtService,
    private readonly cfg: ConfigService,
  ) {}

  private ttlSeconds() {
    return Number(this.cfg.get('QR_TOKEN_TTL_SECONDS', '120'));
  }

  private now() {
    return new Date();
  }

  async issue(location_id?: number, shift_id?: number) {
    try {
      const jti = randomUUID();
      const issued_at = this.now();
      const expires_at = new Date(issued_at.getTime() + this.ttlSeconds() * 1000);

      const payload: Record<string, any> = {
        location_id: location_id ?? null,
        shift_id: shift_id ?? null,
        jti,
        iat: Math.floor(issued_at.getTime() / 1000),
        exp: Math.floor(expires_at.getTime() / 1000),
      };

      const token = await this.jwt.signAsync(payload, {
        secret: this.cfg.get<string>('JWT_ACCESS_SECRET'),
        expiresIn: `${this.ttlSeconds()}s`,
      });

      const rec = this.qrRepo.create({
        jti,
        issued_at,
        expires_at,
        meta: { location_id, shift_id },
      });
      await this.qrRepo.save(rec);

      return { token, expires_at, location_id: location_id ?? null, shift_id: shift_id ?? null };
    } catch (e) {
      throw new InternalServerErrorException('Failed to issue QR token');
    }
  }
}