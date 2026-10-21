/// Common character groups for `RegexModel.allowOnly`, `RegexModel.notAllowed`
/// and the `allowList` of the "only" rules. Pick them instead of writing regex.
enum RegexChar {
  /// Letters of any language (a, ş, ä, é, …).
  letters(r'\p{L}', 'letters'),

  /// English letters a–z and A–Z only.
  englishLetters('a-zA-Z', 'English letters'),

  /// Uppercase letters of any language.
  uppercase(r'\p{Lu}', 'uppercase letters'),

  /// Lowercase letters of any language.
  lowercase(r'\p{Ll}', 'lowercase letters'),

  /// Digits 0–9.
  digits('0-9', 'numbers'),

  /// Spaces, tabs and line breaks.
  whitespace(r'\s', 'spaces'),

  /// `_`
  underscore('_', '_'),

  /// `-`
  dash(r'\-', '-'),

  /// `.`
  dot(r'\.', '.'),

  /// `@`
  at('@', '@'),

  /// `+`
  plus(r'\+', '+'),

  /// `,`
  comma(',', ','),

  /// `'`
  apostrophe("'", "'"),

  /// `/`
  slash(r'\/', '/'),

  /// Anything that is not a letter, digit or space (!, #, €, …).
  special(r'^\p{L}\p{N}\s', 'special characters');

  const RegexChar(this.pattern, this.label);

  /// Character class body; [special] is a negated class and is handled apart.
  final String pattern;

  /// Word used in automatic rule titles.
  final String label;
}
