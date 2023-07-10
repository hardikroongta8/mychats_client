import 'package:mychats/models/message.dart';
import 'package:mychats/screens/chats/photo_viewer.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhotoBlock extends StatelessWidget {
  final Photo photo;
  final String displayName;
  const PhotoBlock({required this.displayName, required this.photo, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: (photo.sentBy == AuthService().phoneNumber)
        ? Alignment.centerRight 
        : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus!.unfocus();
          Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => PhotoViewer(photo: photo, displayName: displayName,)
            )
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.7,
              minWidth: screenWidth * 0.1,
              minHeight: screenWidth * 0.1,
              maxHeight: screenWidth * 0.8,
            ),
            decoration: BoxDecoration(
              color: photo.sentBy == AuthService().phoneNumber! 
                ? Colors.blue[800]
                : Colors.white10,
              borderRadius: BorderRadius.circular(16)
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 1,
                            minWidth: 1,
                          ),
                          child: Image.network(
                            photo.body,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) => Center(child: child,),
                            loadingBuilder: (context, child, loadingProgress) => Center(child: child,),
                          ),
                        ),
                      ),
                    ),
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
      ),
    );
  }
}