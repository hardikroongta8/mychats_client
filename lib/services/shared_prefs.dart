import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs{
  Future<void> setIsProfileCreated(bool value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isProfileCreated', value);
  }

  Future<void> deleteIsProfileCreated()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('isProfileCreated');
  }

  Future<bool> isProfileCreated()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isProfileCreated') ?? false;
  }
}