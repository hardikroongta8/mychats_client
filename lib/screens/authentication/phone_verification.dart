import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mychats/shared/constants.dart';

class PhoneVerification extends StatefulWidget {
  const PhoneVerification({super.key});

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  int start = 60;
  bool wait = false;

  String buttonName = 'Send Code';

  late Timer timer;
  void startTimer() {
    const onsec = Duration(seconds: 1);
    timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        if(mounted){
          setState(() {
            timer.cancel();
            wait = false;
          });
        }
      } else {
        if(mounted){
          setState(() {
            start--;
          });
        }
      }
    });
  }


  final buttonStyle = ButtonStyle(
    shape: MaterialStateProperty.all(RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10)
    )),
    elevation: MaterialStateProperty.all(2),
  );

  final _controller = TextEditingController();
  String code = '+91';

  String verificationIdFinal = '';
  String smsCode = '';

  List<String> smsCodeList = ['0', '0', '0', '0', '0', '0'];

  final authService = FirebaseAuth.instance;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    void showSnackbar(String text){
      final snackBar = SnackBar(content: Text(text));
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 0.15*screenHeight,
                  ),
                  const Text(
                    'Enter your phone number',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(
                    height: screenHeight*0.02,
                  ),
                  const Text(
                    'MyChats will need to verify your phone number.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(
                    height: screenHeight*0.04,
                  ),
                  SizedBox(
                    width: screenWidth*0.8,
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: textInputDecration.copyWith(
                        hintText: 'Phone number',
                        prefixIcon: SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(code),
                          ),
                        )
                      ),
                      controller: _controller,
                    ),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: wait ? null :(){
                      if(!mounted)return;
                      
                      startTimer();

                      FocusManager.instance.primaryFocus?.unfocus();
      
                      setState(() {
                        start = 60;
                        wait = true;
                        buttonName = 'Resend code';
                      });
      
                      authService.verifyPhoneNumber(
                        phoneNumber: code + _controller.text.replaceAllMapped(' ', (match) => '').trim(),
                        timeout: const Duration(seconds: 60),
                        verificationCompleted: (PhoneAuthCredential credential){
                          showSnackbar('Verification has been completed.');
                        },
                        verificationFailed: (FirebaseAuthException e){
                          showSnackbar(e.toString());
                        },
                        codeSent: (String verificationId, int? resendToken){
                          showSnackbar('SMS sent.');
                          if(mounted){
                            setState(() {
                              verificationIdFinal = verificationId;
                            });
                          }
                        },
                        codeAutoRetrievalTimeout: (String verificationId){
                          showSnackbar('Time Out');
                        }
                      );
                    },
                    style: buttonStyle,
                    child: Text(
                      buttonName,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight*0.1,),
                  const Text(
                    'Enter the Code',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white70
                    ),
                  ),
                  SizedBox(height: screenHeight*0.05,),
                  SizedBox(
                    height: 80,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[0] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[1] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[2] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[3] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[4] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: TextFormField(
                            decoration: textInputDecration,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(1),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value){
                              if(value.length == 1){
                                smsCodeList[5] = value;
                                FocusScope.of(context).nextFocus();
                              }
                              if(value.isEmpty){
                                FocusScope.of(context).previousFocus();
                              }
                            },
                          ),
                        ),                     
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight*0.1,
                  ),
                  ElevatedButton(
                    onPressed: ()async{
                      smsCode = '';
                      for(int i = 0; i < 6; i++){
                        smsCode += smsCodeList[i];
                      }
                      AuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationIdFinal,
                        smsCode: smsCode
                      );
      
                      await authService.signInWithCredential(credential);
                      showSnackbar('Logged In');
                    },
                    style: buttonStyle,
                    child: const Text('Verify OTP')
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}