import 'package:Walltrade/main.dart';
import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';
import 'package:Walltrade/pages/HomePage.dart';
import 'package:Walltrade/primary.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


import '../../variables/serverURL.dart';

class ContinueRegisterPage extends StatefulWidget {
  final String username;
  ContinueRegisterPage({required this.username});
  @override
  _ContinueRegisterPageState createState() =>
      _ContinueRegisterPageState(username: username);
}

class _ContinueRegisterPageState extends State<ContinueRegisterPage> {
  final TextEditingController alpacaKeyController = TextEditingController();
  final TextEditingController alpacaSecretController = TextEditingController();
  final TextEditingController settradeAppIDController = TextEditingController();
  final TextEditingController settradeSecretController =
      TextEditingController();
  String errorMessage = '';
  final String username;

  _ContinueRegisterPageState({required this.username});

  Future<void> updateUser() async {
    final url = Uri.parse('${Constants.serverUrl}/updateAPI');

    final response = await http.post(
      url,
      body: {
        'api_key': alpacaKeyController.text,
        'secret_key': alpacaSecretController.text,
        'th_api_key': settradeAppIDController.text,
        'ath_secret_key': settradeSecretController.text,
        'username': username,
      },
    );

    if (response.statusCode == 200) {
      // สำเร็จ
      Fluttertoast.showToast(
          msg: "สมัครสมาชิกสำเร็จ",
          backgroundColor: primary,
          textColor: Colors.white);
    } else {
      // ไม่สามารถส่งข้อมูลไปยัง Flask server ได้
      print('Failed to update user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ข้อมูลเบื้องต้น',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: alpacaKeyController,
                  decoration: InputDecoration(
                    labelText: 'Alpaca API Key',
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
                    prefixIcon: const Icon(Icons.vpn_key_rounded),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: alpacaSecretController,
                  decoration: InputDecoration(
                    labelText: 'Alpaca Secret Key',
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
                    prefixIcon: const Icon(Icons.key_rounded),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: settradeAppIDController,
                  decoration: InputDecoration(
                    labelText: 'Settrade Application ID',
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
                    prefixIcon: const Icon(Icons.vpn_key_rounded),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: settradeSecretController,
                  decoration: InputDecoration(
                    labelText: 'Settrade Application Secret',
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
                    prefixIcon: const Icon(Icons.key_off_rounded),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (alpacaKeyController.text != '' &&
                        alpacaSecretController.text != '' &&
                        settradeAppIDController.text != '' &&
                        settradeSecretController.text != '') {
                      updateUser().then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(username: username,initialIndex: 0),)));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'สมัครสมาชิก',
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
                  "มีบัญชีแล้ว?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
