import { ICategory } from 'src/lib/categories/domain/interfaces/ICategory';

export interface IProduct {
  id: string;
  name: string;
  brand: string;
  categories: string[];
  price: number;
  userId: string;
  createdAt: string;
}

export interface IProductCreate extends Omit<IProduct, 'id'> {}
