## 1.1.0

* **`RegexTextField`**: field + rules + strength bar + show / hide button in one widget; makes its own
  controller and focus node when you pass none.
* **One-line fields**: `RegexTextField.password()`, `.email()`, `.userName()` with ready rules,
  keyboard type and autofill; ready rule lists `RegexModel.passwordRules()`, `userNameRules()`, `emailRules()`.
* **No regex needed**: plain-word rules `lengthBetween`, `exactLength`, `lettersOnly`, `digitsOnly`,
  `lettersAndDigits` (with `allow:` for extra characters, escaped for you), `startsWith`, `endsWith`,
  `contains`, and `count:` on `uppercase`, `lowercase`, `digit`, `special`. README "I want… / Write" table.
* **`RegexChar` groups**: pick characters from a list instead of writing them:
  `RegexModel.allowOnly([...])`, `RegexModel.notAllowed([...])`, and `allowList:` on `lettersOnly`,
  `digitsOnly`, `lettersAndDigits`.
* **`RegexLabels`**: one place for every text the package writes (rule titles, `RegexChar` names,
  screen reader words, strength words, Show / Hide, field labels). Set your language once; pass only
  what you change. Ready languages: `RegexLabels.en`, `tr`, `de`, `es`, `fr`, `it`, `pt`, `ja`,
  `RegexLabels.forLanguage(code)`, and `copyWith` to change a few words. `title:` still changes a single rule.
* **Form support**: `RegexModel.validator(rules)` for `TextFormField`; `RegexTextField` uses it, so
  `Form.validate()` checks the same rules.
* **New rules**: `maxLength`, `sameAs` (repeat password), `notContains` (e.g. no user name),
  `noRepeating`, `phone`, `url`.
* **Real password strength**: `passwordStrength(value)` → 0–4; `strengthMode: RegexUIStrength.password`
  drives the bar with it, and `strengthLabels` shows Very weak … Strong next to it.
* Empty input meets no rule, so nothing is ticked before typing (e.g. `^\w*$`, `maxLength`).
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
