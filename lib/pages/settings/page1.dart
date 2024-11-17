import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: const Text('Genel Ayarlar'),),
      body: Column(children: [
        SwitchListTile(value: true, onChanged: (open){

        }),
      ],),
    );
  }
}
