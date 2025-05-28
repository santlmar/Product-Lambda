import { IProduct } from 'src/lib/product/domain/interfaces/IProduct';

export interface ICategory {
  id: number;
  name: string;
  products: IProduct[];
}

export interface ICategoryAssing extends Omit<ICategory, 'id'> {}
