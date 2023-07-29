import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../variables/serverURL.dart';

class Settings extends StatefulWidget {
  final String username;

  Settings({required this.username});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _apiKeyController = TextEditingController();
  TextEditingController _secretKeyController = TextEditingController();

  Future<void> _saveKeys() async {
    String apiKey = _apiKeyController.text;
    String secretKey = _secretKeyController.text;

    // Send the API key and secret key to the Flask server
    String url =
        '${Constants.serverUrl}/api/user'; // เปลี่ยนเป็น URL ของ Flask server ที่ใช้งาน

    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> body = {
      'api_key': apiKey,
      'secret_key': secretKey,
      'username': widget.username,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Clear the text fields after saving
        _apiKeyController.clear();
        _secretKeyController.clear();

        // Show a success message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keys saved successfully')),
        );
      } else {
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save keys')),
        );
      }
    } catch (e) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8F9),
      appBar: AppBar(
        backgroundColor: Color(0xFF212436),
        title: Text('การตั้งค่า'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 700,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20),),
          child: Column(
            children: [
              Container(
                height: 300,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "หุ้นอเมริกา",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(                         
                                    shape: BoxShape.circle),
                                child: Padding(
                                  //this padding will be you border size
                                  padding: const EdgeInsets.all(3.5),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      foregroundImage:
                                          AssetImage("assets/img/usflag.png"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius:
                              BorderRadius.circular(20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius:
                              BorderRadius.circular(20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _secretKeyController,
                        decoration: InputDecoration(
                          labelText: 'Secret Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveKeys,
                      child: Text('บันทึก'),
                    ),
                  ],
                ),
              ),
              Container(
                height: 300,
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "หุ้นไทย",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.transparent,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: const BoxDecoration(
                                    
                                    shape: BoxShape.circle),
                                child: Padding(
                                  //this padding will be you border size
                                  padding: const EdgeInsets.all(3.5),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      foregroundImage:
                                          AssetImage("assets/img/thaiflag.png"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius:
                              BorderRadius.circular(20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius:
                              BorderRadius.circular(20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _secretKeyController,
                        decoration: InputDecoration(
                          labelText: 'Secret Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: _saveKeys,
                      child: Text('บันทึก'),
                    ),
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
