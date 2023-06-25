import 'package:mychats/screens/chats/personal_chat.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/services/my_contact_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:mychats/shared/loading.dart';

class ContactScreen extends StatefulWidget {
  final SessionService session;
  const ContactScreen({required this.session, super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List contactInfo = [];

  bool isLoading = true;

  void getAndUpdateContacts()async{
    if(mounted){
      final contactList = await MyContactService().fetchContacts();
      if(mounted){
        setState((){
          contactInfo = contactList;
          isLoading = false;
        });
      }
      MyContactService().updateContactInfoOnDB();
    }
  }

  void getContactsFromDB()async{
    final contactList = await MyContactService().getContactsFromDB();
    if(mounted){
      setState(() {
        contactInfo = contactList;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getContactsFromDB();
    getAndUpdateContacts();
  }
  
  @override
  Widget build(BuildContext context) {
    return isLoading ? const Loading() : Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: (){
              AuthService().signOut();
            }, 
            icon: const Icon(Icons.logout_rounded)
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalChat(
                  phoneNumber: contactInfo[index]['phoneNumber'],
                  displayName: contactInfo[index]['displayName'],
                  session: widget.session,

                )
              )
            );
          },
          leading: const CircleAvatar(
            radius: 30,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          title: Text(contactInfo[index]['displayName']),
          subtitle: Text(contactInfo[index]['phoneNumber']),
        ),
        itemCount: contactInfo.length,
      ),
    );
  }
}
