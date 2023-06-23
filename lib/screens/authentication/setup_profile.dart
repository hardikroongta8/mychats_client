import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychats/services/my_contact_service.dart';
import 'package:mychats/services/shared_prefs.dart';
import 'package:mychats/shared/loading.dart';
import 'package:mychats/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:mychats/services/mongodb_service.dart';
import 'package:mychats/models/my_chats_user.dart';

class SetupProfile extends StatefulWidget {
  const SetupProfile({super.key});

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  bool isLoading = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController aboutController = TextEditingController(text: 'Hey there! I am using MyChats.');

  List<Map> contactInfo = [];

  void getContacts()async{
    final contactList = await MyContactService().fetchContacts();
    if(mounted){
      setState((){
        contactInfo = contactList;
      });
      
    }
  }

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  @override
  Widget build(BuildContext context) {
    final boolProvider = Provider.of<BoolProvider>(context);
    final user = Provider.of<User?>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return isLoading ? const Loading() : Scaffold(
      appBar: AppBar(
        title: const Text('Setup your profile'),
      ),
      body: Center(
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenHeight*0.08,
                ),
                CircleAvatar(
                  radius: screenWidth * 0.35,
                ),
                SizedBox(
                  height: screenHeight*0.08,
                ),
                SizedBox(
                  width: 0.8*screenWidth,
                  child: TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      fillColor: Colors.white10,
                      filled: true,
                      icon: Icon(Icons.person_rounded, size: 32),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight*0.05,
                ),
                SizedBox(
                  width: 0.8*screenWidth,
                  child: TextFormField(
                    controller: aboutController,
                    decoration: const InputDecoration(
                      hintText: 'About',
                      fillColor: Colors.white10,
                      filled: true,
                      icon: Icon(Icons.info_outline_rounded, size: 32,),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight*0.08,
                ),
                ElevatedButton(
                  onPressed: ()async{
                    setState(() {
                      isLoading = true;
                    });

                    MyChatsUser myUser = MyChatsUser(
                      firebaseId: user!.uid, 
                      phoneNumber: user.phoneNumber!,
                      fullName: fullNameController.text.trim(), 
                      contactInfo: contactInfo,
                      about: aboutController.text
                    );

                    await MongoDBService().createUser(myUser);

                    await SharedPrefs().setIsProfileCreated(true);

                    boolProvider.setValue(true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red[900]),
                    foregroundColor: MaterialStateProperty.all(Colors.white70)
                  ),
                  child: const Text('Next')
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}