import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mychats/services/shared_prefs.dart';
import 'package:mychats/shared/auth_functions.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:mychats/shared/globals.dart';


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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          log('INSIDE REQUEST');
          String accessToken = await SharedPrefs.getAccessToken() ?? ' ';
          options.headers['authorization'] = 'Bearer $accessToken';
          handler.next(options);
        },
        onError: (e, handler) async {
          log('INSIDE ERROR');
          Response? res = e.response;
          if(res != null && (res.statusCode == 403 || res.statusCode == 401)){
            log('INSIDE 401 or 403');
            String? accessToken = await SharedPrefs.getAccessToken();
            if(accessToken == null){
              showSnackbar('Login to continue!');
            }
            else{
              bool couldRegenerate = await AuthFunctions().regenerateAccessToken();
              if(couldRegenerate){
                return handler.resolve(await AuthFunctions().retryRequest(res));
              }else{
                showSnackbar('Your session has expired! Login again.');
              }
            }
          }
          else if(res != null && (res.statusCode == 400)){
            log('INSIDE OTHER');
            log(res.toString());
            showSnackbar(res.data['message']);
          }
          else{
            return handler.next(e);
          }
        },
      )
    );
  }
}