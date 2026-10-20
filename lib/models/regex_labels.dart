import 'regex_char.dart';

part 'regex_labels_built_in.dart';

/// Every text regex_ui writes by itself: rule titles, [RegexChar] names,
/// screen reader words, strength labels and field labels.
///
/// Set your language once, before the rules are built (e.g. in `main`).
/// Pass only what you change; the rest stays English:
///
/// ```dart
/// RegexLabels.current = RegexLabels(
///   minLength: (n) => '$n文字以上',
///   chars: {RegexChar.whitespace: 'スペース', RegexChar.digits: '数字'},
///   only: (list) => '$listのみ',
///   join: (words) => words.join('、'),
/// );
/// ```
///
/// Ready languages: [en], [tr], [de], [es], [fr], [it], [pt], [ja]:
/// `RegexLabels.current = RegexLabels.tr;` or, from the device language,
/// `RegexLabels.forLanguage(locale.languageCode)`. Change a few words of a
/// ready language with [copyWith].
///
/// One rule only? Pass `title:` to that rule instead.
class RegexLabels {
  /// The labels used by every rule and widget. English by default.
  static RegexLabels current = en;

  static const en = RegexLabels();
  static const tr = _tr;
  static const de = _de;
  static const es = _es;
  static const fr = _fr;
  static const it = _it;
  static const pt = _pt;
  static const ja = _ja;

  /// Ready languages by language code.
  static const builtIn = <String, RegexLabels>{
    'en': en,
    'tr': tr,
    'de': de,
    'es': es,
    'fr': fr,
    'it': it,
    'pt': pt,
    'ja': ja,
  };

  /// The ready labels for [languageCode] (e.g. "tr", "ja-JP"), English when
  /// that language is not built in.
  static RegexLabels forLanguage(String languageCode) =>
      builtIn[languageCode.split(RegExp('[-_]')).first.toLowerCase()] ?? en;

  final String Function(int length) minLength;
  final String Function(int length) maxLength;
  final String Function(int min, int max) lengthBetween;
  final String Function(int length) exactLength;
  final String Function(int count) uppercase;
  final String Function(int count) lowercase;
  final String Function(int count) digit;
  final String Function(int count) special;
  final String Function(int count) noRepeating;
  final String Function(String text) startsWith;
  final String Function(String text) endsWith;
  final String Function(String text) contains;

  /// Title of `allowOnly` and the "only" rules; [list] is built by [join].
  final String Function(String list) only;

  /// Title of `notAllowed`; [list] is built by [join].
  final String Function(String list) none;

  /// Joins character names into one phrase: "letters, numbers and _".
  final String Function(List<String> words) join;

  /// Names of the [RegexChar] groups you want to change; the others keep
  /// their English name.
  final Map<RegexChar, String> chars;

  /// Name of a space passed in `allow:`.
  final String space;

  final String noSpaces;
  final String email;
  final String phone;
  final String url;
  final String sameAs;
  final String notContains;

  /// Screen reader words for a met / not met rule.
  final String met, unmet;

  /// Password strength words, weakest first.
  final List<String> strength;

  /// Show / hide password button.
  final String show, hide;

  /// Labels of `RegexTextField.password`, `.email` and `.userName`.
  final String passwordField, emailField, userNameField;

  /// Creates labels; anything left out stays English.
  const RegexLabels({
    this.minLength = _minLength,
    this.maxLength = _maxLength,
    this.lengthBetween = _lengthBetween,
    this.exactLength = _exactLength,
    this.uppercase = _uppercase,
    this.lowercase = _lowercase,
    this.digit = _digit,
    this.special = _special,
    this.noRepeating = _noRepeating,
    this.startsWith = _startsWith,
    this.endsWith = _endsWith,
    this.contains = _contains,
    this.only = _only,
    this.none = _none,
    this.join = _join,
    this.chars = const {},
    this.space = 'spaces',
    this.noSpaces = 'No spaces',
    this.email = 'Valid e-mail address',
    this.phone = 'Valid phone number',
    this.url = 'Valid web address',
    this.sameAs = 'Passwords match',
    this.notContains = 'Does not contain your name',
    this.met = 'met',
    this.unmet = 'not met',
    this.strength = const ['Very weak', 'Weak', 'Fair', 'Good', 'Strong'],
    this.show = 'Show',
    this.hide = 'Hide',
    this.passwordField = 'Password',
    this.emailField = 'E-mail',
    this.userNameField = 'User name',
  });

