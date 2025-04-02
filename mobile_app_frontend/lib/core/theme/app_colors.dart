import 'package:flutter/material.dart';

class AppColors {
  // Neutral Colors
  static const Color neutral600 = Color(0xFF011112);
  static const Color neutral500 = Color(0xFF1A1A1C);
  static const Color neutral450 = Color(0xFF302E31);
  static const Color neutral400 = Color(0xFF252325);
  static const Color neutral300 = Color(0xFF5A5A5C);
  static const Color neutral200 = Color(0xFF909091);
  static const Color neutral150 = Color(0xFFBFBFBF);
  static const Color neutral100 = Color(0xFFE9E9EA);

  // Primary Colors
  static const Color primary300 = Color(0xFF1D4780);
  static const Color primary200 = Color(0xFF275FEB);
  static const Color primary100 = Color(0xFF5D87F0);

  // State Colors as a Map
  static const Map<String, Color> states = {
    'overdue': Color(0xFFD40000),
    'error': Color(0xFFCC0202),
    'completed': Color(0xFF2B2A45),
    'ok': Color(0xFF4CAF50),
    'scheduled': Color(0xFF007BFF),
    'inProgress': Color(0xFF17A2B8),
    'upcoming': Color(0xFFFFBF00),
    'canceled': Color(0xFF6C757D),
  };
}
