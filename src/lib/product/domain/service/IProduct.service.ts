import { ProductDto } from '../../infrastructure/dtos/product.dto';
import { IProduct } from '../interfaces/IProduct';

export interface IProductService {
  create: (productDto: ProductDto & { userId: string }) => Promise<IProduct>;
}
