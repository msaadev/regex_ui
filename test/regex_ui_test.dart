import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:regex_ui/regex_ui.dart';

void main() {
  group('RegexModel presets', () {
    test('minLength', () {
      final rule = RegexModel.minLength(8);
      expect(rule.matches('1234567'), isFalse);
      expect(rule.matches('12345678'), isTrue);
    });

    test('uppercase and lowercase work for any language', () {
      expect(RegexModel.uppercase().matches('şİ'), isTrue);
      expect(RegexModel.uppercase().matches('abc'), isFalse);
      expect(RegexModel.lowercase().matches('ÄÖ'), isFalse);
      expect(RegexModel.lowercase().matches('Äö'), isTrue);
    });

    test('digit, special, noSpaces, email', () {
      expect(RegexModel.digit().matches('a1'), isTrue);
      expect(RegexModel.special().matches('abc1'), isFalse);
      expect(RegexModel.special().matches('abc!'), isTrue);
      expect(RegexModel.noSpaces().matches('a b'), isFalse);
      expect(RegexModel.noSpaces().matches(''), isFalse);
      expect(RegexModel.email().matches('a@b.co'), isTrue);
      expect(RegexModel.email().matches('a@b'), isFalse);
    });

    test('custom test function', () {
      final rule = RegexModel(title: 'Not admin', test: (v) => v != 'admin');
      expect(rule.matches('admin'), isFalse);
    });
  });

  group('RegexUI', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    Future<List<bool>> pump(
      WidgetTester tester, {
      FocusNode? node,
      RegexUIStyle style = RegexUIStyle.list,
      bool showStrength = false,
    }) async {
      final results = <bool>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(controller: controller, focusNode: node),
                RegexUI(
                  controller: controller,
                  focusNode: node,
                  style: style,
                  showStrength: showStrength,
                  validate: results.add,
                  regexList: [RegexModel.minLength(3), RegexModel.digit()],
                ),
              ],
            ),
          ),
        ),
      );
      return results;
    }

    testWidgets('shows rules only while focused', (tester) async {
      await pump(tester, node: focusNode);
      expect(find.text('One number'), findsNothing);

      focusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('One number'), findsOneWidget);
    });

    testWidgets('without a focus node the rules are always shown', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('At least 3 characters'), findsOneWidget);
    });

    testWidgets('validate reports when all rules pass', (tester) async {
      final results = await pump(tester);
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.enterText(find.byType(TextField), 'ab1');
      await tester.pumpAndSettle();
      expect(results.last, isTrue);
      expect(results.first, isFalse);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    });

    testWidgets('chips style and strength bar render', (tester) async {
      await pump(tester, style: RegexUIStyle.chips, showStrength: true);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('screen reader hears met / not met', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);
      expect(find.bySemanticsLabel('One number: not met'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('removes its listeners on dispose', (tester) async {
      await pump(tester, node: focusNode);
      await tester.pumpWidget(const SizedBox());
      controller.text = 'abc';
      focusNode.dispose();
      focusNode = FocusNode();
    });
  });
}
