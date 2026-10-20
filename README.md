<p align="center"><img src="https://raw.githubusercontent.com/msaadev/regex_ui/main/logo/logo.png" width="128" alt="regex_ui logo"></p>

# regex_ui

[![pub package](https://img.shields.io/pub/v/regex_ui.svg)](https://pub.dev/packages/regex_ui)

**Live password validation and rule checklists for Flutter text fields.** Show users, while
they type, which rules their password, user name or e-mail already meets: animated check
marks, a password strength indicator, list or chip styles. Material 3, dark mode, no dependencies.

<p align="center"><img src="https://raw.githubusercontent.com/msaadev/regex_ui/main/screen_shots/regex_ui.gif" width="320" alt="Flutter password validation checklist with strength indicator"></p>

**Live demo:** [monsware.com/regex-ui](https://monsware.com/regex-ui/)

## Features of this Flutter password validator

- **One line**: `RegexTextField.password()`, `.email()`, `.userName()` are ready fields with
  sensible rules, keyboard and autofill.
- **One widget, no boilerplate**: `RegexTextField` is the field, the rules, the strength bar and the
  show / hide password button together; it makes its own controller and focus node.
- **Works with `Form`**: `Form.validate()` checks the same rules (`RegexModel.validator(rules)` for your own `TextFormField`).
- **Ready rules**: `minLength`, `maxLength`, `uppercase`, `lowercase`, `digit`, `special`, `noSpaces`,
  `noRepeating`, `email`, `phone`, `url`, `sameAs` (repeat password), `notContains` (no user name in the password)
  (letters in any language, e.g. `Ş`, `Ä`, `É`).
- **Real password strength**: `passwordStrength(value)` scores 0–4 from length, variety, repeats,
  sequences and common passwords; the bar can show it with labels (Very weak … Strong).
- **No regex needed**: rules in plain words (`digitsOnly()`, `lettersAndDigits(allow: '_')`,
  `lengthBetween(3, 20)`, `startsWith('TR')`, `digit(count: 2)`…) with automatic titles.
- **Your own rules**: any `RegExp`, or a `test` function in plain Dart.
- **Password strength indicator**: a bar that fills and turns green as rules are met, or by real strength.
- **Two styles**: a checklist (`RegexUIStyle.list`) or compact chips (`RegexUIStyle.chips`).
- **Show on focus or always**: pass a `FocusNode` to show the rules only while typing.
- **Accessible**: screen readers hear "One number: met"; labels are translatable.
- **`validate` callback**: enable your submit button only when every rule passes.

## Install

```yaml
dependencies:
  regex_ui: ^1.1.0
```

## Usage: password validation in Flutter

One line each: the field, its rules, the strength bar and the show / hide button.

```dart
import 'package:regex_ui/regex_ui.dart';

RegexTextField.userName(),
RegexTextField.email(),
RegexTextField.password(),                    // 8+ chars, upper, lower, number, special
RegexTextField.password(minLength: 12, label: 'New password'),
```

Inside a `Form`, `formKey.currentState!.validate()` checks the same rules. Pass `rules:` to any of
them to use your own, or start from the ready lists: `RegexModel.passwordRules()`,
`RegexModel.userNameRules()`, `RegexModel.emailRules()`.

Full control:

```dart
import 'package:regex_ui/regex_ui.dart';

Form(
  key: formKey,
  child: Column(children: [
    RegexTextField(
      controller: password,
      obscureText: true, // adds the show / hide button
      decoration: const InputDecoration(labelText: 'Password'),
      showStrength: true,
      strengthMode: RegexUIStrength.password, // Very weak … Strong
      rules: [
        RegexModel.minLength(8),
        RegexModel.digit(),
        RegexModel.noRepeating(),
        RegexModel.notContains(() => userName.text),
      ],
    ),
    RegexTextField(
      obscureText: true,
      decoration: const InputDecoration(labelText: 'Repeat password'),
      rules: [RegexModel.sameAs(password)],
    ),
  ]),
)
// formKey.currentState!.validate() checks the same rules.
```

With your own field:

```dart
TextField(controller: controller, focusNode: focusNode, obscureText: true),
RegexUI(
  controller: controller,
  focusNode: focusNode,
  showStrength: true,
  validate: (isValid) => setState(() => canSubmit = isValid),
  regexList: [
    RegexModel.minLength(8),
    RegexModel.uppercase(),
    RegexModel.lowercase(),
    RegexModel.digit(),
    RegexModel.special(),
  ],
)
```

## No regex needed

You don't need to know regular expressions. Say what you want in plain words; the rule writes its
own title too.

| I want… | Write |
|---|---|
| at least 8 characters | `RegexModel.minLength(8)` |
| at most 20 characters | `RegexModel.maxLength(20)` |
| 3 to 20 characters | `RegexModel.lengthBetween(3, 20)` |
| exactly 11 characters (ID number, code) | `RegexModel.exactLength(11)` |
| only numbers | `RegexModel.digitsOnly()` |
| only letters, spaces and dashes allowed (names) | `RegexModel.lettersOnly(allow: ' -')` |
| letters, numbers, `_` and `.` (user names) | `RegexModel.lettersAndDigits(allow: '_.')` |
| at least 2 numbers | `RegexModel.digit(count: 2)` |
| an uppercase / lowercase letter | `RegexModel.uppercase()` / `RegexModel.lowercase()` |
| a special character like `!` or `#` | `RegexModel.special()` |
| no spaces | `RegexModel.noSpaces()` |
| no "aaa" | `RegexModel.noRepeating()` |
| starts with "TR" | `RegexModel.startsWith('TR')` |
| ends with "@company.com" | `RegexModel.endsWith('@company.com')` |
| contains "@" | `RegexModel.contains('@')` |
| same as the password field | `RegexModel.sameAs(passwordController)` |
| must not contain the user name | `RegexModel.notContains(() => userName.text)` |
| an e-mail / phone / web address | `RegexModel.email()` / `.phone()` / `.url()` |
| anything else, in plain Dart | `RegexModel(title: 'Not "admin"', test: (v) => v != 'admin')` |

Characters you pass to `allow:`, `startsWith`, `endsWith` and `contains` are used as they are:
`-`, `.`, `]` or `\` need no escaping. Every rule takes `title:` for your own wording or language.
Already have a regex from somewhere? `RegexModel(title: '…', regExp: RegExp(r'…'))` still works.

### User name and e-mail as chips

```dart
RegexUI(
  controller: userName,
  style: RegexUIStyle.chips,
  regexList: [
    RegexModel.lengthBetween(3, 20),
    RegexModel.lettersAndDigits(allow: '_'),
  ],
)
```

### Custom rule and translations

```dart
RegexUI(
  controller: controller,
  metLabel: 'erfüllt',
  unmetLabel: 'nicht erfüllt',
  regexList: [
    RegexModel.minLength(8, title: 'Mindestens 8 Zeichen'),
    RegexModel(title: 'Nicht "passwort"', test: (v) => v.toLowerCase() != 'passwort'),
  ],
)
```

## Options

| Parameter | Default | |
|---|---|---|
| `style` | `list` | `list` or `chips` |
| `showStrength` | `false` | strength bar above the rules |
| `strengthMode` | `rules` | `rules` (share of met rules) or `password` (`passwordStrength`, 0–4) |
| `strengthLabels` | 5 English labels in `password` mode | words next to the bar, weakest first |
| `visibility` | `focus` with a `focusNode`, else `always` | |
| `iconTrue` / `iconFalse` | check / close | per rule too |
| `iconColorTrue` / `iconColorFalse` | green / outline | per rule: `colorTrue` / `colorFalse` |
| `textColorTrue` / `textColorFalse` / `textStyle` | theme | per rule too |
| `padding` / `margin` / `boxDecoration` | none | |
| `metLabel` / `unmetLabel` | "met" / "not met" | screen reader words |

## Upgrading from 0.0.1

Existing code keeps working. `focusNode` is optional now, `RegexModel` is exported from
`package:regex_ui/regex_ui.dart`, and the default look follows your Material 3 theme.

## Keywords

Flutter password validation · password strength indicator · password checker · password rules ·
regex validator · text field validation · form validation · sign up form · Material 3.

Issues and ideas: [GitHub](https://github.com/msaadev/regex_ui/issues).

## About the author

Made with ❤️ by **[Muhammed Şamil Demir](https://monsware.com)**, Flutter & iOS developer and founder of
**[Monsware](https://monsware.com)**. Free and open source (see LICENSE).

- 🌐 Website: [monsware.com](https://monsware.com) · GitHub: [@msaadev](https://github.com/msaadev)
- 📱 Apps by Monsware: [Triangle Calculator](https://apps.apple.com/app/id1600108278) ·
  [Circle Calculator](https://apps.apple.com/app/id1607441563)
- 📦 More Flutter packages: [awesome_stepper](https://pub.dev/packages/awesome_stepper) ·
  [regex_ui](https://pub.dev/packages/regex_ui) · [fold_kit](https://pub.dev/packages/fold_kit)
- 💼 Need a Flutter or iOS app built? [Get in touch](https://monsware.com/contact)

If this package saves you time, a ⭐ on GitHub and a 👍 on pub.dev help a lot.
