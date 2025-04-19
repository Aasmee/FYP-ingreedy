import 'package:flutter/material.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  CreatePostState createState() => CreatePostState();
}

class CreatePostState extends State<CreatePost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Text("Create Post"));
  }
}
