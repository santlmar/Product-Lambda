import {
  Controller,
  Get,
  HttpStatus,
  Inject,
  Param,
  ParseIntPipe,
} from '@nestjs/common';
import { ResponseAdapter } from './../../../../common/response-adapter/response.adapter';
import { HTTP_RESPONSE_MESSAGE } from './../../../../common/constants/http-message';
import { GetAllCategoriesUseCase } from '../../application/getAll/GetAllCategories.useCase';

@Controller('category')
export class CategoryController {
  constructor(
    @Inject('GetAllCategoriesUseCase')
    private readonly getAllCategoriesUseCase: GetAllCategoriesUseCase,
  ) {}

  @Get()
  public async getAllCategory() {
    const response = await this.getAllCategoriesUseCase.run();
    return ResponseAdapter.set(
      HttpStatus.OK,
      response,
      HTTP_RESPONSE_MESSAGE.HTTP_200_OK,
      true,
    );
  }
}
