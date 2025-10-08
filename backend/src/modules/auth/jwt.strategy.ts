import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../users/users.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly users: UsersService,
    private readonly cfg: ConfigService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: cfg.get<string>('JWT_SECRET', 'dev-secret'),
    });
  }

  async validate(payload: any) {
    // Sesuaikan method pencarian user Anda; misalnya findById(payload.sub)
    const user = await (this.users as any).findById?.(payload.sub)
      ?? (this.users as any).findOneById?.(payload.sub)
      ?? null;

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Kembalikan objek user (atau versi aman). Passport akan menaruh ini di req.user
    return (this.users as any).toSafeUser?.(user) ?? user;
  }
}