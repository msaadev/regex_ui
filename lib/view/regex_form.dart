import 'package:flutter/material.dart';

/// Knows whether every `RegexTextField` and `RegexUI` inside a [RegexForm]
/// meets its rules.
/// Listen to it, or read [isValid]; pass one to [RegexForm] to use it from
/// outside the form.
class RegexFormController extends ChangeNotifier {
  final Map<Object, bool Function()> _fields = {};
  bool _pending = false;
  bool _disposed = false;

  /// Whether there is at least one field and every field meets its rules.
  bool get isValid =>
      _fields.isNotEmpty && _fields.values.every((check) => check());

  void _add(Object field, bool Function() check) {
    _fields[field] = check;
    _notifyLater();
  }

  void _remove(Object field) {
    if (_fields.remove(field) != null) _notifyLater();
  }

  void _changed() => notifyListeners();

  // Fields join and leave while the tree builds; tell listeners after it.
  void _notifyLater() {
    if (_pending || _disposed) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// A [Form] that knows when all its `RegexTextField`s and `RegexUI`s are
/// valid: enable the submit button with [onChanged] or [RegexForm.isValidOf].
/// When one field changes, the others are checked again too, so "repeat
/// password" follows the password. Fields with `optional: true` may stay
/// empty. Plain `TextFormField`s are not counted; `Form.validate()` still
/// checks them.
///
/// ```dart
/// RegexForm(
///   onChanged: (ok) => setState(() => canSubmit = ok),
///   child: Column(children: [
///     RegexTextField.email(),
///     RegexTextField.password(),
///   ]),
/// )
/// ```
class RegexForm extends StatefulWidget {
  /// The fields, anywhere below.
  final Widget child;

  /// Called when "every field is valid" turns on or off.
  final ValueChanged<bool>? onChanged;

  /// Optional, to read [RegexFormController.isValid] from outside.
  final RegexFormController? controller;

  /// Key of the inner [Form], for `formKey.currentState!.validate()`.
  final GlobalKey<FormState>? formKey;

  /// Passed to the inner [Form].
  final AutovalidateMode? autovalidateMode;

  /// Creates a form around [child].
  const RegexForm({
    super.key,
    required this.child,
    this.onChanged,
    this.controller,
    this.formKey,
    this.autovalidateMode,
  });

  /// Whether every field of the nearest [RegexForm] is valid; rebuilds the
  /// caller when that changes. False outside a [RegexForm].
  static bool isValidOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<RegexFormScope>()
          ?.notifier
          ?.isValid ??
      false;

  @override
  State<RegexForm> createState() => _RegexFormState();
}

class _RegexFormState extends State<RegexForm> {
  RegexFormController? _own;
  bool _valid = false;

  RegexFormController get _controller =>
      widget.controller ?? (_own ??= RegexFormController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(RegexForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.controller ?? _own;
    if (old != _controller) {
      old?.removeListener(_onChanged);
      _controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegexFormScope(
      notifier: _controller,
      child: Form(
        key: widget.formKey,
        autovalidateMode: widget.autovalidateMode,
        child: widget.child,
      ),
    );
  }

  void _onChanged() {
    final valid = _controller.isValid;
    if (valid == _valid) return;
    _valid = valid;
    widget.onChanged?.call(valid);
  }
}

/// Connects `RegexUI`s to their [RegexForm]; not for direct use.
class RegexFormScope extends InheritedNotifier<RegexFormController> {
  /// Creates the scope.
  const RegexFormScope({
    super.key,
    required RegexFormController super.notifier,
    required super.child,
  });

  /// The controller of the nearest [RegexForm], without depending on it.
  static RegexFormController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<RegexFormScope>()?.notifier;
}

/// Lets `RegexUI` join a [RegexFormController].
extension RegexFormFields on RegexFormController {
  /// Registers [field] with its [check]; call [leave] when it goes away.
  void join(Object field, bool Function() check) => _add(field, check);

  /// Removes [field].
  void leave(Object field) => _remove(field);

  /// Tells the form that a field's text changed.
  void fieldChanged() => _changed();
}
