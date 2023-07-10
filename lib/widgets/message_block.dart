import 'package:flutter/material.dart';
import 'package:mychats/models/message.dart';
import 'package:mychats/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:mychats/shared/styles.dart';

class MessageBlock extends StatelessWidget {
  final Message message;
  const MessageBlock({
    required this.message, 
    super.key
  });

  Size textSize(String text, TextStyle style){
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style), 
      maxLines: 1,

      textDirection: ui.TextDirection.ltr
    )
    ..layout(minWidth: 0, maxWidth: double.infinity);
    
    return textPainter.size;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (message.sentBy == AuthService().phoneNumber)
        ? Alignment.centerRight 
        : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.2
          ),
          width: textSize(message.body, Styles().messageTextStyle).width  + 60,
          decoration: BoxDecoration(
            color: message.sentBy == AuthService().phoneNumber! 
              ? Colors.blue[800]
              : Colors.white10,
            borderRadius: BorderRadius.circular(12)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Stack(
              children: [
                Text(
                  message.body,
                  style: Styles().messageTextStyle,
                  softWrap: true,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text(
                    DateFormat("HH:mm").format(DateTime.parse(message.sendingTime)),
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
    );
  }
}