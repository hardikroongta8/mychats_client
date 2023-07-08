import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:mychats/services/shared_prefs.dart';
import 'package:mychats/shared/auth_functions.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:mychats/shared/globals.dart';
import 'package:mychats/shared/header_keys.dart';


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
        onResponse: (res, handler) {
          res.headers.forEach((name, values)async{
            log('IN RESPONSE');
            if(name == HeaderKeys.setCookieHeader){
              Map<String, String> cookieMap = {};

              for(var c in values){
                String key = '';
                String value = '';

                key = c.substring(0, c.indexOf('='));
                value = c.substring(key.length+1, c.indexOf(';'));

                cookieMap[key] = value;
              }

              String cookieFormatted = '';
              cookieMap.forEach((key, value) => cookieFormatted += '$key=$value; ');

              await SharedPrefs.saveCookieFormatted(cookieFormatted);
            }
          });

          handler.next(res);
        },
        onError: (e, handler) async {
          log('INSIDE ERROR');
          Response? res = e.response;
          if(res != null && (res.statusCode == 401)){
            log('INSIDE 401');
            String? accessToken = await SharedPrefs.getAccessToken();
            if(accessToken == null){
              showSnackbar('Login to continue!');
            }
            else{
              log('NON NULL ACCESS TOKEN');
              bool couldRegenerate = await AuthFunctions().regenerateAccessToken();
              if(couldRegenerate){
                log('COULD REGENERATE');
                return handler.resolve(await AuthFunctions().retryRequest(res));
              }else{
                showSnackbar('Your session has expired! Login again.');
              }
            }
          }
          else if(res != null && (res.statusCode == 440)){
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