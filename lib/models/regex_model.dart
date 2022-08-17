import 'package:flutter/material.dart';

class RegexModel {
  final String title;
  final RegExp regExp;
  final IconData iconTrue, iconFalse;
  final Color colorTrue, colorFalse;

  RegexModel({
    required this.title,
    required this.regExp,
    this.iconTrue = Icons.check,
    this.iconFalse = Icons.clear,
    this.colorTrue = Colors.green,
    this.colorFalse = Colors.red,
  });
}
