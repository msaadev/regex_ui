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

  /// Contains [count] or more uppercase letters (any language).
  factory RegexModel.uppercase({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\p{Lu}', unicode: true),
        title ??
            (count == 1
                ? 'One uppercase letter'
                : 'At least $count uppercase letters'),
      );

  /// Contains [count] or more lowercase letters (any language).
  factory RegexModel.lowercase({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\p{Ll}', unicode: true),
        title ??
            (count == 1
                ? 'One lowercase letter'
                : 'At least $count lowercase letters'),
      );

  /// Contains [count] or more digits.
  factory RegexModel.digit({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\d'),
        title ?? (count == 1 ? 'One number' : 'At least $count numbers'),
      );

  /// Contains [count] or more characters that are not a letter, digit or
  /// space.
  factory RegexModel.special({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
        title ??
            (count == 1
                ? 'One special character'
                : 'At least $count special characters'),
      );

  factory RegexModel._atLeast(int count, RegExp kind, String title) =>
      RegexModel(
        title: title,
        test: (value) => kind.allMatches(value).length >= count,
      );

  // No regex needed: rules in plain words.

  /// Between [min] and [max] characters, e.g. a user name of 3–20.
  factory RegexModel.lengthBetween(int min, int max, {String? title}) =>
      RegexModel(
        title: title ?? '$min to $max characters',
        test: (value) => value.length >= min && value.length <= max,
      );

  /// Exactly [length] characters, e.g. a 6-digit code.
  factory RegexModel.exactLength(int length, {String? title}) => RegexModel(
    title: title ?? 'Exactly $length characters',
    test: (value) => value.length == length,
  );

  /// Only letters (any language), plus the characters in [allow].
  /// `RegexModel.lettersOnly(allow: ' -')` also accepts spaces and dashes.
  factory RegexModel.lettersOnly({String allow = '', String? title}) =>
      RegexModel._only(
        r'\p{L}',
        allow,
        title ?? _onlyTitle('Only letters', allow),
      );

  /// Only digits 0–9, plus the characters in [allow].
  factory RegexModel.digitsOnly({String allow = '', String? title}) =>
      RegexModel._only(
        r'0-9',
        allow,
        title ?? _onlyTitle('Only numbers', allow),
      );

  /// Only letters and digits, plus the characters in [allow].
  /// `RegexModel.lettersAndDigits(allow: '_.')` for user names.
  factory RegexModel.lettersAndDigits({String allow = '', String? title}) =>
      RegexModel._only(
        r'\p{L}\p{N}',
        allow,
        title ?? _onlyTitle('Only letters and numbers', allow),
      );

  // Characters in [allow] are escaped here, so callers never write regex.
  factory RegexModel._only(String kinds, String allow, String title) {
    final extra = allow
        .split('')
        .map((c) => '\\u{${c.runes.first.toRadixString(16)}}')
        .join();
    final only = RegExp('^[$kinds$extra]+\$', unicode: true);
    return RegexModel(title: title, test: only.hasMatch);
  }

  static String _onlyTitle(String base, String allow) => allow.isEmpty
      ? base
      : '$base, plus: ${allow.split('').map((c) => c == ' ' ? 'space' : c).join(', ')}';

  /// Starts with [text], e.g. `startsWith('TR')` for an IBAN.
  factory RegexModel.startsWith(
    String text, {
    bool ignoreCase = false,
    String? title,
  }) => RegexModel(
    title: title ?? 'Starts with "$text"',
    test: (value) => ignoreCase
        ? value.toLowerCase().startsWith(text.toLowerCase())
        : value.startsWith(text),
  );

  /// Ends with [text], e.g. `endsWith('@company.com')`.
  factory RegexModel.endsWith(
    String text, {
    bool ignoreCase = true,
    String? title,
  }) => RegexModel(
    title: title ?? 'Ends with "$text"',
    test: (value) => ignoreCase
        ? value.toLowerCase().endsWith(text.toLowerCase())
        : value.endsWith(text),
  );

  /// Contains [text] somewhere.
  factory RegexModel.contains(
    String text, {
    bool ignoreCase = true,
    String? title,
  }) => RegexModel(
    title: title ?? 'Contains "$text"',
    test: (value) => ignoreCase
        ? value.toLowerCase().contains(text.toLowerCase())
        : value.contains(text),
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

  /// Ready password rules: length, upper, lower, number, special character.
  static List<RegexModel> passwordRules({int minLength = 8}) => [
    RegexModel.minLength(minLength),
    RegexModel.uppercase(),
    RegexModel.lowercase(),
    RegexModel.digit(),
    RegexModel.special(),
  ];

  /// Ready user name rules: 3–20 letters, numbers or `_`, no spaces.
  static List<RegexModel> userNameRules({
    int minLength = 3,
    int maxLength = 20,
  }) => [
    RegexModel.minLength(minLength),
    RegexModel.maxLength(maxLength),
    RegexModel.lettersAndDigits(allow: '_'),
  ];

  /// Ready e-mail rules.
  static List<RegexModel> emailRules() => [RegexModel.email()];

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
