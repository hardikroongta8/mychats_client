import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mychats/screens/chats/personal_chat.dart';
import 'package:mychats/screens/contact_screen.dart';
import 'package:mychats/services/chat_service.dart';
import 'package:mychats/services/session_service.dart';
import 'package:intl/intl.dart';
import 'package:mychats/shared/loading.dart';
import 'package:mychats/widgets/profile_pic.dart';

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
  late Future<List> activeRooms;

  final SessionService sessionService = SessionService();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sessionService.joinMyRoom();
    sessionService.socket.on('refreshView', (data){
      log('refreshView');
      if(mounted){
        setState(() {
          activeRooms = ChatService().getActiveChats();
        });
      }
    });
    if(mounted){
      setState(() {
        activeRooms = ChatService().getActiveChats();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.resumed){
      log('resume');
      sessionService.joinMyRoom();
      setState(() {
        activeRooms = ChatService().getActiveChats();
      });
    }
  }

  @override
  void dispose() {
    if(sessionService.socket.connected)sessionService.leaveMyRoom();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text('MyChats'),
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
      body: FutureBuilder(
        future: activeRooms,
        builder: (context, snapshot){
          switch(snapshot.connectionState){
            case ConnectionState.none: return const Text('None');
            case ConnectionState.waiting: return const Loading();
            case ConnectionState.active: return const Text('active');
            case ConnectionState.done: 
            if(snapshot.hasError){
              return Center(
                child: Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            }
            else{
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => ListTile(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PersonalChat(
                          phoneNumber: snapshot.data![index]['phoneNumber'],
                          displayName: snapshot.data![index]['displayName'],
                          session: sessionService,
                        )
                      )
                    ).then((value){
                      if(mounted){
                        setState(() {
                          activeRooms = ChatService().getActiveChats();
                        });
                      }
                    });
                  },
                  splashColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  leading: ProfilePic(
                    phoneNumber: snapshot.data![index]['phoneNumber'],
                    radius: 30,
                  ),
                  isThreeLine: false,
                  title: Text(snapshot.data![index]['displayName']),
                  subtitle: snapshot.data![index]['lastMessage']['isFile'] 
                  ? const Row(
                    children: [
                      Icon(Icons.image, size: 16, color: Colors.white60,),
                      Text(
                        ' Image',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ):Text(
                    snapshot.data![index]['lastMessage']['body'] ,
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
                        DateFormat("HH:mm").format(DateTime.parse(snapshot.data![index]['lastActive'])),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                      const SizedBox(height: 8,),
                      snapshot.data![index]['count'] == 0 || snapshot.data![index]['count'] == null 
                      ? const SizedBox() 
                      : CircleAvatar(
                        radius: 10,
                        child: Text(
                          snapshot.data![index]['count'].toString(), 
                          style: const TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w300
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}