import 'package:mychats/screens/chats/personal_chat.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/services/chat_service.dart';
import 'package:mychats/services/my_contact_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:mychats/shared/loading.dart';
import 'package:mychats/widgets/profile_pic.dart';

class ContactScreen extends StatefulWidget {
  final SessionService session;
  const ContactScreen({required this.session, super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  late Future<List> contactInfo;

  @override
  void initState() {
    super.initState();
    contactInfo = MyContactService().getContactsFromDB();
    if(mounted){
      setState(() {
        contactInfo = MyContactService().fetchContacts();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('Select Contact'),
        actions: [
          IconButton(
            onPressed: (){
              AuthService().signOut();
              Navigator.pop(context);
            }, 
            icon: const Icon(Icons.logout_rounded)
          )
        ],
      ),
      body: FutureBuilder(
        future: contactInfo,
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return const Loading();
          }
          else if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.data}'),);
          }
          MyContactService().updateContactInfoOnDB(snapshot.data!);
          return ListView.builder(
            itemBuilder: (context, index) => ListTile(
              onTap: (){
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalChat(
                      phoneNumber: snapshot.data![index]['phoneNumber'],
                      displayName: snapshot.data![index]['displayName'],
                      session: widget.session,

                    )
                  )
                );
              },
              leading: ProfilePic(
                phoneNumber: snapshot.data![index]['phoneNumber'],
                radius: 30,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              title: Text(snapshot.data![index]['displayName']),
              subtitle: FutureBuilder(
                future: ChatService().getUserAbout(snapshot.data![index]['phoneNumber']),
                builder: (context, snapshot) {
                  if(!snapshot.hasData){
                    return const Text('');
                  }else if(snapshot.hasError){
                    return Text(snapshot.error.toString());
                  }else{
                    return Text(snapshot.data ?? '');
                  }
                },
              ),
            ),
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
