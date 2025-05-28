import { Injectable } from '@nestjs/common';
import { ProductDto } from '../../infrastructure/dtos/product.dto';
import { IProductService } from '../../domain/service/IProduct.service';

@Injectable()
export class CreateProductUseCase {
  constructor(private readonly productService: IProductService) {}

  public async run(dto: ProductDto, userId: string) {
    try {
      console.log('CreateProductUseCase.run - dto:', dto, 'userId:', userId);
      const result = await this.productService.create({
        ...dto,
        userId,
      });
      console.log('CreateProductUseCase.run - producto creado:', result);
      return result;
    } catch (exception: unknown) {
      console.error('Excepción atrapada en CreateProductUseCase:', exception);
      throw exception;
    }
  }
}
