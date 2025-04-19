import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ingreedy_app/nav.dart';
import 'package:ingreedy_app/screens/login.dart';
import 'package:ingreedy_app/screens/register.dart';
import 'package:ingreedy_app/screens/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Clear any stored token to simulate fresh start (for development/testing)
  // Comment this out if you want to persist login across app launches
  await prefs.remove('token');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token from SharedPreferences: ${prefs.getString('token')}');
    return (token != null && token.isNotEmpty) ? const NavBar() : const Login();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getInitialWidget(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: Text('Error loading app'))),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: snapshot.data,
            routes: {
              '/login': (context) => const Login(),
              '/register': (context) => const Register(),
              '/nav': (context) => const NavBar(),
              '/profile': (context) => const ProfilePage(),
            },
          );
        }
      },
    );
  }
}
