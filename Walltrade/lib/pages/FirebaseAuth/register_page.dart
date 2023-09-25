import 'dart:convert';

import 'package:Walltrade/pages/FirebaseAuth/auth.dart';
import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../variables/serverURL.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  String errorMessage = '';

  Future<void> registerUser() async {
    final String url = '${Constants.serverUrl}/register';
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Map<String, dynamic> body = {
      'email': emailController.text,
      'username': usernameController.text,
      'password': passwordController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 &&
        confirmpasswordController == passwordController) {
      // Registration successful
      final Map<String, dynamic> data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text(data['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Registration failed
      final Map<String, dynamic> error = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(error['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        username: usernameController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF068DA9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                height: 500,
                decoration: BoxDecoration(
                  color: const Color(0xFFECF8F9),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color(0xFF212436),
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'สมัครสมาชิก',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'ชื่อผู้ใช้',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'รหัสผ่าน',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: confirmpasswordController,
                      decoration: InputDecoration(
                        labelText: 'ยืนยันรหัสผ่าน',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.lock_reset),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: createUserWithEmailAndPassword,
                      child: Container(
                        height: 30,
                        width: 100,
                        child: const Center(
                          child: Text(
                            'สมัครสมาชิก',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E1717),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'มีบัญชีแล้ว?  ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Color(0xFF212436),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
