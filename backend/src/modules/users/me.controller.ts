import { Body, Controller, Get, Patch, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users.service';

@Controller('me')
@UseGuards(AuthGuard('jwt'))
export class MeController {
  constructor(private readonly users: UsersService) {}

  @Get()
  async getMe(@Req() req: any) {
    const userId = req.user?.id || req.user?.sub;
    const u = await this.users.findById(userId);
    return this.users.toSafeUser(u!);
  }

  @Patch('identity')
  async updateIdentity(
    @Req() req: any,
    @Body() body: { full_name?: string; username?: string },
  ) {
    const userId = req.user?.id || req.user?.sub;
    const updated = await this.users.updateIdentity(userId, body);
    return this.users.toSafeUser(updated);
  }

  @Patch('phone')
  async updatePhone(
    @Req() req: any,
    @Body() body: { phone: string },
  ) {
    const userId = req.user?.id || req.user?.sub;
    const updated = await this.users.updatePhone(userId, body.phone);
    return this.users.toSafeUser(updated);
  }
}
