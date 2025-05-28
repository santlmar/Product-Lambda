import { IProduct } from 'src/lib/product/domain/interfaces/IProduct';
import { ICategoryAssing } from '../../domain/interfaces/ICategory';
import { IsNotEmpty, IsString, ValidateNested } from 'class-validator';
import { ProductDto } from 'src/lib/product/infrastructure/dtos/product.dto';
import { Type } from 'class-transformer';

export class CategoryDto implements ICategoryAssing {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => ProductDto)
  products: IProduct[];
}
