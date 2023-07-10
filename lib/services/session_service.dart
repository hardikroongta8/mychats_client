import 'package:mychats/services/auth_service.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:developer';
import 'package:mychats/shared/globals.dart';

class SessionService{
  late io.Socket socket;
  
  SessionService(){
    socket = io.io(
      Endpoints.baseUrl,
      io.OptionBuilder().setTransports(['websocket']).build()
    );

    socket.onConnect((data){log('Connection established with socket');});
    socket.onConnectError((data) => log('Socket connection error: $data'));
    socket.onDisconnect((data) => log('Disconnected from socket'));
  }

  void joinMyRoom(){
    if(AuthService().phoneNumber == null){
      disconnectSocket();
      return;
    }
    socket.emit('joinRoom', {
      'roomId': AuthService().phoneNumber!
    });
  }

  void leaveMyRoom(){
    if(AuthService().phoneNumber == null){
      disconnectSocket();
      return;
    }
    socket.emit('leaveRoom', {
      'roomId': AuthService().phoneNumber!
    });
  }

  void disconnectSocket(){
    socket.emit('disconnectSocket');
  }

  void joinPersonalRoom(String theirPhoneNumber){
    socket.emit('joinRoom', {
      'roomId': getRoomId(theirPhoneNumber)
    });
  }

  void leaveRoom(String theirPhoneNumber){
    socket.emit('leaveRoom', {
      'roomId': getRoomId(theirPhoneNumber)
    });
  }

  void sendMessage({required String body, bool? isFile, required String theirPhoneNumber}){
    if(AuthService().phoneNumber == null){
      disconnectSocket();
      return;
    }
    socket.emit('sendMessage', {
      'roomId': getRoomId(theirPhoneNumber),
      'body': body,
      'isFile': isFile ?? false,
      'sendingTime': DateTime.now().toString(),
      'sentBy': AuthService().phoneNumber!
    });
  }

  void typing(String theirPhoneNumber){
    socket.emit('typing', {
      'roomId': getRoomId(theirPhoneNumber)
    });
  }
}