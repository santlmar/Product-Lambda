import { Module } from '@nestjs/common';
import { ProductController } from './infrastructure/controller/product.controller';
import { CreateProductUseCase } from './application/createProduct/CreateProduct.useCase';
import { IProductService } from './domain/service/IProduct.service';
import { ProductService } from './infrastructure/service/product.service';
import { DynamoDBModule } from 'src/utils/dynamodb.module';
import { JwtModule } from '@nestjs/jwt';
import { JwtProvider } from 'src/shared/providers/jwt.provider/jwt.provider';

@Module({
  imports: [
    DynamoDBModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'clave_secreta',
      signOptions: { expiresIn: '1h' },
    }),
  ],
  controllers: [ProductController],
  providers: [
    {
      provide: 'ProductService',
      useClass: ProductService,
    },
    {
      provide: 'CreateProductUseCase',
      useFactory: (productService: IProductService) =>
        new CreateProductUseCase(productService),
      inject: ['ProductService'],
    },
    JwtProvider,
  ],
  exports: ['ProductService'],
})
export class ProductModule {}
