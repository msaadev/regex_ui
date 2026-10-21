import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regex_ui/regex_ui.dart';

void main() {
  group('new rules', () {
    test('empty input meets no rule', () {
      expect(RegexModel.maxLength(3).matches(''), isFalse);
      expect(
        RegexModel(title: 'w', regExp: RegExp(r'^\w*$')).matches(''),
        isFalse,
      );
      expect(RegexModel(title: 't', test: (_) => true).matches(''), isFalse);
    });

    test('maxLength', () {
      expect(RegexModel.maxLength(3).matches('abc'), isTrue);
      expect(RegexModel.maxLength(3).matches('abcd'), isFalse);
    });

    test('sameAs follows the other controller', () {
      final other = TextEditingController(text: 'secret');
      final rule = RegexModel.sameAs(other);
      expect(rule.matches('secret'), isTrue);
      other.text = 'changed';
      expect(rule.matches('secret'), isFalse);
      expect(RegexModel.sameAs(TextEditingController()).matches(''), isFalse);
    });

    test('notContains checks each name word, ignoring case and accents', () {
      final rule = RegexModel.notContains(() => 'Ali-Can Yılmaz');
      expect(rule.matches('yilmaz12345'), isFalse);
      expect(rule.matches('xxCANxx'), isFalse);
      expect(rule.matches('İSTANBUL34'), isTrue);
      expect(rule.matches('guvenli2sifre9'), isTrue);
      expect(RegexModel.notContains(() => 'İpek').matches('ipek1234'), isFalse);
    });

    test('notContains ignores case and an empty source', () {
      var name = 'Samil';
      final rule = RegexModel.notContains(() => name);
      expect(rule.matches('xxSAMILxx'), isFalse);
      expect(rule.matches('another1'), isTrue);
      name = '';
      expect(rule.matches('samil'), isTrue);
    });

    test('noRepeating', () {
      expect(RegexModel.noRepeating().matches('aab'), isTrue);
      expect(RegexModel.noRepeating().matches('aaab'), isFalse);
      expect(RegexModel.noRepeating(count: 2).matches('aab'), isFalse);
    });

    test('phone', () {
      expect(RegexModel.phone().matches('+90 (532) 123-45-67'), isTrue);
      expect(RegexModel.phone().matches('12345'), isFalse);
      expect(RegexModel.phone().matches('call me'), isFalse);
    });

    test('iban', () {
      final iban = RegexModel.iban();
      expect(iban.matches('TR330006100519786457841326'), isTrue);
      expect(iban.matches('TR33 0006 1005 1978 6457 8413 26'), isTrue);
      expect(iban.matches('tr33 0006 1005 1978 6457 8413 26'), isTrue);
      expect(iban.matches('TR330006100519786457841327'), isFalse); // checksum
      expect(iban.matches('TR33000610051978645784132'), isFalse); // length
      expect(iban.matches('DE89 3704 0044 0532 0130 00'), isTrue);
      expect(iban.matches('GB82 WEST 1234 5698 7654 32'), isTrue);
      expect(
        RegexModel.iban(country: 'TR').matches('DE89370400440532013000'),
        isFalse,
      );
      expect(iban.matches('hello'), isFalse);
    });

    test('url', () {
      expect(RegexModel.url().matches('https://monsware.com/x'), isTrue);
      expect(RegexModel.url().matches('ftp://monsware.com'), isFalse);
      expect(RegexModel.url().matches('monsware'), isFalse);
    });

    test('validator returns the first unmet title', () {
      final validate = RegexModel.validator([
        RegexModel.minLength(4),
        RegexModel.digit(),
      ]);
      expect(validate(null), 'Required');
      expect(validate('ab'), 'At least 4 characters');
      expect(validate('abcd'), 'One number');
      expect(validate('abc1'), isNull);
    });
  });

  group('no regex needed', () {
    test('counts', () {
      expect(RegexModel.digit(count: 2).matches('a1'), isFalse);
      expect(RegexModel.digit(count: 2).matches('a1b2'), isTrue);
      expect(
        RegexModel.uppercase(count: 2).title,
        'At least 2 uppercase letters',
      );
      expect(RegexModel.digit().title, 'One number');
    });

    test('length', () {
      expect(RegexModel.lengthBetween(3, 5).matches('ab'), isFalse);
      expect(RegexModel.lengthBetween(3, 5).matches('abcd'), isTrue);
      expect(RegexModel.exactLength(11).matches('12345678901'), isTrue);
      expect(RegexModel.exactLength(11).matches('1234'), isFalse);
    });

    test(
      'only letters / digits with allowed extras, special chars escaped',
      () {
        expect(RegexModel.lettersOnly().matches('Şamil'), isTrue);
        expect(RegexModel.lettersOnly().matches('Şamil Demir'), isFalse);
        expect(
          RegexModel.lettersOnly(allow: ' -').matches('Ali-Can Demir'),
          isTrue,
        );
        expect(RegexModel.digitsOnly().matches('0532'), isTrue);
        expect(RegexModel.digitsOnly().matches('05a'), isFalse);
        final odd = RegexModel.lettersAndDigits(allow: r'-]\^.');
        expect(odd.matches(r'a-b]c\d^e.f1'), isTrue);
        expect(odd.matches('a b'), isFalse);
        expect(odd.matches('a*b'), isFalse);
        expect(
          RegexModel.lettersAndDigits(allow: '_ ').title,
          'Only letters, numbers, _ and spaces',
        );
      },
    );

    test('RegexChar lists', () {
      final name = RegexModel.lettersOnly(
        allowList: [RegexChar.whitespace, RegexChar.dash, RegexChar.apostrophe],
      );
      expect(name.matches("Ali-Can O'Neil"), isTrue);
      expect(name.matches('Ali2'), isFalse);
      expect(name.title, "Only letters, spaces, - and '");

      final user = RegexModel.allowOnly([
        RegexChar.englishLetters,
        RegexChar.digits,
        RegexChar.underscore,
        RegexChar.dot,
      ]);
      expect(user.matches('samil.d_42'), isTrue);
      expect(user.matches('şamil'), isFalse);

      final withSpecial = RegexModel.allowOnly([
        RegexChar.digits,
        RegexChar.special,
      ]);
      expect(withSpecial.matches('12!#€'), isTrue);
      expect(withSpecial.matches('12a'), isFalse);

      final noBad = RegexModel.notAllowed([
        RegexChar.whitespace,
        RegexChar.dot,
      ]);
      expect(noBad.matches('ab_c'), isTrue);
      expect(noBad.matches('a b'), isFalse);
      expect(noBad.matches('a.b'), isFalse);
      expect(noBad.title, 'No spaces and .');
    });

    test('startsWith, endsWith, contains', () {
      expect(RegexModel.startsWith('TR').matches('TR12'), isTrue);
      expect(RegexModel.startsWith('TR').matches('tr12'), isFalse);
      expect(
        RegexModel.startsWith('TR', ignoreCase: true).matches('tr12'),
        isTrue,
      );
      expect(
        RegexModel.endsWith('@monsware.com').matches('a@Monsware.com'),
        isTrue,
      );
      expect(RegexModel.contains('.').matches('ab'), isFalse);
      expect(RegexModel.notStartsWith('0').matches('0123'), isFalse);
      expect(RegexModel.notStartsWith('0').matches('1230'), isTrue);
    });
  });

  group('RegexLabels', () {
    tearDown(() => RegexLabels.current = RegexLabels.en);

    test('ready languages, forLanguage and copyWith', () {
      RegexLabels.current = RegexLabels.tr;
      expect(RegexModel.minLength(8).title, 'En az 8 karakter');
      expect(RegexModel.notStartsWith('0').title, '"0" ile başlamasın');
      expect(
        RegexModel.lettersAndDigits(allowList: [RegexChar.underscore]).title,
        'Sadece harfler, rakamlar ve _',
      );
      expect(
        RegexModel.notAllowed([RegexChar.whitespace]).title,
        'Boşluk olmasın',
      );

      expect(RegexLabels.forLanguage('ja-JP'), same(RegexLabels.ja));
      expect(RegexLabels.forLanguage('de_AT'), same(RegexLabels.de));
      expect(RegexLabels.forLanguage('xx'), same(RegexLabels.en));

      RegexLabels.current = RegexLabels.de.copyWith(
        show: 'Zeigen',
        chars: {RegexChar.digits: 'Ziffern'},
      );
      expect(RegexLabels.current.show, 'Zeigen');
      expect(RegexModel.digitsOnly().title, 'Nur Ziffern');
      expect(RegexModel.minLength(3).title, 'Mindestens 3 Zeichen');
      expect(RegexLabels.current.char(RegexChar.letters), 'Buchstaben');
    });

    test('translator details', () {
      RegexLabels.current = RegexLabels.fr;
      expect(
        RegexModel.notAllowed([RegexChar.whitespace]).title,
        "Pas d'espaces",
      );
      expect(RegexModel.notAllowed([RegexChar.dot]).title, 'Pas de .');
      expect(
        RegexModel.lettersAndDigits(allowList: [RegexChar.underscore]).title,
        'Lettres, chiffres et _ uniquement',
      );
      RegexLabels.current = RegexLabels.de;
      expect(RegexModel.digit().title, 'Eine Ziffer');
      RegexLabels.current = RegexLabels.ja;
      expect(RegexModel.uppercase().title, '英大文字を1文字以上含む');
      expect(RegexModel.notAllowed([RegexChar.whitespace]).title, 'スペースを含まない');
      expect(RegexModel.iban().title, '有効なIBAN');
    });

    test('every ready language fills every text', () {
      for (final labels in RegexLabels.builtIn.values) {
        expect(labels.strength, hasLength(5));
        for (final c in [
          RegexChar.letters,
          RegexChar.englishLetters,
          RegexChar.uppercase,
          RegexChar.lowercase,
          RegexChar.digits,
          RegexChar.whitespace,
          RegexChar.special,
        ]) {
          expect(labels.char(c), isNotEmpty);
          if (labels != RegexLabels.en) {
            expect(labels.char(c), isNot(c.label), reason: '$c');
          }
        }
      }
    });

    test('one language for every auto title, partial overrides', () {
      RegexLabels.current = RegexLabels(
        minLength: (n) => '$n文字以上',
        chars: const {RegexChar.whitespace: 'スペース'},
        only: (list) => '$listのみ',
        join: (words) => words.join('、'),
      );
      expect(RegexModel.minLength(3).title, '3文字以上');
      expect(
        RegexModel.lettersOnly(allowList: [RegexChar.whitespace]).title,
        'letters、スペースのみ',
      );
      expect(RegexModel.digit().title, 'One number');
      expect(RegexModel.minLength(3, title: '最低3').title, '最低3');
    });

    testWidgets('widgets use the labels', (tester) async {
      RegexLabels.current = const RegexLabels(
        show: '表示',
        passwordField: 'パスワード',
        strength: ['1', '2', '3', '4', '5'],
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RegexTextField.password())),
      );
      expect(find.text('パスワード'), findsOneWidget);
      expect(find.byTooltip('表示'), findsOneWidget);
    });
  });

  test('ready rule lists', () {
    bool all(List<RegexModel> rules, String v) =>
        rules.every((r) => r.matches(v));
    expect(all(RegexModel.passwordRules(), 'Abcdef1!'), isTrue);
    expect(all(RegexModel.passwordRules(), 'abcdef1!'), isFalse);
    expect(all(RegexModel.userNameRules(), 'şamil_42'), isTrue);
    expect(all(RegexModel.userNameRules(), 'a b'), isFalse);
    expect(all(RegexModel.emailRules(), 'a@b.co'), isTrue);
  });

  testWidgets('RegexTextField.password is complete in one line', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: RegexTextField.password())),
    );
    expect(find.text('Password'), findsOneWidget);
    expect(find.byTooltip('Show password'), findsOneWidget);
    await tester.showKeyboard(find.byType(TextFormField));
    await tester.pumpAndSettle();
    expect(find.text('One uppercase letter'), findsOneWidget);
  });

  test('passwordStrength ranks passwords', () {
    expect(passwordStrength(''), 0);
    expect(passwordStrength('password'), 0);
    expect(passwordStrength('aaaaaaaa'), 0);
    expect(passwordStrength('abc123'), 0);
    expect(passwordStrength('Password1!'), lessThanOrEqualTo(1));
    expect(passwordStrength('correct horse battery staple'), 4);
    expect(
      passwordStrength('k9#Lm2qZ'),
      greaterThan(passwordStrength('abcdefgh')),
    );
  });

  testWidgets('RegexTextField: eye toggles, Form validates, labels show', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: RegexTextField(
              obscureText: true,
              showStrength: true,
              strengthMode: RegexUIStrength.password,
              visibility: RegexUIVisibility.always,
              rules: [RegexModel.minLength(8)],
            ),
          ),
        ),
      ),
    );

    EditableText field() => tester.widget(find.byType(EditableText));
    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);

    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'correct horse battery');
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    expect(find.text('Strong'), findsOneWidget);
  });

  testWidgets('RegexForm knows when every field is valid', (tester) async {
    final changes = <bool>[];
    final password = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegexForm(
            onChanged: changes.add,
            child: Column(
              children: [
                RegexTextField.email(),
                RegexTextField.password(
                  controller: password,
                  rules: [RegexModel.minLength(4)],
                ),
                RegexTextField(
                  visibility: RegexUIVisibility.always,
                  rules: [RegexModel.sameAs(password)],
                ),
                Builder(
                  builder: (context) => FilledButton(
                    onPressed: RegexForm.isValidOf(context) ? () {} : null,
                    child: const Text('Send'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    FilledButton button() => tester.widget(find.byType(FilledButton));
    final inputs = find.byType(TextFormField);

    expect(button().onPressed, isNull);
    await tester.enterText(inputs.at(0), 'a@b.co');
    await tester.enterText(inputs.at(1), 'abcd');
    await tester.enterText(inputs.at(2), 'abcd');
    await tester.pump();
    expect(button().onPressed, isNotNull);
    expect(changes, [true]);

    // Changing the password makes "repeat" invalid without touching it.
    await tester.enterText(inputs.at(1), 'abcde');
    await tester.pumpAndSettle();
    expect(button().onPressed, isNull);
    expect(changes, [true, false]);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('RegexForm: optional fields may stay empty', (tester) async {
    final changes = <bool>[];
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegexForm(
            formKey: form,
            onChanged: changes.add,
            child: Column(
              children: [
                RegexTextField.email(
                  controller: TextEditingController(text: 'a@b.co'),
                ),
                RegexTextField(
                  optional: true,
                  rules: [RegexModel.exactLength(6)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(changes, [true]);
    expect(form.currentState!.validate(), isTrue);

    // Once typed, the rules apply.
    await tester.enterText(find.byType(TextFormField).at(1), 'abc');
    await tester.pump();
    expect(changes, [true, false]);
    expect(form.currentState!.validate(), isFalse);
  });

  testWidgets('RegexForm counts RegexUI with your own TextField', (
    tester,
  ) async {
    final changes = <bool>[];
    final text = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegexForm(
            onChanged: changes.add,
            child: Column(
              children: [
                TextField(controller: text),
                RegexUI(controller: text, regexList: [RegexModel.minLength(2)]),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pump();
    expect(changes, [true]);
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(changes, [true, false]);
  });

  test('validator and allMet with optional', () {
    final rules = [RegexModel.minLength(3)];
    expect(RegexModel.validator(rules)(''), 'Required');
    expect(RegexModel.validator(rules, optional: true)(''), isNull);
    expect(
      RegexModel.validator(rules, optional: true)('ab'),
      'At least 3 characters',
    );
    expect(RegexModel.allMet(rules, '', optional: true), isTrue);
    expect(RegexModel.allMet(rules, ''), isFalse);
  });

  test('lengths count characters, not UTF-16 units', () {
    expect(RegexModel.minLength(8).matches('😀😀😀😀'), isFalse);
    expect(RegexModel.exactLength(4).matches('😀😀😀😀'), isTrue);
    expect(RegexModel.maxLength(3).matches('😀😀😀'), isTrue);
    expect(RegexModel.lengthBetween(2, 3).matches('😀😀'), isTrue);
  });

  testWidgets('validate reports pre-filled text on the first frame', (
    tester,
  ) async {
    final results = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegexUI(
            controller: TextEditingController(text: 'abcdefgh'),
            regexList: [RegexModel.minLength(8)],
            validate: results.add,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(results, [true]);
  });
}
