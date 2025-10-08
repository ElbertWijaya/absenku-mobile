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
    const user =
      (await this.users.findById?.(payload.sub)) ??
      (await (this.users as any).findOneById?.(payload.sub)) ??
      null;

    if (!user) throw new UnauthorizedException('User not found');

    return this.users.toSafeUser(user);
  }
}