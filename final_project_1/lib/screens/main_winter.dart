import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'homescreen_winter.dart';

const String _apiBase = 'http://localhost:3000';
final ApiService apiService = ApiService(baseUrl: _apiBase);

class NotivaColors {
  static const bgTop = Color(0xFF002B45);
  static const bgBottom = Color(0xFF1A3E5D);
  static const panel = Color(0xFFEAF6F9);
  static const panelBorder = Color(0xFF4169E1);
  static const glacial = Color(0xFF4169E1);
  static const buttonTop = Color(0xFF7FB8D9);
  static const buttonBottom = Color(0xFF4169E1);
  static const shadow = Color(0x554B5A6A);
}
