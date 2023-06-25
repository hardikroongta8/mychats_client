import 'dart:convert';
import 'dart:developer';
import 'package:contacts_service/contacts_service.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mychats/shared/constants.dart';
import 'package:http/http.dart' as http;
import 'package:mychats/shared/globals.dart';

class MyContactService{
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
              'roomId': roomId(phoneNumber)
            });
          }
        }
      }
    }

    return contactInfo;
  }

  Future updateContactInfoOnDB()async{
    List contactInfo = await fetchContacts();

    String firebaseId = AuthService().firebaseId!;

    http.Response res = await http.put(
      Uri.parse('${uri}user/update_contact_info'),
      body: jsonEncode({
        'contactInfo': contactInfo,
        'firebaseId': firebaseId
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    );

    if(res.statusCode == 200){
      log(res.body);
    }
    else{
      log('Error updating contact info on database');
      log(res.body);
    }
  }

  Future<List> getContactsFromDB()async{
    final String firebaseId = AuthService().firebaseId!;

    http.Response res = await http.get(
      Uri.parse('${uri}user/get_contact_info/$firebaseId'),
      headers: {'Content-Type': 'application/json'}
    );

    final contactInfo = jsonDecode(res.body)['contactInfo'];

    return contactInfo;
  }
}