import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private readonly users: UsersService,
    private readonly jwt: JwtService,
  ) {}

  async login(email: string, password: string) {
    const user = await this.users.validateUser(email, password);
    if (!user) throw new UnauthorizedException('Invalid credentials');

    const payload = { sub: user.id, email: user.email };
    const access_token = await this.jwt.signAsync(payload);
    return { access_token, user: this.users.toSafeUser(user) };
  }

  async changePassword(userId: string, currentPassword: string, newPassword: string) {
    const user = await this.users.findById(userId);
    if (!user) throw new UnauthorizedException('User not found');
    const ok = await bcrypt.compare(currentPassword, user.password_hash);
    if (!ok) throw new BadRequestException('Password saat ini salah');
    if (!newPassword || newPassword.length < 6) throw new BadRequestException('Password baru minimal 6 karakter');
    // Hash and save
    const hashed = await bcrypt.hash(newPassword, 10);
    (user as any).password_hash = hashed;
    // Persist via repository
    // We don't have a direct repository here, use users service internal repo via updateIdentity-like pattern
    await (this.users as any).userRepository.save(user);
    return { success: true };
  }
}