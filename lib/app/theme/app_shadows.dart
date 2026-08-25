import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const card = BoxShadow(
    blurRadius: 24,
    offset: Offset(0, 10),
    spreadRadius: -4,
    color: Color(0x12000000),
  );
}
