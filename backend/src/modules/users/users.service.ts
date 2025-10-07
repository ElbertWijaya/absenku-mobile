import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly usersRepo: Repository<User>,
  ) {}

  findByEmail(email: string) {
    return this.usersRepo.findOne({
      where: { email },
      relations: ['roles', 'employee'],
    });
  }

  findById(id: string) {
    return this.usersRepo.findOne({
      where: { id },
      relations: ['roles', 'employee'],
    });
  }

  async updateLastLogin(userId: string) {
    await this.usersRepo.update(userId, { last_login_at: new Date() });
  }

  toSafeUser(user: User) {
    if (!user) return null;
    // omit password_hash in responses
    const { password_hash, ...rest } = user as any;
    return rest;
  }
}