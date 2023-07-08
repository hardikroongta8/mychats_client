import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mychats/services/shared_prefs.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:mychats/shared/header_keys.dart';

class AuthFunctions{
  Future<bool> regenerateAccessToken()async{
    String cookieFormatted = await SharedPrefs.getCookieFormatted() ?? '';
    try {
      Dio dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        )
      );

      Response res = await dio.post(
        '/user/refresh_token',
        options: Options(headers: {'cookie': cookieFormatted}),
      );

      if(res.statusCode == 200){
        await SharedPrefs.setAccessToken(res.data['accessToken']);
        return true;
      }
      else{
        // return Future.error(res.statusMessage.toString());
        log(res.statusMessage.toString());
        return false;
      }
    }catch(e){
      // return Future.error(e.toString());
      log(e.toString());
      return false;
    }
  }  

  Future<Response> retryRequest(Response res)async{
    RequestOptions requestOptions = res.requestOptions;
    String accessToken = await SharedPrefs.getAccessToken() ?? ' ';
    requestOptions.headers[HeaderKeys.authorization] = 'Bearer $accessToken';

    Options options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers
    );

    Dio retryDio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5)
      )
    );

    if (requestOptions.method == "GET") {
      return retryDio.request(
        requestOptions.path,
        queryParameters: requestOptions.queryParameters, 
        options: options
      );
    }else{
      return retryDio.request(requestOptions.path,
        queryParameters: requestOptions.queryParameters,
        data: requestOptions.data,
        options: options
      );
    }
  }
}