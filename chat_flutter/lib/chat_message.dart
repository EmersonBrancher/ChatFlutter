import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.senderUser);

 final Map<String, dynamic> data;
 final bool senderUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !senderUser ?
          Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ) :
          Container(),
          Expanded(
            child: Column(
                crossAxisAlignment: senderUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (data['imgUrl'] != null)
                    Image.network(
                      data['imgUrl'],
                      width: 250,
                    )
                  else Container(
                          padding: EdgeInsets.only(left: 75),
                          child: Text(
                            data['text'],
                            textAlign: senderUser ? TextAlign.end : TextAlign.start,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                  Text(
                    data['senderName'],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ),
          senderUser ?
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ) :
          Container(),
        ],
      ),
    );
  }
}
