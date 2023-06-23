import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mychats/models/my_chats_user.dart';
import 'package:mychats/shared/constants.dart';

class MongoDBService{
  Future<String> createUser(MyChatsUser myUser)async{
    http.Response res = await http.put(
      Uri.parse('${uri}user/create'),
      body: jsonEncode({
        'fullName': myUser.fullName,
        'firebaseId': myUser.firebaseId,
        'phoneNumber': myUser.phoneNumber,
        'about': myUser.about,
        'contactInfo': myUser.contactInfo,
        'groups': []
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    return res.body;
  }

  Future<String> sendMessage(Map roomData)async{
    http.Response res = await http.put(
      Uri.parse('${uri}message/send_message'),
      body: jsonEncode(roomData),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    return res.body;
  }

  Future<List> getMessages(String roomId)async{
    http.Response res = await http.get(
      Uri.parse('${uri}message/of/$roomId'),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if(res.statusCode == 200){
      final Map data = jsonDecode(res.body);
      final m = data['messageList'];
      
      return m;
    }
    else{
      log(res.body);
      return [];
    }
  }
}