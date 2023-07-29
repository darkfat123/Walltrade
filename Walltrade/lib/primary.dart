import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE4E5E7),
  100: Color(0xFFBCBDC3),
  200: Color(0xFF90929B),
  300: Color(0xFF646672),
  400: Color(0xFF424554),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF1D2030),
  700: Color(0xFF181B29),
  800: Color(0xFF141622),
  900: Color(0xFF0B0D16),
});
const int _primaryPrimaryValue = 0xFF212436;

const MaterialColor primaryAccent = MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF5971FF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF0023F2),
  700: Color(0xFF001FD9),
});
const int _primaryAccentValue = 0xFF2645FF;