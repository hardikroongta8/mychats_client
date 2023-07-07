import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs{
  static Future<void> setAccessToken(String token)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', token);
  }

  static Future<String?> getAccessToken()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('accessToken');
  }

  static Future<void> setRefreshToken(String token)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('refreshToken', token);
  }

  static Future<String?> getRefreshToken()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('refreshToken');
  }

  static Future<void> setIsProfileCreated(bool value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isProfileCreated', value);
  }

  static Future<void> deleteIsProfileCreated()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('isProfileCreated');
  }

  static Future<bool> isProfileCreated()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isProfileCreated') ?? false;
  }
}