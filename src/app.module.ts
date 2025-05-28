import { Module } from '@nestjs/common';
import { ProductModule } from './lib/product/product.module';
import { CoreModule } from './core/core.module';

@Module({
  imports: [CoreModule, ProductModule],
  controllers: [],
  providers: [],
})
export class AppModule {}
