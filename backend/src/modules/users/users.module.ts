import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../../entities/user.entity';
import { Role } from '../../entities/role.entity';
import { Employee } from '../../entities/employee.entity';
import { UsersService } from './users.service';
import { MeController } from './me.controller';

@Module({
  imports: [TypeOrmModule.forFeature([User, Role, Employee])],
  providers: [UsersService],
  controllers: [MeController],
  exports: [UsersService, TypeOrmModule],
})
export class UsersModule {}