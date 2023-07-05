import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mychats/models/my_chats_user.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/endpoints.dart';

class MongoDBService{
  Future<String> createUser(MyChatsUser myUser)async{
    try {
      Response res = await ApiService().putRequest(
        path: '${Endpoints.baseUrl}/user/create',
        data: jsonEncode({
          'fullName': myUser.fullName,
          'firebaseId': myUser.firebaseId,
          'phoneNumber': myUser.phoneNumber,
          'about': myUser.about,
          'contactInfo': myUser.contactInfo,
          'groups': []
        })
      );
      
      if(res.statusCode == 200)return res.data;

      throw Exception(res.statusMessage);
    }catch(e){
      throw Exception(e.toString());
    }
  }

  Future<String> saveMessages(Map roomData)async{
    try {
      Response res = await ApiService().putRequest(
        path: '${Endpoints.baseUrl}/message/save_messages',
        data: jsonEncode(roomData)
      );

      if(res.statusCode == 200)return res.data;

      throw Exception(res.statusMessage);
    }catch(e){
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, String>>> getMessages(String roomId)async{
    try {
      String myPhoneNumber = AuthService().phoneNumber!;
      Response res = await ApiService().getRequest(
        path: '${Endpoints.baseUrl}/message/of/$roomId/$myPhoneNumber'
      );

      if(res.statusCode == 200){
        final msgs = res.data['messageList'];
        List<Map<String, String>> m = [];
        for(int i = 0; i < msgs.length; i++){
          m.add({
            'body': msgs[i]['body'] as String,
            'sentBy': msgs[i]['sentBy'] as String,
            'sendingTime': msgs[i]['sendingTime'] as String,
            'roomId': roomId
          });
        }
        
        return m;
      }
      else{
        throw Exception(res.statusMessage);
      }
    }catch(e){
      throw Exception(e.toString());
    }
  }
}