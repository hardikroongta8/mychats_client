import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mychats/interceptors/request_retrier.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor{
  final RequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({required this.requestRetrier});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async{
    if(_shouldRetry(err)){
      try{
        Response res = await requestRetrier.scheduleRequestRetry(err.requestOptions);
        handler.resolve(res);
      }catch(e){
        throw Exception(e.toString());
      }
    }
  }

  bool _shouldRetry(DioException err){
    return err.type == DioExceptionType.unknown &&
    err.error != null &&
    err.error is SocketException;
  }
}