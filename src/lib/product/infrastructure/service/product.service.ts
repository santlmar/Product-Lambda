import { Inject, Injectable } from '@nestjs/common';
import { IProductService } from '../../domain/service/IProduct.service';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { ProductDto } from '../dtos/product.dto';
import { v4 as uuidv4 } from 'uuid';
import { IProduct } from '../../domain/interfaces/IProduct';

@Injectable()
export class ProductService implements IProductService {
  constructor(
    @Inject('DYNAMODB_CLIENT')
    private readonly dynamoClient: DynamoDBDocumentClient,
  ) {}

  async create(productDto: ProductDto & { userId: string }): Promise<IProduct> {
    try {
      // Validar userId
      if (!productDto.userId) {
        throw new Error('userId no puede ser vacío');
      }

      // Guardar en DynamoDB con uuid
      const dynamoProduct = {
        uuid: uuidv4(),
        ...productDto,
        createdAt: new Date().toISOString(),
      };

      await this.dynamoClient.send(
        new PutCommand({
          TableName: process.env.PRODUCTS_TABLE, // Usa la variable de entorno
          Item: dynamoProduct,
        }),
      );

      // Responder con id (mapeando uuid a id)
      return {
        id: dynamoProduct.uuid,
        name: dynamoProduct.name,
        brand: dynamoProduct.brand,
        categories: dynamoProduct.categories,
        price: dynamoProduct.price,
        userId: dynamoProduct.userId,
        createdAt: dynamoProduct.createdAt,
      };
    } catch (error) {
      throw error;
    }
  }
}
