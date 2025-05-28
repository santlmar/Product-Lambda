import { Injectable } from '@nestjs/common';
import { ProductDto } from '../../infrastructure/dtos/product.dto';
import { IProductService } from '../../domain/service/IProduct.service';

@Injectable()
export class CreateProductUseCase {
  constructor(private readonly productService: IProductService) {}

  public async run(dto: ProductDto, userId: string) {
    try {
      const result = await this.productService.create({
        ...dto,
        userId,
      });
      return result;
    } catch (exception: unknown) {
      throw exception;
    }
  }
}
