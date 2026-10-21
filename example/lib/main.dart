import 'package:flutter/material.dart';
import 'package:regex_ui/regex_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  static const _fields = InputDecorationTheme(border: OutlineInputBorder());

  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00696D);
    return MaterialApp(
      title: 'Regex UI',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(colorSchemeSeed: seed, inputDecorationTheme: _fields),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        inputDecorationTheme: _fields,
      ),
      home: SignUpPage(onToggleTheme: _toggleTheme),
    );
  }

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }
}

class SignUpPage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SignUpPage({super.key, required this.onToggleTheme});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _userName = TextEditingController();
  final _password = TextEditingController();
  bool _canSubmit = false;
  String _language = 'en';

  @override
  void dispose() {
    _userName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex UI'),
        actions: [
          _buildLanguageMenu(),
          IconButton(
            tooltip: 'Toggle theme',
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: RegexForm(
            onChanged: (ok) => setState(() => _canSubmit = ok),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                RegexTextField.userName(controller: _userName),
                const SizedBox(height: 24),
                RegexTextField.email(),
                const SizedBox(height: 24),
                RegexTextField.password(
                  controller: _password,
                  rules: [
                    ...RegexModel.passwordRules(),
                    RegexModel.noRepeating(),
                    RegexModel.notContains(() => _userName.text),
                  ],
                ),
                const SizedBox(height: 24),
                RegexTextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Repeat password',
                  ),
                  rules: [RegexModel.sameAs(_password)],
                ),
                const SizedBox(height: 24),
                RegexTextField(
                  decoration: const InputDecoration(labelText: 'IBAN'),
                  style: RegexUIStyle.chips,
                  rules: [RegexModel.iban()],
                ),
                const SizedBox(height: 32),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(64, 52),
                  ),
                  onPressed: _canSubmit ? _submit : null,
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Language',
      icon: const Icon(Icons.translate),
      initialValue: _language,
      onSelected: (code) => setState(() {
        _language = code;
        RegexLabels.current = RegexLabels.forLanguage(code);
      }),
      itemBuilder: (_) => [
        for (final code in RegexLabels.builtIn.keys)
          PopupMenuItem(value: code, child: Text(code.toUpperCase())),
      ],
    );
  }

  void _submit() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account created')));
  }
}
