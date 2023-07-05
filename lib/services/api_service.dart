import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:mychats/interceptors/request_retrier.dart';
import 'package:mychats/interceptors/retry_interceptor.dart';
import 'package:mychats/shared/endpoints.dart';


// TODO: HANDLE INFINITE LOADING WHEN NO INTERNET
class ApiService{
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: Endpoints.getHeader()
    )
  );

  ApiService(){
    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: RequestRetrier(
          connectivity: Connectivity(),
          dio: dio
        ),
      ),
    );
  }

  Future<Response> getRequest({required String path}){
    return dio.get(path);
  }

  Future<Response> putRequest({required String path, required String data}){
    return dio.put(path, data: data);
  }
}