import 'package:flutter/material.dart';
import 'package:regex_ui/regex_ui.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF00696D);
    return MaterialApp(
      title: 'Regex UI',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(colorSchemeSeed: seed),
      darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _valid = <String, bool>{};

  bool get _canSubmit => _valid.length == 4 && _valid.values.every((v) => v);

  @override
  void dispose() {
    _userName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex UI'),
        actions: [
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
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildField(_userName, 'User name'),
              RegexUI(
                controller: _userName,
                style: RegexUIStyle.chips,
                validate: (ok) => _setValid('user', ok),
                regexList: [
                  RegexModel.minLength(3),
                  RegexModel.noSpaces(),
                  RegexModel(
                    title: 'Letters, numbers, _',
                    regExp: RegExp(r'^\w*$'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField(_email, 'E-mail'),
              RegexUI(
                controller: _email,
                style: RegexUIStyle.chips,
                validate: (ok) => _setValid('email', ok),
                regexList: [RegexModel.email()],
              ),
              const SizedBox(height: 24),
              RegexTextField(
                controller: _password,
                obscureText: true,
                showStrength: true,
                strengthMode: RegexUIStrength.password,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validate: (ok) => _setValid('password', ok),
                rules: [
                  RegexModel.minLength(8),
                  RegexModel.uppercase(),
                  RegexModel.lowercase(),
                  RegexModel.digit(),
                  RegexModel.special(),
                  RegexModel.noRepeating(),
                  RegexModel.notContains(() => _userName.text),
                ],
              ),
              const SizedBox(height: 24),
              RegexTextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Repeat password',
                  border: OutlineInputBorder(),
                ),
                validate: (ok) => _setValid('repeat', ok),
                rules: [RegexModel.sameAs(_password)],
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
                onPressed: _canSubmit ? _submit : null,
                child: const Text('Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  void _setValid(String field, bool ok) {
    if (_valid[field] == ok) return;
    setState(() => _valid[field] = ok);
  }

  void _submit() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account created')));
  }
}
