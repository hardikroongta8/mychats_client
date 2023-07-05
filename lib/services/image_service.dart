import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageService{
  Future<File?> pickImage(bool isCamera)async{
    try{
      final XFile? image = await ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);

      if(image == null)return null;
      final imageTemporary = File(image.path);
      return imageTemporary;
    } on PlatformException catch(e){
      log('Failed to pick image: $e');
      return null;
    }
  }
}