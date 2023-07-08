import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mychats/screens/authentication/phone_verification.dart';
import 'package:mychats/screens/home.dart';
import 'package:mychats/screens/authentication/setup_profile.dart';
import 'package:mychats/services/shared_prefs.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final isProfileCreated = Provider.of<IsProfileCreatedProvider>(context);

    void setBoolValue()async{
      bool val = await SharedPrefs.isProfileCreated();

      if(isProfileCreated.value != val){
        isProfileCreated.setValue(val);
      }
    }

    if(user != null){
      setBoolValue();

      if(isProfileCreated.value){
        return const Home();
      }
      else{
        return const SetupProfile();
      }
    }
    else{
      return const PhoneVerification();
    }
  }
}


class IsProfileCreatedProvider extends ChangeNotifier{
  bool value = false;

  void setValue(bool val){
    value = val;

    notifyListeners();
  }
}