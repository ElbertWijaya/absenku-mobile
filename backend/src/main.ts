import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const config = app.get(ConfigService);
  const port = Number(config.get('PORT', 3000));
  const enableSwagger = String(config.get('SWAGGER_ENABLE', 'true')) === 'true';

  // Security middleware
  app.use(helmet());

  // CORS
  const corsOrigins = String(config.get('CORS_ORIGINS', 'http://localhost:5173')).split(',');
  app.enableCors({
    origin: corsOrigins,
    credentials: true,
  });

  // Swagger
  if (enableSwagger) {
    const docConfig = new DocumentBuilder()
      .setTitle('Absensi API')
      .setDescription('API untuk aplikasi absensi (NestJS + MariaDB)')
      .setVersion('0.2.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, docConfig);
    SwaggerModule.setup('docs', app, document);
  }

  await app.listen(port, '0.0.0.0');
  // eslint-disable-next-line no-console
  console.log(`Server running on http://0.0.0.0:${port}`);
}

bootstrap();