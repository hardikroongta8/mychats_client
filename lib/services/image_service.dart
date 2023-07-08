import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:http_parser/http_parser.dart';

class ImageService{
  final Dio _dio = ApiService().dio;

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

  Future<String> uploadImage(File image)async{
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      'pic': await MultipartFile.fromFile(
        image.path, 
        filename: fileName,
        contentType: MediaType('image', 'png'),
      )
    });

    try {
      Response res = await _dio.post(
        '${Endpoints.baseUrl}/image/upload',
        data: formData
      );

      if(res.statusCode == 200){
        log('Image uploaded successfully');
        return res.data['imageUrl'].toString();
      }else{
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }
}