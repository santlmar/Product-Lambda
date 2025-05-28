import { NotFoundError } from 'rxjs';
import { ICategoryService } from '../../domain/service/ICategory.service';

export class GetAllCategoriesUseCase {
  constructor(private readonly categoryService: ICategoryService) {}

  async run() {
    const categories = await this.categoryService.getAll();
    if (!categories) {
      throw new NotFoundError('Categories not found');
    }
    return categories;
  }
}
