import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
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

  final formKey = GlobalKey<FormState>();

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
    final boolProvider = Provider.of<IsProfileCreatedProvider>(context);
    final user = Provider.of<User?>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return isLoading ? const Loading() : Scaffold(
      appBar: AppBar(
        title: const Text('Setup your profile'),
        elevation: 1,
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
                    FocusManager.instance.primaryFocus!.unfocus();
                    showModalBottomSheet(
                      context: context, 
                      builder: (context) => SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                                pickImage(true);
                              },
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.pink,
                                child: Icon(Icons.camera_alt_rounded, size: 32,),
                              ),
                            ),
                            GestureDetector(
                              onTap: ()async{
                                Navigator.pop(context);
                                pickImage(false);
                              },
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.purple,
                                child: Icon(Icons.image_rounded, size: 32,),
                              ),
                            ),                                    
                          ],
                        ),
                      )
                    );
                  },
                  child: CircleAvatar(
                    radius: screenWidth * 0.35,
                    child: image == null 
                    ? Icon(
                      Icons.person_rounded, 
                      size:  1.3*0.35*screenWidth,
                    ): CircleAvatar(
                      radius: screenWidth * 0.35,
                      backgroundImage: FileImage(image!),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight*0.08,
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 0.8*screenWidth,
                        child: TextFormField(
                          controller: fullNameController,
                          
                          validator: (value) {
                            if(value == null || value.isEmpty){
                              return 'Please enter your name.';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Full Name',
                            fillColor: Colors.white10,
                            filled: true,
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
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight*0.08,
                      ),
                      ElevatedButton(
                        onPressed: ()async{
                          if(formKey.currentState!.validate()){
                            setState(() {
                              isLoading = true;
                            });
                            
                            String? imageUrl;
                            if(image != null){
                              File compressedImage = await FlutterNativeImage.compressImage(image!.path, quality: 25);
                              imageUrl = await ImageService().uploadImage(compressedImage);
                            }
                            
                            log('Image url: $imageUrl');
                            
                            MyChatsUser myUser = MyChatsUser(
                              firebaseId: user!.uid, 
                              phoneNumber: user.phoneNumber!,
                              fullName: fullNameController.text.trim(), 
                              contactInfo: contactInfo,
                              about: aboutController.text,
                              profilePicUrl: imageUrl
                            );
                            
                            Map tokens = await MongoDBService().signinUser(myUser);
                            
                            await SharedPrefs.setIsProfileCreated(true);
                            await SharedPrefs.setAccessToken(tokens['accessToken']);                   
                            
                            boolProvider.setValue(true);
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blue[800]),
                          foregroundColor: MaterialStateProperty.all(Colors.white70)
                        ),
                        child: const Text('Next')
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}