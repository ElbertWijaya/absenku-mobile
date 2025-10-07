import { IsNumber, IsOptional, IsString } from 'class-validator';

export class CheckInDto {
  @IsString()
  qr_token: string;

  @IsOptional()
  @IsNumber()
  lat?: number;

  @IsOptional()
  @IsNumber()
  lng?: number;
}