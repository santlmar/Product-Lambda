import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDBDocumentClient, PutCommand } from '@aws-sdk/lib-dynamodb';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { JwtService } from '@nestjs/jwt';

const dynamoClient = DynamoDBDocumentClient.from(
  new DynamoDBClient({ region: process.env.AWS_REGION }),
);

interface Product {
  id: string;
  name: string;
  brand: string;
  categories: string[];
  price: number;
  userId: string;
  createdAt: string;
}

const jwtService = new JwtService({
  secret: process.env.JWT_SECRET || 'clave_secreta',
});

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  // 1. Verificar token JWT
  const token = event.headers?.Authorization?.split(' ')[1];
  if (!token) {
    return {
      statusCode: 401,
      body: JSON.stringify({ message: 'Token no proporcionado' }),
    };
  }

  let userId: string;
  try {
    const decoded = jwtService.verify(token) as { sub: string };
    userId = decoded.sub;
  } catch (error) {
    return {
      statusCode: 403,
      body: JSON.stringify({ message: 'Token inválido o expirado' }),
    };
  }

  // 2. Validar cuerpo de la petición
  if (!event.body) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Body vacío' }),
    };
  }

  const { name, brand, categories, price } = JSON.parse(event.body);
  if (!name || !brand || !categories || !price) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Datos incompletos' }),
    };
  }

  // 3. Crear producto en DynamoDB
  const product: Product = {
    id: crypto.randomUUID(),
    name,
    brand,
    categories,
    price: Number(price),
    userId,
    createdAt: new Date().toISOString(),
  };

  try {
    await dynamoClient.send(
      new PutCommand({
        TableName: process.env.PRODUCTS_TABLE,
        Item: product,
      }),
    );

    return {
      statusCode: 201,
      body: JSON.stringify({
        message: 'Producto creado exitosamente',
        data: product,
      }),
    };
  } catch (error) {
    console.error('Error en DynamoDB:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Error al crear el producto' }),
    };
  }
};
