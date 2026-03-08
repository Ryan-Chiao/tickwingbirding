import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const port = process.env.APP_PORT ?? 3000;
  await app.listen(port);
  console.log(`Tickwing API is running on: http://localhost:${port}`);
}

bootstrap();
