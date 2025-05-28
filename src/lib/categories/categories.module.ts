import { Module } from '@nestjs/common';
import { CategoryController } from './infrastructure/controller/category.controller';
import { GetAllCategoriesUseCase } from './application/getAll/GetAllCategories.useCase';

@Module({
  controllers: [CategoryController],
  providers: [GetAllCategoriesUseCase],
  exports: [GetAllCategoriesUseCase],
})
export class CategoryModule {}
