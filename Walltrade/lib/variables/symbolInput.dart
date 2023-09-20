import 'package:flutter/foundation.dart';

class Data extends ChangeNotifier {
  String _text = '';

  String get text => _text;

  set text(String value) {
    _text = value;
    notifyListeners(); // อัปเดตสถานะและ rebuild หน้าจอที่เกี่ยวข้อง
  }
}