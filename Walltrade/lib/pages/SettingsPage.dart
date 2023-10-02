import 'dart:io';

import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';
import 'package:Walltrade/primary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../variables/serverURL.dart';
import 'FirebaseAuth/auth.dart';

class Settings extends StatefulWidget {
  final String username;

  Settings({required this.username});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController _apiKeyController = TextEditingController();
  TextEditingController _secretKeyController = TextEditingController();
  TextEditingController _THapiKeyController = TextEditingController();
  TextEditingController _THsecretKeyController = TextEditingController();

  Future<void> saveUSalpacaAPI() async {
    String apiKey = _apiKeyController.text;
    String secretKey = _secretKeyController.text;

    // Send the API key and secret key to the Flask server
    String url =
        '${Constants.serverUrl}/updateUSalpacaAPI'; // เปลี่ยนเป็น URL ของ Flask server ที่ใช้งาน

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

  Future<void> saveTHsettradeAPI() async {
    String thapiKey = _THapiKeyController.text;
    String thsecretKey = _THsecretKeyController.text;

    // Send the API key and secret key to the Flask server
    String url =
        '${Constants.serverUrl}/updateTHsettradeAPI'; // เปลี่ยนเป็น URL ของ Flask server ที่ใช้งาน

    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    Map<String, String> body = {
      'th_api_key': thapiKey,
      'th_secret_key': thsecretKey,
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

  PlatformFile? pickedFile;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    setState(() {
      pickedFile = result?.files.first;
    });
  }

  UploadTask? uploadTask;
  Future uploadFile() async {
    final path = "files/${pickedFile!.name}";
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Widget buildProgress() {
    return StreamBuilder(
        stream: uploadTask?.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            double progress = data.bytesTransferred / data.totalBytes;
            return SizedBox(
              height: 50,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey,
                    color: primary,
                  ),
                  Center(
                    child: Text("${(100 * progress).roundToDouble()}%"),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox(
              height: 50,
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('การตั้งค่า'),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                /*Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "เปลี่ยนรูปโปรไฟล์",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                      SizedBox(height: 30),
                      if (pickedFile != null)
                        Expanded(
                          child: Image.file(
                            File(pickedFile!.path!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ElevatedButton(
                          onPressed: () => selectFile(),
                          child: Text("เลือกรูปภาพ")),
                      ElevatedButton(
                          onPressed: () => uploadFile(), child: Text("ตกลง")),
                    ],
                  ),
                ),*/
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "หุ้นอเมริกา",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundImage:
                                    AssetImage("assets/img/usflag.png"),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'Alpaca API Key (US)',
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
                          prefixIcon: const Icon(Icons.vpn_key),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _secretKeyController,
                        decoration: InputDecoration(
                          labelText: 'Alpaca Secret Key (US)',
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
                          prefixIcon: const Icon(Icons.key_rounded),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: saveUSalpacaAPI,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('บันทึก'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "หุ้นไทย",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle),
                              child: const CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundImage:
                                    AssetImage("assets/img/thaiflag.png"),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: _THapiKeyController,
                        decoration: InputDecoration(
                          labelText: 'Settrade API Key (TH)',
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
                          prefixIcon: const Icon(Icons.vpn_key),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _THsecretKeyController,
                        decoration: InputDecoration(
                          labelText: 'Settrade Secret Key (TH)',
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
                          prefixIcon: const Icon(Icons.key_rounded),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: saveTHsettradeAPI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('บันทึก'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7E1717),
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      signOut().then((value) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          )));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "ออกจากระบบ",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
