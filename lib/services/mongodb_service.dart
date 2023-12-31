import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mychats/models/my_chats_user.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/endpoints.dart';

class MongoDBService{
  final _dio = ApiService().dio;

  Future<Map> signinUser(MyChatsUser myUser)async{
    try {
      Response res = await _dio.put(
        '${Endpoints.baseUrl}/user/signin',
        data: jsonEncode({
          'fullName': myUser.fullName,
          'firebaseId': myUser.firebaseId,
          'phoneNumber': myUser.phoneNumber,
          'about': myUser.about,
          'profilePicUrl': myUser.profilePicUrl,
          'contactInfo': myUser.contactInfo,
          'groups': []
        })
      );
      
      if(res.statusCode == 200){
        return {
          'accessToken': res.data['accessToken'].toString(),
        };
      }

      return Future.error(res.statusMessage.toString());
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<String> saveMessages(Map roomData)async{
    try {
      Response res = await _dio.put(
        '${Endpoints.baseUrl}/message/save_messages',
        data: jsonEncode(roomData)
      );

      if(res.statusCode == 200)return res.data;

      return Future.error(res.statusMessage.toString());
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String roomId)async{
    try {
      String myPhoneNumber = AuthService().phoneNumber!;
      Response res = await _dio.get(
        '${Endpoints.baseUrl}/message/of/$roomId/$myPhoneNumber'
      );

      if(res.statusCode == 200){
        final msgs = res.data['messageList'];
        
        List<Map<String, dynamic>> m = [];
        for(int i = 0; i < msgs.length; i++){
          m.add({
            'body': msgs[i]['body'] as String,
            'sentBy': msgs[i]['sentBy'] as String,
            'sendingTime': msgs[i]['sendingTime'] as String,
            'isFile': msgs[i]['isFile'] as bool,
            'roomId': roomId
          });
        }
        
        return m;
      }
      else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }
}