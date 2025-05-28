import { IProduct } from '../../domain/interfaces/IProduct';

export class Product implements IProduct {
  id: string;
  name: string;
  brand: string;
  categories: string[];
  price: number;
  userId: string;
  createdAt: string;
}
