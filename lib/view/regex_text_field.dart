import 'package:flutter/material.dart';

import '../models/regex_labels.dart';
import '../models/regex_model.dart';
import 'regex_ui.dart';

/// A text field with its rule checklist, strength bar and a show / hide
/// button in one widget. Works inside a `Form`: `Form.validate()` checks the
/// same [rules].
class RegexTextField extends StatefulWidget {
  /// The rules shown under the field and used by the form validator.
  final List<RegexModel> rules;

  /// Optional; created and disposed by the widget when null.
  final TextEditingController? controller;

  /// Optional; created and disposed by the widget when null.
  final FocusNode? focusNode;

  /// Decoration of the field. The show / hide button goes into its suffix.
  final InputDecoration decoration;

  /// Hides the text and adds a show / hide button (passwords).
  final bool obscureText;

  /// Keyboard, action and autofill of the field.
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  /// Called on every change with whether all rules are met.
  final ValueChanged<bool>? validate;

  /// May be left empty: empty counts as valid (no "Required" error, and
  /// [RegexForm] can still be valid); once typed, the rules apply.
  final bool optional;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// When the rules are shown. Defaults to while the field has focus.
  final RegexUIVisibility visibility;

  /// List or chips.
  final RegexUIStyle style;

  /// Shows a strength bar above the rules.
  final bool showStrength;

  /// What the strength bar measures.
  final RegexUIStrength strengthMode;

  /// Words next to the strength bar, weakest first.
  final List<String>? strengthLabels;

  /// Tooltips (and screen reader labels) of the show / hide button.
  /// Default: [RegexLabels].
  final String? showLabel, hideLabel;

  /// Creates a field checked against [rules].
  const RegexTextField({
    super.key,
    required this.rules,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validate,
    this.onSubmitted,
    this.optional = false,
    this.visibility = RegexUIVisibility.focus,
    this.style = RegexUIStyle.list,
    this.showStrength = false,
    this.strengthMode = RegexUIStrength.rules,
    this.strengthLabels,
    this.showLabel,
    this.hideLabel,
  });

  /// A password field in one line: hidden text with a show / hide button,
  /// [RegexModel.passwordRules] and a real strength bar with labels.
  /// Pass [rules] to replace the default rules.
  RegexTextField.password({
    super.key,
    List<RegexModel>? rules,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validate,
    this.onSubmitted,
    this.optional = false,
    this.visibility = RegexUIVisibility.focus,
    this.showLabel,
    this.hideLabel,
    String? label,
    int minLength = 8,
    this.style = RegexUIStyle.list,
    this.strengthLabels,
  }) : rules = rules ?? RegexModel.passwordRules(minLength: minLength),
       decoration = InputDecoration(
         labelText: label ?? RegexLabels.current.passwordField,
       ),
       obscureText = true,
       keyboardType = TextInputType.visiblePassword,
       autofillHints = const [AutofillHints.password],
       showStrength = true,
       strengthMode = RegexUIStrength.password;

  /// An e-mail field in one line with [RegexModel.emailRules].
  RegexTextField.email({
    super.key,
    List<RegexModel>? rules,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validate,
    this.onSubmitted,
    this.optional = false,
    this.visibility = RegexUIVisibility.focus,
    this.showLabel,
    this.hideLabel,
    String? label,
    this.style = RegexUIStyle.chips,
  }) : rules = rules ?? RegexModel.emailRules(),
       decoration = InputDecoration(
         labelText: label ?? RegexLabels.current.emailField,
       ),
       obscureText = false,
       keyboardType = TextInputType.emailAddress,
       autofillHints = const [AutofillHints.email],
       showStrength = false,
       strengthMode = RegexUIStrength.rules,
       strengthLabels = null;

  /// A user name field in one line with [RegexModel.userNameRules].
  RegexTextField.userName({
    super.key,
    List<RegexModel>? rules,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.validate,
    this.onSubmitted,
    this.optional = false,
    this.visibility = RegexUIVisibility.focus,
    this.showLabel,
    this.hideLabel,
    String? label,
    this.style = RegexUIStyle.chips,
  }) : rules = rules ?? RegexModel.userNameRules(),
       decoration = InputDecoration(
         labelText: label ?? RegexLabels.current.userNameField,
       ),
       obscureText = false,
       keyboardType = TextInputType.text,
       autofillHints = const [AutofillHints.username],
       showStrength = false,
       strengthMode = RegexUIStrength.rules,
       strengthLabels = null;

  @override
  State<RegexTextField> createState() => _RegexTextFieldState();
}

class _RegexTextFieldState extends State<RegexTextField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocusNode;
  late bool _hidden = widget.obscureText;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void didUpdateWidget(RegexTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _hidden = widget.obscureText;
    }
  }

  @override
  void dispose() {
    _ownController?.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          obscureText: _hidden,
          enableSuggestions: !widget.obscureText,
          autocorrect: !widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          onFieldSubmitted: widget.onSubmitted,
          validator: RegexModel.validator(
            widget.rules,
            optional: widget.optional,
          ),
          decoration: widget.obscureText
              ? widget.decoration.copyWith(suffixIcon: _buildEye())
              : widget.decoration,
        ),
        RegexUI(
          controller: _controller,
          optional: widget.optional,
          focusNode: _focusNode,
          regexList: widget.rules,
          validate: widget.validate,
          visibility: widget.visibility,
          style: widget.style,
          showStrength: widget.showStrength,
          strengthMode: widget.strengthMode,
          strengthLabels: widget.strengthLabels,
          padding: const EdgeInsets.only(top: 8),
        ),
      ],
    );
  }

  Widget _buildEye() {
    return IconButton(
      tooltip: _hidden
          ? widget.showLabel ?? RegexLabels.current.show
          : widget.hideLabel ?? RegexLabels.current.hide,
      icon: Icon(
        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _hidden = !_hidden),
    );
  }
}
