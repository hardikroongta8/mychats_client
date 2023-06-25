import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mychats/screens/chats/personal_chat.dart';
import 'package:mychats/screens/contact_screen.dart';
import 'package:mychats/services/chat_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// SOCKET CONNECTIONS THAT LISTENS TO EVERY MESSAGE SENT TO ME
// NOT ONLY ROOMS BUT EVERY MESSAGE
// MAYBE EVERYONE JOINS A PRIVATE ROOM (ROOM ID = MY PHONE NUMBER)
// AND WHENEVER SOMEBODY SENDS A MESSAGE TO ME, SOCKET EMITS A MESSAGE TO HIS AND MINE PRIVATE ROOMS
class _HomeState extends State<Home> with WidgetsBindingObserver {
  List activeRooms= [];

  final SessionService sessionService = SessionService();

  void getActiveChats()async{
    final chats = await ChatService().getActiveChats();
    if(mounted){
      setState(() {
        chats.sort((a, b) => -1*(a['lastActive'].toString()).compareTo(b['lastActive'].toString()));
        activeRooms = chats;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionService.joinMyRoom();
    sessionService.socket.on('refreshView', (data){
      log('refreshView');
      getActiveChats();
    });
    getActiveChats();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      log('resume');
      sessionService.joinMyRoom();
      getActiveChats();
    }
  }

  @override
  void dispose() {
    sessionService.leaveMyRoom();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    sessionService.socket.on('refreshView', (data){
      log('refreshView');
      getActiveChats();
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('MyChats'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PersonalChat(
                  phoneNumber: activeRooms[index]['phoneNumber'],
                  displayName: activeRooms[index]['displayName'],
                  session: sessionService,
                )
              )
            ).then((value){getActiveChats();});
          },
          splashColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: const CircleAvatar(
            radius: 30,
          ),
          isThreeLine: false,
          title: Text(activeRooms[index]['displayName']),
          subtitle: Text(
            activeRooms[index]['lastMessage']['body'],
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              color: Colors.white60,
            ),
          ),
          titleAlignment: ListTileTitleAlignment.titleHeight,
          trailing: Column(
            children: [
              Text(
                DateFormat("HH:mm").format(DateTime.parse(activeRooms[index]['lastActive'])),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w300
                ),
              ),
              const SizedBox(height: 8,),
              const CircleAvatar(
                radius: 10,
                child: Text('10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),),
              )
            ],
          ),
        ),
        itemCount: activeRooms.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ContactScreen(session: sessionService,))
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}