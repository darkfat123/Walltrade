import 'package:Walltrade/pages/FirebaseAuth/auth.dart';
import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'makeDismissible.dart';

TextEditingController emailcontroller = TextEditingController();
TextEditingController usernamecontroller = TextEditingController();
TextEditingController passwordcontroller = TextEditingController();

Widget buildRegisterSheet({
  required BuildContext
      context, // เพิ่มพารามิเตอร์ context ที่รับค่า BuildContext
}) {
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth()
          .createUserWithEmailAndPassword(
            email: emailcontroller.text,
            password: passwordcontroller.text,
            username: usernamecontroller.text,
          )
          .then((value) => Navigator.pop(context));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  return makeDismissible(
    child: DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            TextField(
              controller: emailcontroller,
            ),
            TextField(
              controller: usernamecontroller,
            ),
            TextField(
              controller: passwordcontroller,
            ),
            ElevatedButton(
                onPressed: createUserWithEmailAndPassword,
                child: Text("สมัครสมาชิก"))
          ],
        ),
      ),
    ),
    context: context,
  );
}
