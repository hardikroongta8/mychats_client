import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/endpoints.dart';

class ChatService{
  Future<List> getActiveChats()async{
    try{
      final String firebaseId = AuthService().firebaseId!;

      Response res = await ApiService().getRequest(
        path: '${Endpoints.baseUrl}/user/active_rooms/$firebaseId'
      );

      if(res.statusCode == 200){
        log('Received active rooms');
        Map m = res.data;
        
        final chats = m['activeRooms'];
        chats.sort((a, b) => -1*(a['lastActive'].toString()).compareTo(b['lastActive'].toString()));

        return chats;
      }
      else{
        throw Exception(res.statusMessage);
      }
    }catch(e){
      throw Exception(e.toString());
    }
  }
}