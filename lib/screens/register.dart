// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ingreedy_app/constants.dart';
import 'package:ingreedy_app/widgets/button.dart';
import 'package:ingreedy_app/widgets/textfield.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final res = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': usernameCtrl.text,
            'email': emailCtrl.text,
            'password': passCtrl.text,
          }),
        );

        final data = jsonDecode(res.body);

        if (res.statusCode == 201) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Registration failed';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Network error: Unable to connect to server';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('images/login.jpeg', fit: BoxFit.cover),
          ),
          Container(color: const Color.fromRGBO(0, 0, 0, 0.4)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Create an account",
                    style: TextStyle(color: Colors.white, fontSize: 16.5),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: const Color.fromRGBO(244, 67, 54, 0.3),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Textfield(
                          label: 'Username',
                          labelColor: Colors.white,
                          controller: usernameCtrl,
                          validator: _validate,
                          hintText: 'Username',
                        ),
                        const SizedBox(height: 9),
                        Textfield(
                          label: 'Email',
                          labelColor: Colors.white,
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validate,
                          hintText: 'Email',
                        ),
                        const SizedBox(height: 9),
                        Textfield(
                          label: 'Password',
                          labelColor: Colors.white,
                          controller: passCtrl,
                          isPassword: true,
                          validator: _validate,
                          hintText: 'Password',
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Button(
                              text: 'Register',
                              color: Colors.white,
                              txtColor: Colors.black,
                              onPressed: _submit,
                            ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed:
                                  () => Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  ),
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
