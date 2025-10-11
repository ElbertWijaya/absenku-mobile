import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QrCode } from '../../entities/qr-code.entity';

@Injectable()
export class QrService {
  constructor(
    private readonly jwt: JwtService,
    @InjectRepository(QrCode) private readonly qrRepo: Repository<QrCode>,
  ) {}

  private todayStr(d = new Date()) {
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }

  async getActive() {
    const today = this.todayStr();
    let qr = await this.qrRepo.findOne({ where: { work_date: today } });
    if (!qr) return { active: false };
    return {
      active: true,
      token: qr.token,
      work_date: qr.work_date,
      expires_at: (qr.valid_until as any as Date).toISOString(),
    };
  }

  async issue() {
    const today = this.todayStr();
    let qr = await this.qrRepo.findOne({ where: { work_date: today } });
    if (qr) {
      return {
        active: true,
        token: qr.token,
        work_date: qr.work_date,
        expires_at: (qr.valid_until as any as Date).toISOString(),
        reused: true,
      };
    }
    const now = new Date();
    // valid until end of today (local time)
    const endOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1);
    const ttlSec = Math.max(60, Math.floor((endOfDay.getTime() - now.getTime()) / 1000));
    const exp = new Date(now.getTime() + ttlSec * 1000);
    const token = this.jwt.sign({ wd: today, typ: 'qr' }, { expiresIn: ttlSec });
    qr = this.qrRepo.create({ work_date: today, token, valid_until: exp as any });
    await this.qrRepo.save(qr);
    return {
      active: true,
      token: qr.token,
      work_date: qr.work_date,
      expires_at: (qr.valid_until as any as Date).toISOString(),
      reused: false,
    };
  }
}
