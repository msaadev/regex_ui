import 'package:flutter/material.dart';

/// One rule shown by `RegexUI`: a title and a check (a [RegExp] or a function).
class RegexModel {
  /// Text shown next to the check mark, e.g. "At least 8 characters".
  final String title;

  /// Pattern the input must match. Either this or [test] is required.
  final RegExp? regExp;

  /// Custom check, used instead of [regExp].
  final bool Function(String value)? test;

  /// Icon when the rule is met / not met. Overrides the `RegexUI` defaults.
  final IconData? iconTrue, iconFalse;

  /// Badge color when the rule is met / not met.
  final Color? colorTrue, colorFalse;

  /// Text color when the rule is met / not met.
  final Color? textColorTrue, textColorFalse;

  /// Text style of [title].
  final TextStyle? textStyle;

  /// Creates a rule from a [regExp] or a [test] function.
  RegexModel({
    required this.title,
    this.regExp,
    this.test,
    this.iconTrue,
    this.iconFalse,
    this.colorTrue,
    this.colorFalse,
    this.textColorTrue,
    this.textColorFalse,
    this.textStyle,
  }) : assert(regExp != null || test != null, 'Pass a regExp or a test');

  /// At least [length] characters.
  factory RegexModel.minLength(int length, {String? title}) => RegexModel(
    title: title ?? 'At least $length characters',
    test: (value) => value.length >= length,
  );

  /// Contains an uppercase letter (any language).
  factory RegexModel.uppercase({String title = 'One uppercase letter'}) =>
      RegexModel(title: title, regExp: RegExp(r'\p{Lu}', unicode: true));

  /// Contains a lowercase letter (any language).
  factory RegexModel.lowercase({String title = 'One lowercase letter'}) =>
      RegexModel(title: title, regExp: RegExp(r'\p{Ll}', unicode: true));

  /// Contains a digit.
  factory RegexModel.digit({String title = 'One number'}) =>
      RegexModel(title: title, regExp: RegExp(r'\d'));

  /// Contains a character that is not a letter, digit or space.
  factory RegexModel.special({String title = 'One special character'}) =>
      RegexModel(
        title: title,
        regExp: RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
      );

  /// Contains no whitespace.
  factory RegexModel.noSpaces({String title = 'No spaces'}) => RegexModel(
    title: title,
    test: (value) => value.isNotEmpty && !value.contains(RegExp(r'\s')),
  );

  /// Looks like an e-mail address.
  factory RegexModel.email({String title = 'Valid e-mail address'}) =>
      RegexModel(title: title, regExp: RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'));

  /// Whether [value] meets this rule.
  bool matches(String value) => test?.call(value) ?? regExp!.hasMatch(value);
}
