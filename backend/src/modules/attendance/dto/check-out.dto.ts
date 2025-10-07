import { IsNumber, IsOptional } from 'class-validator';

export class CheckOutDto {
  @IsOptional()
  @IsNumber()
  lat?: number;

  @IsOptional()
  @IsNumber()
  lng?: number;
}