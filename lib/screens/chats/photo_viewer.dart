import 'package:flutter/material.dart';
import 'package:mychats/models/message.dart';
import 'package:mychats/services/auth_service.dart';

class PhotoViewer extends StatelessWidget {
  final Photo photo;
  final String displayName;
  const PhotoViewer({
    required this.photo,
    required this.displayName,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(photo.sentBy == AuthService().phoneNumber ? 'You' : displayName),
        backgroundColor: Colors.black38,
        
      ),
      body: Center(child: Image.network(photo.body)),
    );
  }
}