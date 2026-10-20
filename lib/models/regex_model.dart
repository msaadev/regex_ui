import 'package:flutter/material.dart';

import 'regex_char.dart';
import 'regex_labels.dart';

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
    title: title ?? RegexLabels.current.minLength(length),
    test: (value) => value.runes.length >= length,
  );

  /// Contains [count] or more uppercase letters (any language).
  factory RegexModel.uppercase({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\p{Lu}', unicode: true),
        title ?? RegexLabels.current.uppercase(count),
      );

  /// Contains [count] or more lowercase letters (any language).
  factory RegexModel.lowercase({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\p{Ll}', unicode: true),
        title ?? RegexLabels.current.lowercase(count),
      );

  /// Contains [count] or more digits.
  factory RegexModel.digit({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'\d'),
        title ?? RegexLabels.current.digit(count),
      );

  /// Contains [count] or more characters that are not a letter, digit or
  /// space.
  factory RegexModel.special({int count = 1, String? title}) =>
      RegexModel._atLeast(
        count,
        RegExp(r'[^\p{L}\p{N}\s]', unicode: true),
        title ?? RegexLabels.current.special(count),
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
        title: title ?? RegexLabels.current.lengthBetween(min, max),
        test: (value) {
          final n = value.runes.length;
          return n >= min && n <= max;
        },
      );

  /// Exactly [length] characters, e.g. a 6-digit code.
  factory RegexModel.exactLength(int length, {String? title}) => RegexModel(
    title: title ?? RegexLabels.current.exactLength(length),
    test: (value) => value.runes.length == length,
  );

  /// Only the character groups in [chars], plus the characters in [allow]:
  /// `RegexModel.allowOnly([RegexChar.letters, RegexChar.whitespace])`.
  factory RegexModel.allowOnly(
    List<RegexChar> chars, {
    String allow = '',
    String? title,
  }) {
    assert(chars.isNotEmpty || allow.isNotEmpty, 'Pass chars or allow');
    final special = chars.contains(RegexChar.special);
    final normal = chars.where((c) => c != RegexChar.special);
    final cls = '[${normal.map((c) => c.pattern).join()}${_escape(allow)}]';
    // Special = not a letter, digit or space; joined with an alternation as it is a negated class.
    final one = special ? '(?:$cls|[${RegexChar.special.pattern}])' : cls;
    final only = RegExp('^$one+\$', unicode: true);
    return RegexModel(
      title: title ?? RegexLabels.current.only(_words(chars, allow)),
      test: only.hasMatch,
    );
  }

  /// None of the character groups in [chars] and none of the characters in
  /// [allow]: `RegexModel.notAllowed([RegexChar.whitespace, RegexChar.dot])`.
  factory RegexModel.notAllowed(
    List<RegexChar> chars, {
    String allow = '',
    String? title,
  }) {
    final banned = RegexModel.allowOnly(chars, allow: allow);
    return RegexModel(
      title: title ?? RegexLabels.current.none(_words(chars, allow)),
      test: (value) =>
          !value.runes.any((r) => banned.matches(String.fromCharCode(r))),
    );
  }

  /// Only letters (any language), plus [allowList] groups and [allow]
  /// characters: `RegexModel.lettersOnly(allowList: [RegexChar.whitespace])`.
  factory RegexModel.lettersOnly({
    List<RegexChar> allowList = const [],
    String allow = '',
    String? title,
  }) => RegexModel.allowOnly(
    [RegexChar.letters, ...allowList],
    allow: allow,
    title: title,
  );

  /// Only digits 0–9, plus [allowList] groups and [allow] characters.
  factory RegexModel.digitsOnly({
    List<RegexChar> allowList = const [],
    String allow = '',
    String? title,
  }) => RegexModel.allowOnly(
    [RegexChar.digits, ...allowList],
    allow: allow,
    title: title,
  );

  /// Only letters and digits, plus [allowList] groups and [allow] characters:
  /// `RegexModel.lettersAndDigits(allowList: [RegexChar.underscore])`.
  factory RegexModel.lettersAndDigits({
    List<RegexChar> allowList = const [],
    String allow = '',
    String? title,
  }) => RegexModel.allowOnly(
    [RegexChar.letters, RegexChar.digits, ...allowList],
    allow: allow,
    title: title,
  );

  // Characters in [allow] are escaped here, so callers never write regex.
  static String _escape(String allow) =>
      allow.runes.map((r) => '\\u{${r.toRadixString(16)}}').join();

  static String _words(List<RegexChar> chars, String allow) {
    final labels = RegexLabels.current;
    return labels.join([
      for (final c in chars) labels.char(c),
      for (final c in allow.split('')) c == ' ' ? labels.space : c,
    ]);
  }

  /// Starts with [text], e.g. `startsWith('TR')` for an IBAN.
  factory RegexModel.startsWith(
    String text, {
    bool ignoreCase = false,
    String? title,
  }) => RegexModel(
    title: title ?? RegexLabels.current.startsWith(text),
    test: (value) => ignoreCase
        ? value.toLowerCase().startsWith(text.toLowerCase())
        : value.startsWith(text),
  );

  /// Does not start with [text], e.g. `notStartsWith('0')` for an ID number.
  factory RegexModel.notStartsWith(String text, {String? title}) => RegexModel(
    title: title ?? RegexLabels.current.notStartsWith(text),
    test: (value) => !value.startsWith(text),
  );

  /// Ends with [text], e.g. `endsWith('@company.com')`.
  factory RegexModel.endsWith(
    String text, {
    bool ignoreCase = true,
    String? title,
  }) => RegexModel(
    title: title ?? RegexLabels.current.endsWith(text),
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
    title: title ?? RegexLabels.current.contains(text),
    test: (value) => ignoreCase
        ? value.toLowerCase().contains(text.toLowerCase())
        : value.contains(text),
  );

  /// Contains no whitespace.
  factory RegexModel.noSpaces({String? title}) => RegexModel(
    title: title ?? RegexLabels.current.noSpaces,
    test: (value) => !value.contains(RegExp(r'\s')),
  );

  /// Looks like an e-mail address.
  factory RegexModel.email({String? title}) => RegexModel(
    title: title ?? RegexLabels.current.email,
    regExp: RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  );

  /// At most [length] characters.
  factory RegexModel.maxLength(int length, {String? title}) => RegexModel(
    title: title ?? RegexLabels.current.maxLength(length),
    test: (value) => value.runes.length <= length,
  );

  /// Equals the text of [other], e.g. "repeat password".
  factory RegexModel.sameAs(TextEditingController other, {String? title}) =>
      RegexModel(
        title: title ?? RegexLabels.current.sameAs,
        test: (value) => value == other.text,
      );

  /// Does not contain any word of [text] (3+ letters), ignoring case and
  /// accents: with the name "Ali-Can Yılmaz", "yilmaz123" fails.
  /// `RegexModel.notContains(() => fullName.text)`.
  factory RegexModel.notContains(String Function() text, {String? title}) =>
      RegexModel(
        title: title ?? RegexLabels.current.notContains,
        test: (value) {
          final plain = _fold(value);
          return !_fold(text())
              .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
              .any((word) => word.length >= 3 && plain.contains(word));
        },
      );

  // shortcut: folds common Latin accents only, enough for names in passwords.
  static final Map<int, int> _accents = () {
    const from = 'àáâãäåçćèéêëìíîïıñòóôõöşśùúûüğýÿž';
    const to = 'aaaaaacceeeeiiiiinooooossuuuugyyz';
    final keys = from.runes.toList();
    return {for (var i = 0; i < keys.length; i++) keys[i]: to.codeUnitAt(i)};
  }();

  static String _fold(String text) => String.fromCharCodes(
    text.toLowerCase().replaceAll('i̇', 'i').runes.map((r) => _accents[r] ?? r),
  );

  /// No character [count] or more times in a row ("aaa" for 3).
  factory RegexModel.noRepeating({int count = 3, String? title}) {
    assert(count >= 2, 'count must be at least 2');
    final repeat = RegExp('(.)\\1{${count - 1}}');
    return RegexModel(
      title: title ?? RegexLabels.current.noRepeating(count),
      test: (value) => !repeat.hasMatch(value),
    );
  }

  /// Looks like a phone number: optional +, 7–15 digits, spaces, dashes,
  /// dots or parentheses.
  factory RegexModel.phone({String? title}) => RegexModel(
    title: title ?? RegexLabels.current.phone,
    test: (value) {
      if (!RegExp(r'^\+?[\d\s\-().]+$').hasMatch(value.trim())) {
        return false;
      }
      final digits = value.replaceAll(RegExp(r'\D'), '').length;
      return digits >= 7 && digits <= 15;
    },
  );

  /// A valid IBAN: country length and check digits (mod 97). Spaces and
  /// lowercase are fine, as people paste "TR33 0006 1005 …". Pass [country]
  /// (e.g. 'TR') to accept only that country.
  factory RegexModel.iban({String? country, String? title}) => RegexModel(
    title: title ?? RegexLabels.current.iban,
    test: (value) => _isIban(value, country),
  );

  static bool _isIban(String value, String? country) {
    final iban = value.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]{11,30}$').hasMatch(iban)) return false;
    final code = iban.substring(0, 2);
    if (country != null && code != country.toUpperCase()) return false;
    final length = _ibanLengths[code];
    if (length != null && iban.length != length) return false;
    var rest = 0;
    for (final r in (iban.substring(4) + iban.substring(0, 4)).runes) {
      final n = r < 65 ? r - 48 : r - 55; // 0–9 → 0–9, A–Z → 10–35
      rest = (n > 9 ? rest * 100 + n : rest * 10 + n) % 97;
    }
    return rest == 1;
  }

  // shortcut: lengths of common IBAN countries; others get the checksum only.
  static const _ibanLengths = {
    'AD': 24,
    'AE': 23,
    'AT': 20,
    'AZ': 28,
    'BA': 20,
    'BE': 16,
    'BG': 22,
    'BH': 22,
    'CH': 21,
    'CY': 28,
    'CZ': 24,
    'DE': 22,
    'DK': 18,
    'EE': 20,
    'EG': 29,
    'ES': 24,
    'FI': 18,
    'FR': 27,
    'GB': 22,
    'GE': 22,
    'GR': 27,
    'HR': 21,
    'HU': 28,
    'IE': 22,
    'IL': 23,
    'IS': 26,
    'IT': 27,
    'JO': 30,
    'KW': 30,
    'KZ': 20,
    'LB': 28,
    'LI': 21,
    'LT': 20,
    'LU': 20,
    'LV': 21,
    'MC': 27,
    'ME': 22,
    'MK': 19,
    'MT': 31,
    'NL': 18,
    'NO': 15,
    'PK': 24,
    'PL': 28,
    'PT': 25,
    'QA': 29,
    'RO': 24,
    'RS': 22,
    'SA': 24,
    'SE': 24,
    'SI': 19,
    'SK': 24,
    'SM': 27,
    'TR': 26,
    'UA': 29,
  };

  /// An http or https address with a domain, e.g. https://monsware.com.
  factory RegexModel.url({String? title}) => RegexModel(
    title: title ?? RegexLabels.current.url,
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
    RegexModel.lettersAndDigits(allowList: [RegexChar.underscore]),
  ];

  /// Ready e-mail rules.
  static List<RegexModel> emailRules() => [RegexModel.email()];

  /// Whether [value] meets this rule. Empty input never does, so nothing is
  /// ticked before the user types (e.g. `^\w*\$` or `maxLength`).
  bool matches(String value) =>
      value.isNotEmpty && (test?.call(value) ?? regExp!.hasMatch(value));

  /// A `TextFormField.validator` that returns the first unmet rule's title,
  /// so `Form.validate()` checks the same rules as the checklist. Empty is
  /// "Required", or fine when [optional].
  static String? Function(String?) validator(
    List<RegexModel> rules, {
    bool optional = false,
  }) => (value) {
    if ((value ?? '').isEmpty) {
      return optional ? null : RegexLabels.current.required;
    }
    for (final rule in rules) {
      if (!rule.matches(value!)) return rule.title;
    }
    return null;
  };

  /// Whether [value] meets every rule; empty is valid only when [optional].
  static bool allMet(
    List<RegexModel> rules,
    String value, {
    bool optional = false,
  }) =>
      (optional && value.isEmpty) || rules.every((rule) => rule.matches(value));
}
