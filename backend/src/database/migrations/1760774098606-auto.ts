import { MigrationInterface, QueryRunner } from 'typeorm';

export class Auto1760774098606 implements MigrationInterface {
  name = 'Auto1760774098606';
  public async up(_: QueryRunner): Promise<void> {}
  public async down(_: QueryRunner): Promise<void> {}
}
