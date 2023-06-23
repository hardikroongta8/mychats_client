import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/constants.dart';

class ChatService{
  Future<List> getActiveChats()async{
    final String firebaseId = AuthService().firebaseId!;

    http.Response res = await http.get(
      Uri.parse('${uri}user/active_rooms/$firebaseId'),
      headers: {'Content-Type' : 'application/json'}
    );

    if(res.statusCode == 200){
      log('Received active rooms');
      Map m = jsonDecode(res.body);
      return m['activeRooms'];
    }
    else{
      log(res.body);
      return [];
    }
  }
}