import 'package:Walltrade/guidePage/alpacaLoginGuide.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';



class AlpacaRegisterGuidePage extends StatelessWidget {
  const AlpacaRegisterGuidePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("สมัครสมาชิกกับ Alpaca")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF212436),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(12),
              child: TextButton(
                child: Text(
                  "เข้าสู่เว็บไซต์: alpaca.markets",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    width: 0,
                    title: 'เปิด Browser',
                    text: 'เมื่อกดปุ่ม "ตกลง" จะนำไปสู่เว็บไซต์ Alpaca',
                    backgroundColor: Colors.white,
                    titleColor: Colors.black,
                    textColor: Colors.black,
                    confirmBtnText: "ตกลง",
                    cancelBtnText: "ยกเลิก",
                    confirmBtnTextStyle:
                        TextStyle(fontSize: 16, color: Colors.white),
                    cancelBtnTextStyle: TextStyle(fontSize: 16),
                    showCancelBtn: true,
                    onConfirmBtnTap: () {
                      launchUrl(Uri.parse("https://alpaca.markets/"),
                          mode: LaunchMode.externalApplication);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(bottom: 30, top: 20, left: 30, right: 30),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF212436),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'ไปที่คำว่า "Sign up for free หรือ Sign up"',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20.0), // ปรับค่าตามความต้องการ
                    child: Image.asset(
                      "assets/img/alpacaHome.png",
                      width: 320,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(bottom: 30, top: 20, left: 30, right: 30),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF212436),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'กรอกข้อมูลให้เรียบร้อย และกด "Sign up"',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20.0), // ปรับค่าตามความต้องการ
                    child: Image.asset(
                      "assets/img/alpacaInput.png",
                      width: 320,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  EdgeInsets.only(bottom: 30, top: 20, left: 30, right: 30),
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFF212436),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    'เมื่อสำเร็จ จะมีข้อความยืนยันถูกส่งไปที่อีเมลที่เราสมัคร ให้กดที่คำว่า "Confirm My Account"',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20.0), // ปรับค่าตามความต้องการ
                    child: Image.asset(
                      "assets/img/alpacaConfirmRegister.png",
                      width: 320,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF82CD47),
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'ได้สมัครสมาชิกกับ Alpaca เรียบร้อยแล้ว!',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlpacaLoginGuidePage(),
                          ));
                    },
                    child: Text(
                      "ขั้นตอนถัดไป",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF82CD47),
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
