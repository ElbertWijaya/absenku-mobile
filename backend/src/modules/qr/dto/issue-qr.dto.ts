import { IsInt, IsOptional } from 'class-validator';

export class IssueQrDto {
  @IsOptional()
  @IsInt()
  location_id?: number;

  @IsOptional()
  @IsInt()
  shift_id?: number;
}