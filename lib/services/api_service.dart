import 'package:dio/dio.dart';
import 'package:mychats/shared/endpoints.dart';

class ApiService{
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: Endpoints.getHeader()
    )
  );

  ApiService();

  Future<Response> getRequest({required String path}){
    return dio.get(path);
  }

  Future<Response> putRequest({required String path, required String data}){
    return dio.put(path, data: data);
  }
}