## 1.1.0

* **`RegexTextField`**: field + rules + strength bar + show / hide button in one widget; makes its own
  controller and focus node when you pass none.
* **Form support**: `RegexModel.validator(rules)` for `TextFormField`; `RegexTextField` uses it, so
  `Form.validate()` checks the same rules.
* **New rules**: `maxLength`, `sameAs` (repeat password), `notContains` (e.g. no user name),
  `noRepeating`, `phone`, `url`.
* **Real password strength**: `passwordStrength(value)` → 0–4; `strengthMode: RegexUIStrength.password`
  drives the bar with it, and `strengthLabels` shows Very weak … Strong next to it.
* New logo; README polish.

## 1.0.0

* New design: Material 3 colors from the theme, dark mode, animated check marks and colors.
* Ready rules: `RegexModel.minLength`, `uppercase`, `lowercase`, `digit`, `special`, `noSpaces`, `email` (any language).
* Custom rules with a `test` function as well as `RegExp`.
* Password strength bar (`showStrength`) and chips style (`RegexUIStyle.chips`).
* `focusNode` is optional; `visibility`: show on focus or always.
* Accessibility: screen reader text per rule (`metLabel` / `unmetLabel`).
* `RegexModel` is exported from `package:regex_ui/regex_ui.dart`.
* Dart 3 (SDK `^3.8.0`).
* Fixed: build error on current Flutter (`bodyText1` was removed).
* Fixed: listeners were never removed from the controller and focus node.

## 0.0.1

* Initial release.
