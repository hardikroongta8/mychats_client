import 'package:firebase_auth/firebase_auth.dart';
import 'package:mychats/services/shared_prefs.dart';

class AuthService{
  final FirebaseAuth authService = FirebaseAuth.instance;

  String? get firebaseId{
    return authService.currentUser?.uid;
  }

  String? get phoneNumber{
    return authService.currentUser?.phoneNumber;
  }

  Stream<User?> get user{
    return authService.authStateChanges();
  }

  Future<void> signOut()async{
    await authService.signOut();
    await SharedPrefs.deleteTokens();
    await SharedPrefs.deleteIsProfileCreated();
  }
}