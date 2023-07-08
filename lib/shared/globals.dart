import 'package:flutter/material.dart';
import 'package:mychats/main.dart';
import 'package:mychats/services/auth_service.dart';

String? getRoomId(String theirPhoneNumber){
  if(AuthService().phoneNumber == null)return null;
  String myPhoneNumber = AuthService().phoneNumber!;

  String roomId;

  if(myPhoneNumber.compareTo(theirPhoneNumber) < 0){
    roomId = myPhoneNumber+theirPhoneNumber;
  }
  else{
    roomId = theirPhoneNumber+myPhoneNumber;
  }

  return roomId;
}

void showSnackbar(String message){
  scaffoldMessangerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message))
  );
}