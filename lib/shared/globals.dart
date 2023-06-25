import 'package:mychats/services/auth_service.dart';

String roomId(String theirPhoneNumber){
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