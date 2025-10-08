import { Injectable, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class QrService {
  constructor(private readonly jwt: JwtService) {}

  getActive(location_id: number, shift_id: number) {
    if (!location_id || !shift_id) {
      throw new BadRequestException('location_id and shift_id are required');
    }
    const ttl = Number(process.env.QR_TOKEN_TTL_SECONDS || 120);
    const exp = new Date(Date.now() + ttl * 1000);
    const token = this.jwt.sign({ loc: location_id, sh: shift_id, typ: 'qr' }, { expiresIn: `${ttl}s` });
    return {
      token,
      expires_at: exp.toISOString(),
      shift_id,
      location_id,
    };
    }

  issue(location_id: number, shift_id: number) {
    return this.getActive(location_id, shift_id);
  }
}
