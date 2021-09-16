import 'dart:io';

import 'package:chat_flutter/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  late User _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user!;
    });
  }

  Future<User?> _getUser() async{

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = authResult.user;

      return user;
    } catch (error) {
        return null;
    }
  }

  void _sendMessage({String? text, imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState!.showSnackBar(
        SnackBar(
            content: Text('Não foi possível fazer o login. Tente novamente!'),
        )
      );
    }

    Map<String, dynamic> data = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
    };

    if (imgFile != null){
      UploadTask task = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);

      String url = await (await task).ref.getDownloadURL();
      data['imgUrl'] = url;
    }

    if (text != null) {
      data['text'] = text;
    }

    FirebaseFirestore.instance.collection("messages").add(data);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Olá"),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        List<QueryDocumentSnapshot> documents = snapshot.data!.docs.reversed.toList();

                        return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(documents[index].get('text')),
                            );
                          }
                        );
                    }
                  },
                  stream: FirebaseFirestore.instance.collection('messages').snapshots(),
              ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
