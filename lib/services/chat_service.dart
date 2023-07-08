import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/endpoints.dart';

class ChatService{
  final _dio = ApiService().dio;

  Future<Map> getUserInfo(String phoneNumber)async{
    try {
      Response res = await _dio.get(
        '${Endpoints.baseUrl}/user/get_user_info/$phoneNumber'
      );

      if(res.statusCode == 200){
        return res.data;
      }else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<String?> getUserAbout(String phoneNumber)async{
    try {
      Response res = await _dio.get(
        '${Endpoints.baseUrl}/user/get_user_about/$phoneNumber'
      );

      if(res.statusCode == 200){
        return res.data['about'];
      }else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<String?> getUserDp(String phoneNumber)async{
    try {
      Response res = await _dio.get(
        '${Endpoints.baseUrl}/user/get_user_dp/$phoneNumber'
      );

      if(res.statusCode == 200){
        return res.data['profilePicUrl'];
      }else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<List> getActiveChats()async{
    try{
      final String firebaseId = AuthService().firebaseId!;

      Response res = await _dio.get(
        '${Endpoints.baseUrl}/user/active_rooms/$firebaseId'
      );

      log('response received');

      if(res.statusCode == 200){
        log('Received active rooms');
        Map m = res.data;
        
        final chats = m['activeRooms'];
        chats.sort((a, b) => -1*(a['lastActive'].toString()).compareTo(b['lastActive'].toString()));

        return chats;
      }
      else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }
}