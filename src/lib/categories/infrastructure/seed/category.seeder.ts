import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
} from '@aws-sdk/lib-dynamodb';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { Category } from '../entity/category.entity';

const dynamoClient = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: process.env.AWS_REGION }),
);

export const seedCategories = async () => {
  const categories: Omit<Category, 'id' | 'products'>[] = [
    { name: 'Tecnología' },
    { name: 'Hogar' },
    { name: 'Deportes' },
    { name: 'Ropa' },
    { name: 'Libros' },
  ];

  for (const cat of categories) {
    // Busca si ya existe la categoría por nombre
    const getParams = {
      TableName: process.env.CATEGORIES_TABLE,
      Key: { name: cat.name },
    };
    const exists = await dynamoClient.send(new GetCommand(getParams));
    if (!exists.Item) {
      const category: Category = {
        id: crypto.randomUUID(),
        name: cat.name,
        products: [],
      };
      await dynamoClient.send(
        new PutCommand({
          TableName: process.env.CATEGORIES_TABLE,
          Item: category,
        }),
      );
    }
  }

  console.log('✔ Categorías sembradas');
};
