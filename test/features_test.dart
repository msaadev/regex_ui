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
