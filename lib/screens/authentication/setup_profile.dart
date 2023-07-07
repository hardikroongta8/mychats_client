import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychats/services/image_service.dart';
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
  File? image;

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

  void pickImage(bool isCamera)async{
    File? img = await ImageService().pickImage(isCamera);
    setState(() {
      if(img!=null)image=img;
    });
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
                GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                      context: context, 
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        height: screenHeight*0.15,
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                pickImage(true);
                              },
                              child: const Text('Capture an image')
                            ),
                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                                pickImage(false);
                              },
                              child: const Text('Pick from gallery')
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: screenWidth * 0.35,
                    backgroundImage: image == null ? null : FileImage(image!),
                  ),
                ),
                SizedBox(
                  height: screenHeight*0.08,
                ),
                SizedBox(
                  width: 0.8*screenWidth,
                  child: TextFormField(
                    controller: fullNameController,
                    textCapitalization: TextCapitalization.words,
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
                    List<int>? imageData;

                    if(image!=null)imageData = await image!.readAsBytes();

                    MyChatsUser myUser = MyChatsUser(
                      firebaseId: user!.uid, 
                      phoneNumber: user.phoneNumber!,
                      fullName: fullNameController.text.trim(), 
                      contactInfo: contactInfo,
                      about: aboutController.text,
                      profilePicData: imageData == null ? null : base64Encode(imageData)
                    );

                    Map tokens = await MongoDBService().signinUser(myUser);

                    await SharedPrefs.setIsProfileCreated(true);
                    await SharedPrefs.setAccessToken(tokens['accessToken']);
                    await SharedPrefs.setRefreshToken(tokens['refreshToken']);                    

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