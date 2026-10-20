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
  factory RegexModel.noSpaces({String title = 'No spaces'}) =>
      RegexModel(title: title, test: (value) => !value.contains(RegExp(r'\s')));

  /// Looks like an e-mail address.
  factory RegexModel.email({String title = 'Valid e-mail address'}) =>
      RegexModel(title: title, regExp: RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'));

  /// At most [length] characters.
  factory RegexModel.maxLength(int length, {String? title}) => RegexModel(
    title: title ?? 'At most $length characters',
    test: (value) => value.length <= length,
  );

  /// Equals the text of [other], e.g. "repeat password".
  factory RegexModel.sameAs(
    TextEditingController other, {
    String title = 'Passwords match',
  }) => RegexModel(title: title, test: (value) => value == other.text);

  /// Does not contain [text] (case-insensitive), e.g. the user name:
  /// `RegexModel.notContains(() => userName.text)`.
  factory RegexModel.notContains(
    String Function() text, {
    String title = 'Does not contain your name',
  }) => RegexModel(
    title: title,
    test: (value) {
      final part = text().trim().toLowerCase();
      return (part.isEmpty || !value.toLowerCase().contains(part));
    },
  );

  /// No character [count] or more times in a row ("aaa" for 3).
  factory RegexModel.noRepeating({int count = 3, String? title}) {
    assert(count >= 2, 'count must be at least 2');
    final repeat = RegExp('(.)\\1{${count - 1}}');
    return RegexModel(
      title: title ?? 'No character $count times in a row',
      test: (value) => !repeat.hasMatch(value),
    );
  }

  /// Looks like a phone number: optional +, 7–15 digits, spaces, dashes,
  /// dots or parentheses.
  factory RegexModel.phone({String title = 'Valid phone number'}) => RegexModel(
    title: title,
    test: (value) {
      if (!RegExp(r'^\+?[\d\s\-().]+$').hasMatch(value.trim())) {
        return false;
      }
      final digits = value.replaceAll(RegExp(r'\D'), '').length;
      return digits >= 7 && digits <= 15;
    },
  );

  /// An http or https address with a domain, e.g. https://monsware.com.
  factory RegexModel.url({String title = 'Valid web address'}) => RegexModel(
    title: title,
    test: (value) {
      final uri = Uri.tryParse(value.trim());
      return uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.contains('.');
    },
  );

  /// Whether [value] meets this rule. Empty input never does, so nothing is
  /// ticked before the user types (e.g. `^\w*\$` or `maxLength`).
  bool matches(String value) =>
      value.isNotEmpty && (test?.call(value) ?? regExp!.hasMatch(value));

  /// A `TextFormField.validator` that returns the first unmet rule's title,
  /// so `Form.validate()` checks the same rules as the checklist.
  static String? Function(String?) validator(List<RegexModel> rules) =>
      (value) {
        for (final rule in rules) {
          if (!rule.matches(value ?? '')) return rule.title;
        }
        return null;
      };
}
