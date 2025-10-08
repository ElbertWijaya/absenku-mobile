import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
  ) {}

  // Contoh implementasi; sesuaikan dengan UsersService Anda.
  // Jika UsersService belum punya validateUser, gunakan findByEmail + verifikasi password di sini.
  async login(email: string, password: string) {
    // Ganti sesuai method yang Anda miliki di UsersService
    const user = await (this.users as any).validateUser?.(email, password)
      ?? null;

    if (!user) throw new UnauthorizedException('Invalid credentials');

    const payload = { sub: user.id, email: user.email };
    const access_token = await this.jwt.signAsync(payload);
    // Jika punya helper toSafeUser, gunakan. Kalau tidak ada, kembalikan field aman.
    const safeUser = (this.users as any).toSafeUser?.(user) ?? {
      id: user.id,
      email: user.email,
    };

    return { access_token, user: safeUser };
  }
}