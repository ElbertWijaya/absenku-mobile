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
    const user = await this.userRepository.findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
    if (!user) throw new Error('User not found');

    // Username update (with uniqueness check)
    if (data.username !== undefined) {
      const newUsername = (data.username ?? '').trim() || null;
      if (newUsername) {
        const existing = await this.userRepository.findOne({ where: { username: newUsername } });
        if (existing && existing.id !== user.id) {
          throw new BadRequestException('Username sudah dipakai. Silakan pilih yang lain.');
        }
      }
      user.username = newUsername;
    }

    // Ensure employee exists if we're going to update employee fields
    if (data.full_name !== undefined) {
      if (!user.employee) {
        const emp = this.employeeRepository.create({
          full_name: data.full_name || '',
        });
        user.employee = await this.employeeRepository.save(emp);
      } else {
        user.employee.full_name = data.full_name || '';
        await this.employeeRepository.save(user.employee);
      }
    }
    await this.userRepository.save(user);
    // Reload with relations to reflect nested updates
    const saved = await this.findById(userId);
    return saved!;
  }

  async updatePhone(userId: string, phone: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: userId }, relations: ['employee', 'roles'] });
    if (!user) throw new Error('User not found');
    if (!user.employee) {
      const emp = this.employeeRepository.create({
        full_name: '',
        phone: phone || null,
      });
      user.employee = await this.employeeRepository.save(emp);
    } else {
      user.employee.phone = phone || null;
      await this.employeeRepository.save(user.employee);
    }
    await this.userRepository.save(user);
    const saved = await this.findById(userId);
    return saved!;
  }
}