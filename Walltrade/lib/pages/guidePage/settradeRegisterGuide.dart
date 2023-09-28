import 'package:Walltrade/pages/FirebaseAuth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

class SettradeRegisterGuidePage extends StatelessWidget {
  const SettradeRegisterGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("สมัครสมาชิกกับ Settrade")),
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
                  "เข้าสู่เว็บไซต์: open-api.settrade.com",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    width: 0,
                    title: 'เปิด Browser',
                    text: 'เมื่อกดปุ่ม "ตกลง" จะนำไปสู่เว็บไซต์ Settrade',
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
                      launchUrl(
                          Uri.parse("https://open-api.settrade.com/open-api/"),
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
                    'ไปที่คำว่า "สมัครเข้าใช้งาน"',
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
                      "assets/img/settradeHome.png",
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
                    'กรอกข้อมูลที่ให้เรียบร้อย และกด "ลงทะเบียน"',
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
                      "assets/img/settradeRegister.png",
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
                    'เมื่อกรอกข้อมูลสำเร็จ จะมีข้อตกลงการใช้งานแสดงขึ้นมา อ่านให้เรียบร้อยและเลื่อนลงมาจนสุดจึงจะกดยอมรับได้',
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
                      "assets/img/settradeConfirmPrivacy.png",
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
                    'หลังจากกดยอมรับจะเข้าสู่ระบบทันที และกดคำว่า "สร้าง Application Id" ',
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
                      "assets/img/settradeCreateAPI.png",
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
                    'หลังจากนั้นให้จดหรือบันทึกข้อมูลในช่องสีแดงไว้  *จำเป็นต้องใช้',
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
                      "assets/img/settradeGenerated.png",
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
                    'หากต้องการเปลี่ยนเป็นการเทรดด้วยเงินจริง ให้ติดต่อโบรกเกอร์ที่ใช้งานได้กับ Settrade',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20.0), // ปรับค่าตามความต้องการ
                    child: Image.asset(
                      "assets/img/settradeBroker.png",
                      width: 320,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'หมายเหตุ: การใช้เงินทดลองในการซื้อขายหุ้นไทย จะสามารถใช้งานได้เพียงวันเดียว วันถัดไปหุ้นที่ซื้อในระบบจำลองจะหายไปทั้งหมด',
                  style:TextStyle(fontSize: 16)
                )),
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
                  'ได้สมัครสมาชิกกับ Settrade เรียบร้อยแล้ว!',
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
                            builder: (context) => RegisterPage(),
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
