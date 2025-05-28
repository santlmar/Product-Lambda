import { ICategory } from '../interfaces/ICategory';

export interface ICategoryService {
  getAll: () => Promise<ICategory[]>;
}
