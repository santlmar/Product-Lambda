import {
  Body,
  Controller,
  Headers,
  HttpStatus,
  Inject,
  Post,
  UnauthorizedException,
} from '@nestjs/common';
import { CreateProductUseCase } from '../../application/createProduct/CreateProduct.useCase';
import { ProductDto } from '../dtos/product.dto';
import { ResponseAdapter } from 'src/common/response-adapter/response.adapter';
import { HTTP_RESPONSE_MESSAGE } from 'src/common/constants/http-message';
import { JwtProvider } from 'src/shared/providers/jwt.provider/jwt.provider';

@Controller('products')
export class ProductController {
  constructor(
    @Inject('CreateProductUseCase')
    private readonly createProductUseCase: CreateProductUseCase,
    private readonly jwtProvider: JwtProvider,
  ) {}

  @Post()
  public async create(
    @Body() productDto: ProductDto,
    @Headers('authorization') authHeader: string,
  ) {
    try {
      if (!authHeader) {
        throw new UnauthorizedException('Token no proporcionado');
      }
      const token = authHeader.split(' ')[1];
      const decoded = this.jwtProvider.verifyToken(token);
      const userId = decoded.uuid;

      if (!userId) {
        throw new UnauthorizedException(
          'Token inválido: userId/sub no presente',
        );
      }

      const newProduct = await this.createProductUseCase.run(
        productDto,
        userId,
      );

      return ResponseAdapter.set(
        HttpStatus.CREATED,
        newProduct,
        'Producto registrado exitosamente',
        true,
      );
    } catch (error) {
      throw error;
    }
  }
}
