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
      expect(validate(null), 'At least 4 characters');
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
    });
  });

  group('RegexLabels', () {
    tearDown(() => RegexLabels.current = RegexLabels.en);

    test('ready languages, forLanguage and copyWith', () {
      RegexLabels.current = RegexLabels.tr;
      expect(RegexModel.minLength(8).title, 'En az 8 karakter');
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
    expect(find.byTooltip('Show'), findsOneWidget);
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
    await tester.tap(find.byTooltip('Show'));
    await tester.pump();
    expect(field().obscureText, isFalse);

    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('At least 8 characters'), findsNWidgets(2));

    await tester.enterText(find.byType(TextFormField), 'correct horse battery');
    await tester.pumpAndSettle();
    expect(form.currentState!.validate(), isTrue);
    expect(find.text('Strong'), findsOneWidget);
  });
}
