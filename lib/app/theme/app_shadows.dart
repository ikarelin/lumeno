import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const card = BoxShadow(
    blurRadius: 20,
    offset: Offset(0, 8),
    spreadRadius: 0,
    color: Color(0x14000000),
  );
}
