import 'package:mychats/models/message.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhotoBlock extends StatelessWidget {
  final Photo photo;
  const PhotoBlock({required this.photo, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (photo.sentBy == AuthService().phoneNumber)
        ? Alignment.centerRight 
        : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.2
          ),
          decoration: BoxDecoration(
            color: photo.sentBy == AuthService().phoneNumber! 
              ? Colors.red[900]
              : const Color.fromRGBO(99, 66, 66, 1),
            borderRadius: BorderRadius.circular(12)
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Stack(
              children: [
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photo.body,
                        fit: BoxFit.contain,
                      ),
                    ),
                    //const Text('lkj', style: TextStyle(color: Colors.transparent),)
                  ],
                ),
                Positioned(
                  bottom: 2,
                  right: 5,
                  child: Text(
                    DateFormat("HH:mm").format(DateTime.parse(photo.sendingTime)),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}