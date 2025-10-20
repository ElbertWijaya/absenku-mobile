import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User } from '../../entities/user.entity';
import { Employee } from '../../entities/employee.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Employee)
    private readonly employeeRepository: Repository<Employee>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ 
      where: { email },
      relations: ['employee', 'roles'] 
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ 
      where: { id },
      relations: ['employee', 'roles'] 
    });
  }

  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.findByEmail(email);
    if (!user) return null;
    
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) return null;
    
    return user;
  }

  toSafeUser(user: User) {
    const { password_hash, ...rest } = user;
    return rest;
  }

  async createUser(userData: {
    email: string;
    password: string;
    username?: string;
  }): Promise<User> {
    const hashedPassword = await bcrypt.hash(userData.password, 10);
    
    const user = this.userRepository.create({
      email: userData.email,
      username: userData.username,
      password_hash: hashedPassword,
    });
    
    return this.userRepository.save(user);
  }

  async updateIdentity(userId: string, data: { full_name?: string; username?: string }): Promise<User> {
    const saved = await this.userRepository.manager.transaction(async (tx) => {
      const user = await tx.getRepository(User).findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
      if (!user) throw new Error('User not found');

      // Username update (with uniqueness check)
      if (data.username !== undefined) {
        const newUsername = (data.username ?? '').trim() || null;
        if (newUsername) {
          const existing = await tx.getRepository(User).findOne({ where: { username: newUsername } });
          if (existing && existing.id !== user.id) {
            throw new BadRequestException('Username sudah dipakai. Silakan pilih yang lain.');
          }
        }
        user.username = newUsername;
      }

      // Ensure employee exists if we're going to update employee fields
      if (data.full_name !== undefined) {
        const fullName = (data.full_name ?? '').trim();
        if (!user.employee) {
          const emp = tx.getRepository(Employee).create({
            full_name: fullName || (user.username || user.email.split('@')[0]),
            email: user.email,
            is_active: true,
          });
          user.employee = await tx.getRepository(Employee).save(emp);
        } else {
          user.employee.full_name = fullName || user.employee.full_name || (user.username || user.email.split('@')[0]);
          if (!user.employee.email) user.employee.email = user.email;
          if (user.employee.is_active === undefined || user.employee.is_active === null) user.employee.is_active = true as any;
          await tx.getRepository(Employee).save(user.employee);
        }
      }

      await tx.getRepository(User).save(user);
      return await tx.getRepository(User).findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
    });
    return saved!;
  }

  async updatePhone(userId: string, phone: string): Promise<User> {
    // normalize phone: keep digits and leading +
    const normalized = (phone ?? '')
      .trim()
      .replace(/[^+\d]/g, '')
      .replace(/(?!^)[+]/g, '');
    if (normalized && !/^\+?\d{7,15}$/.test(normalized)) {
      throw new BadRequestException('Nomor telepon tidak valid. Gunakan format internasional, mis. +628123456789.');
    }

    const saved = await this.userRepository.manager.transaction(async (tx) => {
      const user = await tx.getRepository(User).findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
      if (!user) throw new Error('User not found');
      if (!user.employee) {
        const emp = tx.getRepository(Employee).create({
          full_name: user.username || user.email.split('@')[0],
          phone: normalized || null,
          email: user.email,
          is_active: true,
        });
        user.employee = await tx.getRepository(Employee).save(emp);
      } else {
        user.employee.phone = normalized || null;
        if (!user.employee.full_name) user.employee.full_name = user.username || user.email.split('@')[0];
        if (!user.employee.email) user.employee.email = user.email;
        if (user.employee.is_active === undefined || user.employee.is_active === null) user.employee.is_active = true as any;
        await tx.getRepository(Employee).save(user.employee);
      }
      await tx.getRepository(User).save(user);
      return await tx.getRepository(User).findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
    });
    return saved!;
  }
}