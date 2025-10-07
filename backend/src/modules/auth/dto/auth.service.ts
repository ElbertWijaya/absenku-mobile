import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwt: JwtService,
  ) {}

  async validateUser(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user) throw new UnauthorizedException('Invalid credentials');
    const ok = await bcrypt.compare(password, user.password_hash);
    if (!ok) throw new UnauthorizedException('Invalid credentials');
    return user;
  }

  async login(email: string, password: string) {
    const user = await this.validateUser(email, password);
    const roles = (user.roles || []).map((r) => r.name);
    const payload = {
      sub: user.id,
      roles,
      employee_id: user.employee?.id || null,
    };
    const access_token = await this.jwt.signAsync(payload);
    await this.usersService.updateLastLogin(user.id);
    return {
      access_token,
      // refresh_token bisa ditambahkan nanti (rotating refresh)
      user: this.usersService.toSafeUser(user),
    };
  }
}