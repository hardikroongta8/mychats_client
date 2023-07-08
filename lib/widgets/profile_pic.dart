import 'package:flutter/material.dart';
import 'package:mychats/services/chat_service.dart';

class ProfilePic extends StatelessWidget {
  final String phoneNumber;
  final double? radius;
  const ProfilePic({required this.phoneNumber, this.radius, super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: FutureBuilder(
        future: ChatService().getUserDp(phoneNumber),
        builder: (context, snapshot2) {
          if(!snapshot2.hasData || snapshot2.data == null){
            return const Icon(Icons.person_rounded, size: 42,);  
          }else if(snapshot2.hasError){
            return CircleAvatar(radius: radius,);
          }else{
            return CircleAvatar(
              radius: radius,
              backgroundImage: NetworkImage(snapshot2.data!)
            );
          }                        
        },
      ),
    );
  }
}