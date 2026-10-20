import 'dart:math' as math;

const _common = {
  'password',
  'passw0rd',
  '123456',
  '12345678',
  '123456789',
  '1234567890',
  'qwerty',
  'qwertyuiop',
  'asdfgh',
  'azerty',
  'abc123',
  '111111',
  '000000',
  'iloveyou',
  'admin',
  'welcome',
  'letmein',
  'monkey',
  'dragon',
  'football',
  'baseball',
  'sunshine',
  'princess',
  'master',
  'shadow',
  'superman',
  'trustno1',
  'login',
  'starwars',
  'whatever',
  'qazwsx',
  'michael',
  'sifre',
  'parola',
  'passwort',
  'motdepasse',
  'contrasena',
};

/// Password strength from 0 (very weak) to 4 (strong).
///
/// Estimates entropy from length and character variety; repeated characters
/// ("aaa"), sequences ("abc", "123") and common passwords lower the score.
/// shortcut: a small built-in common list, not zxcvbn's dictionaries; enough
/// for a strength bar, not for a security policy.
int passwordStrength(String password) {
  if (password.isEmpty) return 0;
  final lower = password.toLowerCase();
  if (_common.contains(lower)) return 0;

  var pool = 0;
  if (RegExp(r'\p{Ll}', unicode: true).hasMatch(password)) pool += 26;
  if (RegExp(r'\p{Lu}', unicode: true).hasMatch(password)) pool += 26;
  if (RegExp(r'\d').hasMatch(password)) pool += 10;
  if (RegExp(r'[^\p{L}\p{N}]', unicode: true).hasMatch(password)) pool += 33;
  if (RegExp(r'[^\x00-\x7F]').hasMatch(password)) pool += 100;

  final codes = password.runes.toList();
  var length = 1.0;
  for (var i = 1; i < codes.length; i++) {
    final step = (codes[i] - codes[i - 1]).abs();
    length += step <= 1 ? 0.25 : 1;
  }

  final bits = length * math.log(pool) / math.ln2;
  final score = bits < 28
      ? 0
      : bits < 36
      ? 1
      : bits < 50
      ? 2
      : bits < 65
      ? 3
      : 4;
  final base = lower.replaceAll(RegExp(r'^[^a-z]+|[^a-z]+$'), '');
  return _common.contains(base) ? math.min(score, 1) : score;
}
