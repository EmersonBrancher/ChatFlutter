import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);

  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset(){
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                final XFile? imgXFile = await ImagePicker().pickImage(source: ImageSource.camera);
                File imgFile = File(imgXFile!.path);

                widget.sendMessage(imgFile: imgFile);
              },
              icon: Icon(Icons.camera_alt)
          ),
          Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration.collapsed(
                    hintText: 'Enviar uma mensagem'
                ),
                onChanged: (text){
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                  },
                onSubmitted: (text){
                  widget.sendMessage(text: text);
                  _reset();
                },
              )),
          IconButton(
              onPressed: _isComposing ? (){
                widget.sendMessage(text: _controller.text);
                _reset();
              } : null,
              icon: Icon(Icons.send)
          ),
        ],
      ),
    );
  }
}
