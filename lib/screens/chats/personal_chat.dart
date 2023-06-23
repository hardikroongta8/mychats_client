import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:mychats/services/mongodb_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:mychats/shared/globals.dart';
import 'dart:ui' as ui;

class PersonalChat extends StatefulWidget {
  final String phoneNumber;
  final String displayName;
  const PersonalChat({required this.phoneNumber, required this.displayName, super.key});

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> with WidgetsBindingObserver {
  final sessionService = SessionService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final msgStyle = const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w300
  );

  late Timer periodicTimer;

  List<Map> allMessages = [];
  List<Map> socketMessages = [];

  List<Widget> messageBlocks = [];

  bool isOnline = false;
  String status = 'Online';

  Size textSize(String text, TextStyle style){
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), 
      maxLines: 1,

      textDirection: ui.TextDirection.ltr
    )
    ..layout(minWidth: 0, maxWidth: double.infinity);
    
    return textPainter.size;
  }

  void saveMessagesToDB()async{
    final msgs = socketMessages;

    sessionService.socket.emit('dataSavedOnCloud', {
      'roomId': roomId(widget.phoneNumber)
    });

    // TRY EMITTING SOCKET SIGNAL FIRST
    // STORE SOCKET MESSAGES IN LOCAL VARIABLE IN THE SCOPE OF THE FUNCTION

    // ALSO TRY SAVING DATA TO CLOUD ONLY IN DISPOSE FUNCTION
    
    String res = await MongoDBService().sendMessage({
      'roomId': roomId(widget.phoneNumber),
      'messageList': msgs
    });

    sessionService.socket.emit('refreshView', {
      'roomId': roomId(widget.phoneNumber)
    });

    log(res);
  }
  
  void getMessages()async{
    List msgs = await MongoDBService().getMessages(roomId(widget.phoneNumber));
    List<Map> m = [];
    for(int i = 0; i < msgs.length; i++){
      m.add({
        'body': msgs[i]['body'] as String,
        'sentBy': msgs[i]['sentBy'] as String,
        'sendingTime': msgs[i]['sendingTime'] as String,
        'roomId': roomId(widget.phoneNumber)
      });
    }

    if(mounted){
      setState(() {
        allMessages = m;
      });
    }
  }

  void checkOnline(){
    sessionService.socket.on(
      'clientsInRoom',
      (data){
        log(data.toString());
        
        if(data['clientList'] == 2){
          periodicTimer.cancel();
          periodicTimer = Timer.periodic(
            const Duration(seconds: 10),
            (timer){
              log('tick');
              if(socketMessages.isNotEmpty){
                saveMessagesToDB();
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
              log('tick');
              if(socketMessages.isNotEmpty){
                saveMessagesToDB();
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
      sessionService.joinPersonalRoom(widget.phoneNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionService.joinPersonalRoom(widget.phoneNumber);
    getMessages();

    sessionService.socket.on('sentMessage',
      (data){
        log('Message received');
        if(mounted){
          setState(() {
            allMessages.add(data);
            socketMessages.add(data);
          });
        }
    });

    sessionService.socket.on('dataSaved',
      (data){
        log('emptying socket messages');
        socketMessages = [];
      }
    );

    sessionService.socket.emit('findClientsInRoom', {
      'roomId': roomId(widget.phoneNumber)
    });

    checkOnline();

    periodicTimer = Timer.periodic(
    const Duration(seconds: 1),
    (timer){
      log('tick');
      if(socketMessages.isNotEmpty){
        saveMessagesToDB();
      }
    }
  );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    periodicTimer.cancel();
    if(socketMessages.isNotEmpty){
      saveMessagesToDB();
    }
    socketMessages = [];
    sessionService.leaveRoom(widget.phoneNumber);
    sessionService.socket.emit('findClientsInRoom', {
      'roomId': roomId(widget.phoneNumber)
    });
    sessionService.disconnectSocket();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messageBlocks = [];
    for(var message in allMessages){
      messageBlocks.add(
        Align(
          alignment: (message['sentBy'] == AuthService().phoneNumber)
            ? Alignment.centerRight 
            : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
                minWidth: MediaQuery.of(context).size.width * 0.2
              ),
              width: textSize(message['body'], msgStyle).width  + 60,
              decoration: BoxDecoration(
                color: message['sentBy'] == AuthService().phoneNumber! 
                  ? Colors.red[900]
                  : const Color.fromRGBO(99, 66, 66, 1),
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Stack(
                  children: [
                    Text(
                      message['body'],
                      style: msgStyle,
                      softWrap: true,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Text(
                        DateFormat("HH:mm").format(DateTime.parse(message['sendingTime'])),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ),
                  ]
                ),
              )
            ),
          ),
        )
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: SizedBox(
          child: Row(
            children: [
              const CircleAvatar(),
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
              child: allMessages.length <= 20
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
                  int index = allMessages.length - i - 1;
                  return messageBlocks[index];
                },
                itemCount: allMessages.length,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
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
                          onPressed: (){
                            if(_controller.text.isEmpty)return;
                            sessionService.sendMessage(_controller.text, widget.phoneNumber);
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