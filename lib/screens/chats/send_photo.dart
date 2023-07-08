import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mychats/services/image_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class SendPhoto extends StatelessWidget {
  final File image;
  final String phoneNumber;
  final SessionService sessionService;
  const SendPhoto({required this.image, required this.phoneNumber, required this.sessionService, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(
              image,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 10,
            child: GestureDetector(
              onTap: ()async{
                Navigator.pop(context);
                log('Clicked');
                File compressedImage = await FlutterNativeImage.compressImage(image.path, quality: 25);
                String imageUrl = await ImageService().uploadImage(compressedImage);
                log('uploaded');
                sessionService.sendMessage(
                  body: imageUrl,
                  isFile: true,
                  theirPhoneNumber: phoneNumber
                );
              },
              child: const CircleAvatar(
                radius: 25,
                child: Center(child: Icon(Icons.send, size: 28,),)
              )
            ),
          ),
        ],
      ),
    );
  }
}