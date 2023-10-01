import 'dart:convert';

import 'package:Walltrade/variables/serverURL.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'makeDismissible.dart';

Widget ForgotPasswordSheet({
  required BuildContext
      context, // เพิ่มพารามิเตอร์ context ที่รับค่า BuildContext
}) {
  TextEditingController emailController = TextEditingController();
  Future<bool> checkEmailExist() async {
    final url = Uri.parse('${Constants.serverUrl}/checkEmailExist');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": emailController.text.trim()}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return true;
    } else {
      print('เกิดข้อผิดพลาด: ${response.statusCode}');
      print(response.body);
      return false;
    }
  }

  Future resetPassword() async {
    try {
      if (await checkEmailExist()) {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text.trim())
            .then((value) => showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.success(
                    message: 'สำเร็จ! โปรดไปที่อีเมลของคุณเพื่อเปลี่ยนรหัสผ่าน',
                  ),
                ));
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "อีเมลไม่ถูกต้อง โปรดลองใหม่อีกครั้ง",
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: "อีเมลไม่ถูกต้อง โปรดลองใหม่อีกครั้ง",
        ),
      );
    }
  }

  return makeDismissible(
    child: DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "เปลี่ยนรหัสผ่าน",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16.0,
                    ),
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    resetPassword();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rotate_right_rounded),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'ยืนยัน',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF82CD47),
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    context: context,
  );
}
