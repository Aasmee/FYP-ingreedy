import 'package:flutter/material.dart';

class Recipe extends StatefulWidget {
  const Recipe({super.key});

  @override
  RecipeState createState() => RecipeState();
}

class RecipeState extends State<Recipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Text("Recipe"));
  }
}
