import { Injectable } from '@nestjs/common';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class JwtService {
  verifyToken(token: string): any {
    try {
      return jwt.verify(token, process.env.JWT_SECRET || 'clave_secreta');
    } catch (error) {
      throw new Error('Token inválido');
    }
  }
}
