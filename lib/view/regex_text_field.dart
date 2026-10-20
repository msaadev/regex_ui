import 'package:flutter/material.dart';

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
  final String showLabel, hideLabel;

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
    this.visibility = RegexUIVisibility.focus,
    this.style = RegexUIStyle.list,
    this.showStrength = false,
    this.strengthMode = RegexUIStrength.rules,
    this.strengthLabels,
    this.showLabel = 'Show',
    this.hideLabel = 'Hide',
  });

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
          validator: RegexModel.validator(widget.rules),
          decoration: widget.obscureText
              ? widget.decoration.copyWith(suffixIcon: _buildEye())
              : widget.decoration,
        ),
        RegexUI(
          controller: _controller,
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
      tooltip: _hidden ? widget.showLabel : widget.hideLabel,
      icon: Icon(
        _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _hidden = !_hidden),
    );
  }
}
