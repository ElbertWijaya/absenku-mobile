import { Controller, Post, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

class LoginDto {
  email!: string;
  password!: string;
}

@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto.email, dto.password);
  }

  @Post('change-password')
  @UseGuards(AuthGuard('jwt'))
  changePassword(
    @Req() req: any,
    @Body() body: { current_password: string; new_password: string },
  ) {
    const userId = req.user?.id || req.user?.sub;
    return this.auth.changePassword(userId, body.current_password, body.new_password);
  }
}