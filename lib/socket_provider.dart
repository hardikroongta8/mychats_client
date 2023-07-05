import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mychats/services/session_service.dart';

class SocketProvider extends ChangeNotifier{
  late SessionService session;
  bool listenersPresent = false;

  void createSessionInstance(){
    session = SessionService();
  }

  void setupInitialListeners(Function refreshActiveChats){
    session.joinMyRoom();
    session.socket.on('refreshView', (data){
      log('refreshView');
      refreshActiveChats();
    });
    listenersPresent = true;
    notifyListeners();
  }

  void clearAllListeners(){
    session.socket.clearListeners();
    listenersPresent = false;
    notifyListeners();
  }
}