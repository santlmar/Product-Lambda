import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { HTTP_RESPONSE_MESSAGE } from './../../../common/constants/http-message';
import { ResponseAdapter } from './../../../common/response-adapter/response.adapter';
import { CustomError } from 'src/common/domain/errors/CustomError';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    console.error('Excepción atrapada en HttpExceptionFilter:', exception);
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    switch (true) {
      case exception instanceof HttpException:
        return response
          .status(exception.getStatus())
          .json(
            ResponseAdapter.set(
              exception.getStatus(),
              null,
              exception.getResponse()?.['message'] ??
                exception.getResponse().toString(),
            ),
          );

      case exception instanceof CustomError:
        return response
          .status(exception.statusCode)
          .json(
            ResponseAdapter.set(exception.statusCode, null, exception.message),
          );
      default:
        return response
          .status(HttpStatus.INTERNAL_SERVER_ERROR)
          .json(
            ResponseAdapter.set(
              HttpStatus.INTERNAL_SERVER_ERROR,
              null,
              HTTP_RESPONSE_MESSAGE.HTTP_500_INTERNAL_SERVER_ERROR,
            ),
          );
    }
  }
}
