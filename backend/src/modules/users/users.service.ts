import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
// import repository/entity sesuai struktur Anda

@Injectable()
export class UsersService {
  // inject repository via constructor

  async findByEmail(email: string) {
    // ganti sesuai ORM Anda (TypeORM/Prisma)
    // contoh TypeORM: return this.repo.findOne({ where: { email } });
    return null as any; // TODO: implement
  }

  async findById(id: number | string) {
    // TODO: implement
    return null as any;
  }

  async validateUser(email: string, password: string) {
    const user = await this.findByEmail(email);
    if (!user) return null;
    // sesuaikan nama kolom hash di DB, mis. user.password atau user.passwordHash
    const ok = await bcrypt.compare(password, user.password ?? user.passwordHash);
    if (!ok) return null;
    return user;
  }

  toSafeUser(user: any) {
    const { password, passwordHash, ...rest } = user;
    return rest;
  }
}