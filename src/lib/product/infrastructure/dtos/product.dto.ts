import {
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsString,
  IsOptional,
} from 'class-validator';

export class ProductDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsString()
  brand: string;

  @IsNotEmpty()
  @IsArray()
  @IsString({ each: true })
  categories: string[];

  @IsNotEmpty()
  @IsNumber()
  price: number;
}
