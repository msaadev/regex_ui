import 'package:flutter/material.dart';

class RegexModel {
  final String title;
  final RegExp regExp;
  final IconData? iconTrue, iconFalse;
  final Color? colorTrue, colorFalse, textColorTrue, textColorFalse;
  final TextStyle? textStyle;

  RegexModel(
      {required this.title,
      required this.regExp,
      this.iconTrue,
      this.iconFalse,
      this.colorTrue,
      this.colorFalse,
      this.textColorTrue,
      this.textColorFalse,
      this.textStyle});
}
