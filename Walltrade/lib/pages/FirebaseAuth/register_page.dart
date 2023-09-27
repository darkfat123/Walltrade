import 'dart:convert';

import 'package:Walltrade/pages/FirebaseAuth/auth.dart';
import 'package:Walltrade/pages/FirebaseAuth/continue_register_page.dart';
import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';
import 'package:Walltrade/primary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';

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

    if (response.statusCode == 200) {
      // Registration successful
      Fluttertoast.showToast(
          msg: "สมัครสมาชิกสำเร็จ",
          backgroundColor: primary,
          textColor: Colors.white);
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
      backgroundColor: primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Lottie.asset('assets/lottie/registerLottie.json', height: 380),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.app_registration_rounded),
                        SizedBox(
                          width: 8,
                        ),
                        const Text(
                          'สมัครสมาชิก',
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                          ),
                        ),
                      ],
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
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: const Icon(Icons.lock_reset),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16.0),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (passwordController.text !=
                            confirmpasswordController.text) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            width: 0,
                            title: "เกิดข้อผิดพลาด",
                            text: "ยืนยันรหัสผ่านไม่ถูกต้อง",
                            confirmBtnColor: primary,
                            confirmBtnText: "ตกลง",
                            onConfirmBtnTap: () => Navigator.pop(context),
                            confirmBtnTextStyle:
                                TextStyle(fontSize: 16, color: Colors.white),
                          );
                        } else if (emailController.text != '' &&
                            usernameController.text != '' &&
                            passwordController.text != '' &&
                            confirmpasswordController.text != '') {
                          createUserWithEmailAndPassword()
                              .then((value) => registerUser())
                              .then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContinueRegisterPage(
                                      username: usernameController.text,
                                    ),
                                  )));
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ถัดไป',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7E1717),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(thickness: 3),
                    Text(
                      "มีสมาชิกแล้ว?",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF212436),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
