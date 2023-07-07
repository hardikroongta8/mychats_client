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
    final boolProvider = Provider.of<BoolProvider>(context);

    void setBoolValue()async{
      bool val = await SharedPrefs.isProfileCreated();

      if(boolProvider.value != val){
        boolProvider.setValue(val);
      }
    }

    if(user != null){
      setBoolValue();

      if(boolProvider.value){
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


class BoolProvider extends ChangeNotifier{
  bool value = false;

  void setValue(bool val){
    value = val;

    notifyListeners();
  }
}