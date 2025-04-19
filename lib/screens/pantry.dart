import 'package:flutter/material.dart';

class Pantry extends StatefulWidget {
  const Pantry({super.key});

  @override
  PantrytState createState() => PantrytState();
}

class PantrytState extends State<Pantry> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Text("Pantry"));
  }
}