  /// A copy with the given texts changed; [chars] entries are merged.
  RegexLabels copyWith({
    String Function(int length)? minLength,
    String Function(int length)? maxLength,
    String Function(int min, int max)? lengthBetween,
    String Function(int length)? exactLength,
    String Function(int count)? uppercase,
    String Function(int count)? lowercase,
    String Function(int count)? digit,
    String Function(int count)? special,
    String Function(int count)? noRepeating,
    String Function(String text)? startsWith,
    String Function(String text)? endsWith,
    String Function(String text)? contains,
    String Function(String list)? only,
    String Function(String list)? none,
    String Function(List<String> words)? join,
    Map<RegexChar, String>? chars,
    String? space,
    String? noSpaces,
    String? email,
    String? phone,
    String? url,
    String? sameAs,
    String? notContains,
    String? met,
    String? unmet,
    List<String>? strength,
    String? show,
    String? hide,
    String? passwordField,
    String? emailField,
    String? userNameField,
  }) => RegexLabels(
    minLength: minLength ?? this.minLength,
    maxLength: maxLength ?? this.maxLength,
    lengthBetween: lengthBetween ?? this.lengthBetween,
    exactLength: exactLength ?? this.exactLength,
    uppercase: uppercase ?? this.uppercase,
    lowercase: lowercase ?? this.lowercase,
    digit: digit ?? this.digit,
    special: special ?? this.special,
    noRepeating: noRepeating ?? this.noRepeating,
    startsWith: startsWith ?? this.startsWith,
    endsWith: endsWith ?? this.endsWith,
    contains: contains ?? this.contains,
    only: only ?? this.only,
    none: none ?? this.none,
    join: join ?? this.join,
    chars: {...this.chars, ...?chars},
    space: space ?? this.space,
    noSpaces: noSpaces ?? this.noSpaces,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    url: url ?? this.url,
    sameAs: sameAs ?? this.sameAs,
    notContains: notContains ?? this.notContains,
    met: met ?? this.met,
    unmet: unmet ?? this.unmet,
    strength: strength ?? this.strength,
    show: show ?? this.show,
    hide: hide ?? this.hide,
    passwordField: passwordField ?? this.passwordField,
    emailField: emailField ?? this.emailField,
    userNameField: userNameField ?? this.userNameField,
  );

  /// Name of [char]: yours from [chars], or the English one.
  String char(RegexChar char) => chars[char] ?? char.label;

  static String _minLength(int n) => 'At least $n characters';
  static String _maxLength(int n) => 'At most $n characters';
  static String _lengthBetween(int min, int max) => '$min to $max characters';
  static String _exactLength(int n) => 'Exactly $n characters';
  static String _uppercase(int n) =>
      n == 1 ? 'One uppercase letter' : 'At least $n uppercase letters';
  static String _lowercase(int n) =>
      n == 1 ? 'One lowercase letter' : 'At least $n lowercase letters';
  static String _digit(int n) => n == 1 ? 'One number' : 'At least $n numbers';
  static String _special(int n) =>
      n == 1 ? 'One special character' : 'At least $n special characters';
  static String _noRepeating(int n) => 'No character $n times in a row';
  static String _startsWith(String text) => 'Starts with "$text"';
  static String _endsWith(String text) => 'Ends with "$text"';
  static String _contains(String text) => 'Contains "$text"';
  static String _only(String list) => 'Only $list';
  static String _none(String list) => 'No $list';
  static String _join(List<String> words) => words.length == 1
      ? words.first
      : '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';
}
