import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mychats/models/message.dart';
import 'package:mychats/screens/chats/send_photo.dart';
import 'package:mychats/services/image_service.dart';
import 'package:mychats/services/mongodb_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:mychats/shared/globals.dart';
import 'package:mychats/shared/loading.dart';
import 'package:mychats/widgets/message_block.dart';
import 'package:mychats/widgets/photo_block.dart';
import 'package:mychats/widgets/profile_pic.dart';


class PersonalChat extends StatefulWidget {
  final String phoneNumber;
  final String displayName;
  final SessionService session;
  const PersonalChat({required this.session, required this.phoneNumber, required this.displayName, super.key});

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  late Timer periodicTimer;

  late Future<List<Map<String, dynamic>>> allMessages;
  List<Map> socketMessages = [];

  List<Widget> messageBlocks = [];

  bool isOnline = false;
  String status = 'Online';


  List<Widget> getMessageBlockList(List<Map<String, dynamic>> messageList){
    messageBlocks = [];
    for(var message in messageList){
      messageBlocks.add(
        message['isFile'] == true
        ? PhotoBlock(photo: Photo.fromJson(message)) 
        : MessageBlock(message: Message.fromJson(message))
      );
    }
    return messageBlocks;
  }  

  void saveMessagesToDB(bool isOffline)async{
    final msgs = socketMessages;

    widget.session.socket.emit('dataSavedOnCloud', {
      'roomId': getRoomId(widget.phoneNumber)
    });

    // TRY EMITTING SOCKET SIGNAL FIRST
    // STORE SOCKET MESSAGES IN LOCAL VARIABLE IN THE SCOPE OF THE FUNCTION

    // ALSO TRY SAVING DATA TO CLOUD ONLY IN DISPOSE FUNCTION
    int count = 0;
    if(isOffline){
      count = msgs.length;
    }
    String res = await MongoDBService().saveMessages({
      'roomId': getRoomId(widget.phoneNumber),
      'messageList': msgs,
      'unreadMessages': {
        'count': count,
        'phoneNumber': widget.phoneNumber
      }
    });

    widget.session.socket.emit('refreshView', {
      'roomId': getRoomId(widget.phoneNumber)
    });

    log('emitting refresh view');

    log(res);
  }
  

  void checkOnline(){
    widget.session.socket.on(
      'clientsInRoom',
      (data){
        log(data.toString());
        
        if(data['clientList'] == 2){
          periodicTimer.cancel();
          periodicTimer = Timer.periodic(
            const Duration(seconds: 10),
            (timer){
              if(socketMessages.isNotEmpty){
                saveMessagesToDB(false);
              }
            }
          );
          if(mounted){
            setState(() {
              isOnline = true;
            });
          }
          log('Timer period: 10');
        }
        else{
          periodicTimer.cancel();
          periodicTimer = Timer.periodic(
            const Duration(seconds: 1), 
            (timer){
              if(socketMessages.isNotEmpty){
                saveMessagesToDB(true);
              }
            }
          );
          if(mounted){
            setState(() {
              isOnline = false;
            });
          }
          log('Timer period: 1');
        } 
      }
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      log('App state resumed');
      widget.session.joinPersonalRoom(widget.phoneNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.session.joinPersonalRoom(widget.phoneNumber);

    String? roomId = getRoomId(widget.phoneNumber);
    if(roomId == null)widget.session.disconnectSocket();
    
    allMessages = MongoDBService().getMessages(roomId!);

    widget.session.socket.on('sentMessage',
      (data){
        log('Message received');
        // log(data['isFile']);
        if(mounted){
          setState(() {
            messageBlocks.add(
              data['isFile'] ? PhotoBlock(photo: Photo.fromJson(data)) : MessageBlock(message: Message.fromJson(data))
            );
            socketMessages.add(data);
          });
        }
    });

    widget.session.socket.on('dataSaved',
      (data){
        log('emptying socket messages');
        socketMessages = [];
      }
    );

    widget.session.socket.emit('findClientsInRoom', {
      'roomId': getRoomId(widget.phoneNumber)
    });

    checkOnline();

    periodicTimer = Timer.periodic(
    const Duration(seconds: 1),
    (timer){
      if(socketMessages.isNotEmpty){
        saveMessagesToDB(true);
      }
    }
  );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    
    if(socketMessages.isNotEmpty){
      saveMessagesToDB(!isOnline);
    }
    socketMessages = [];
    log('cancelling the timer');

    periodicTimer.cancel();
    widget.session.leaveRoom(widget.phoneNumber);
    widget.session.socket.emit('findClientsInRoom', {
      'roomId': getRoomId(widget.phoneNumber)
    });
    widget.session.socket.off('clientsInRoom');
    widget.session.socket.off('sentMessage');
    widget.session.socket.off('dataSaved');
  }

  @override
  Widget build(BuildContext context) {
    void processImage(File image){
      Navigator.push(
        context,
        MaterialPageRoute( 
          builder: (context) {
            return SendPhoto(
              image: image,
              sessionService: widget.session,
              phoneNumber: widget.phoneNumber
            );
          },
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: SizedBox(
          child: Row(
            children: [
              ProfilePic(phoneNumber: widget.phoneNumber),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.displayName),
                  (!isOnline) ? const SizedBox() : Text(
                    status,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300
                    ),              
                  )
                ],
              ),
            ],
          ),
        ),
        leadingWidth: 20,
        actions: [
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.more_vert_rounded)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: allMessages,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.none: return const Text('None');
                    case ConnectionState.waiting: return const Loading();
                    case ConnectionState.active: return const Text('active');
                    case ConnectionState.done:
                    if(snapshot.hasError){
                      return Center(child: Text('${snapshot.error}'));
                    }else{
                      if(messageBlocks.isEmpty)getMessageBlockList(snapshot.data!);
                      return snapshot.data!.length <= 20
                      ? Container(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            children: messageBlocks,
                          ),
                        ),
                      )
                      : ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemBuilder: (context, i){
                          int index = messageBlocks.length - i - 1;
                          return messageBlocks[index];
                        },
                        itemCount: messageBlocks.length,
                      );
                    }
                  }
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.70,
                      height: MediaQuery.of(context).size.width * 0.12,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent
                              ),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            filled: true,
                            fillColor: Colors.white10,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.transparent
                              ),
                              borderRadius: BorderRadius.circular(30)
                            ),
                          ),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.06,
                      child: Center(
                        child: IconButton(
                          onPressed: ()async{
                            File? image;
                            showModalBottomSheet(
                              context: context, 
                              builder: (context) => SizedBox(
                                width: double.infinity,
                                height: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: ()async{
                                        Navigator.pop(context);
                                        image = await ImageService().pickImage(true);
                                        processImage(image!);
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
                                        image = await ImageService().pickImage(false);
                                        processImage(image!);
                                      },
                                      child: const CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.purple,
                                        child: Icon(Icons.image_rounded, size: 32,),
                                      ),
                                    ),                                    
                                  ],
                                ),
                              ),
                            );
                            
                          },
                          icon: const Icon(Icons.link_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.width * 0.06,
                      child: Center(
                        child: IconButton(
                          onPressed: (){
                            if(_controller.text.isEmpty)return;
                            widget.session.sendMessage(
                              body: _controller.text, 
                              theirPhoneNumber: widget.phoneNumber
                            );
                            _controller.clear();
                          },
                          icon: const Icon(Icons.send)
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}