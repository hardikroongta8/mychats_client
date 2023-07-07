import 'dart:convert';
import 'dart:developer';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:mychats/services/api_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mychats/shared/endpoints.dart';
import 'package:mychats/shared/globals.dart';

class MyContactService{
  final Dio _dio = ApiService().dio;

  Future<List<Map>> fetchContacts()async{
    if(await Permission.contacts.isDenied){
      await Permission.contacts.request();
    }

    List<Map> contactInfo = [];

    if(await Permission.contacts.isGranted){
      final contacts = await ContactsService.getContacts();
      for(int i = 0; i < contacts.length; i++){
        for(int j = 0; j < (contacts[i].phones ?? []).length; j++){
          String phoneNumber = contacts[i].phones![j].value.toString().replaceAllMapped(' ', (match) => '');

          if(phoneNumber.length == 10){
            phoneNumber = '+91$phoneNumber';
          }

          bool isPresent = false;

          for(int i = 0; i < contactInfo.length; i++){
            if(contactInfo[i]['phoneNumber'] == phoneNumber){
              isPresent = true;
            }
          }

          if(!isPresent){
            contactInfo.add({
              'phoneNumber': phoneNumber,
              'displayName': contacts[i].displayName,
              'roomId': getRoomId(phoneNumber)
            });
          }
        }
      }
    }

    return contactInfo;
  }

  Future updateContactInfoOnDB(List contactInfo)async{
    try{
      String firebaseId = AuthService().firebaseId!;

      Response res = await _dio.put(
        '${Endpoints.baseUrl}/user/update_contact_info',
        data: jsonEncode({
          'contactInfo': contactInfo,
          'firebaseId': firebaseId
        }),
      );

      if(res.statusCode == 200){
        log(res.data);
      }
      else{
        log('Error updating contact info on database');
        return Future.error(res.statusMessage.toString());
      }
    }catch(e){
      return Future.error(e.toString());
    }
  }

  Future<List> getContactsFromDB()async{
    try {
      final String firebaseId = AuthService().firebaseId!;

      Response res = await _dio.get(
        '${Endpoints.baseUrl}/user/get_contact_info/$firebaseId'
      );

      if(res.statusCode == 200){
        final contactInfo = res.data['contactInfo'];
        return contactInfo;
      }
      else {
        return Future.error(res.statusMessage.toString());
      }      
    }catch(e){
      return Future.error(e.toString());
    }
  }

}