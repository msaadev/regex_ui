import 'package:flutter/material.dart';

import '../models/password_strength.dart';
import '../models/regex_model.dart';

/// When the rule list is shown.
enum RegexUIVisibility {
  /// Only while the field has focus (needs a `focusNode`).
  focus,

  /// Always.
  always,
}

/// How the rules are laid out.
enum RegexUIStyle {
  /// One rule per row with a round badge.
  list,

  /// Rules as wrapping chips; compact, good under wide fields.
  chips,
}

/// What the strength bar measures.
enum RegexUIStrength {
  /// Share of the rules that are met.
  rules,

  /// Real password strength from [passwordStrength] (0–4), independent of the
  /// rules.
  password,
}

/// Live checklist for a text field: shows which rules (password, user name,
/// e-mail, …) the current input meets.
class RegexUI extends StatefulWidget {
  /// Called on every change with whether all rules are met.
  final Function(bool isValid)? validate;

  /// The field's controller; the rules are checked against its text.
  final TextEditingController controller;

  /// The field's focus node. Needed for [RegexUIVisibility.focus].
  final FocusNode? focusNode;

  /// The rules to show, in order.
  final List<RegexModel> regexList;

  /// Padding and margin of the rule box.
  final EdgeInsets? padding, margin;

  /// Default icon when a rule is met / not met.
  final IconData? iconTrue, iconFalse;

  /// Default text colors when a rule is met / not met.
  final Color? textColorTrue, textColorFalse;

  /// Default badge colors when a rule is met / not met.
  final Color? iconColorTrue, iconColorFalse;

  /// Decoration of the rule box.
  final BoxDecoration? boxDecoration;

  /// Default text style of the rule titles.
  final TextStyle? textStyle;

  /// When the rules are shown. Defaults to [RegexUIVisibility.focus] when a
  /// [focusNode] is given, otherwise [RegexUIVisibility.always].
  final RegexUIVisibility? visibility;

  /// List or chips.
  final RegexUIStyle style;

  /// Shows a strength bar above the rules.
  final bool showStrength;

  /// What the bar measures: met rules or real password strength.
  final RegexUIStrength strengthMode;

  /// Words shown next to the bar, weakest first, e.g. Weak / Fair / Strong.
  /// Defaults to five English labels in [RegexUIStrength.password] mode and
  /// none in [RegexUIStrength.rules] mode.
  final List<String>? strengthLabels;

  /// Screen reader words for a met / not met rule.
  final String metLabel, unmetLabel;

  /// Creates the checklist for [controller].
  const RegexUI({
    super.key,
    required this.controller,
    required this.regexList,
    this.focusNode,
    this.padding,
    this.margin,
    this.boxDecoration,
    this.iconTrue,
    this.iconFalse,
    this.textColorTrue,
    this.textColorFalse,
    this.iconColorTrue,
    this.iconColorFalse,
    this.textStyle,
    this.validate,
    this.visibility,
    this.style = RegexUIStyle.list,
    this.showStrength = false,
    this.strengthMode = RegexUIStrength.rules,
    this.strengthLabels,
    this.metLabel = 'met',
    this.unmetLabel = 'not met',
  });

  @override
  State<RegexUI> createState() => _RegexUIState();
}

class _RegexUIState extends State<RegexUI> {
  bool get _visible {
    final visibility =
        widget.visibility ??
        (widget.focusNode == null
            ? RegexUIVisibility.always
            : RegexUIVisibility.focus);
    return visibility == RegexUIVisibility.always ||
        (widget.focusNode?.hasFocus ?? true);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(RegexUI oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _visible
          ? _buildBox(context)
          : const SizedBox(width: double.infinity),
    );
  }

  Widget _buildBox(BuildContext context) {
    final text = widget.controller.text;
    final results = [for (final rule in widget.regexList) rule.matches(text)];
    return Container(
      width: double.infinity,
      padding: widget.padding,
      margin: widget.margin,
      decoration: widget.boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showStrength) _buildStrength(context, results),
          if (widget.style == RegexUIStyle.chips)
            _buildChips(context, results)
          else
            for (var i = 0; i < results.length; i++)
              _buildRow(context, widget.regexList[i], results[i]),
        ],
      ),
    );
  }

  Widget _buildStrength(BuildContext context, List<bool> results) {
    final (:ratio, :level) = _strength(results);
    final labels =
        widget.strengthLabels ??
        (widget.strengthMode == RegexUIStrength.password
            ? const ['Very weak', 'Weak', 'Fair', 'Good', 'Strong']
            : null);
    final label = labels == null || labels.isEmpty
        ? null
        : labels[(level * (labels.length - 1)).round()];
    final color = Color.lerp(
      Theme.of(context).colorScheme.error,
      _metColor(context, null),
      ratio,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Semantics(
        label: label ?? '${(ratio * 100).round()}%',
        excludeSemantics: true,
        child: Row(
          children: [
            Expanded(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: ratio),
                duration: const Duration(milliseconds: 300),
                builder: (_, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, RegexModel rule, bool met) {
    return Semantics(
      label: '${rule.title}: ${met ? widget.metLabel : widget.unmetLabel}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildBadge(context, rule, met),
            const SizedBox(width: 10),
            Expanded(child: _buildTitle(context, rule, met)),
          ],
        ),
      ),
    );
  }

  Widget _buildChips(BuildContext context, List<bool> results) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < results.length; i++)
            Semantics(
              label:
                  '${widget.regexList[i].title}: '
                  '${results[i] ? widget.metLabel : widget.unmetLabel}',
              excludeSemantics: true,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                decoration: BoxDecoration(
                  color: results[i]
                      ? _metColor(
                          context,
                          widget.regexList[i],
                        ).withValues(alpha: 0.12)
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildBadge(context, widget.regexList[i], results[i]),
                    const SizedBox(width: 6),
                    _buildTitle(context, widget.regexList[i], results[i]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, RegexModel rule, bool met) {
    final color = met ? _metColor(context, rule) : _unmetColor(context, rule);
    final icon = met
        ? rule.iconTrue ?? widget.iconTrue ?? Icons.check_rounded
        : rule.iconFalse ?? widget.iconFalse ?? Icons.close_rounded;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          icon,
          key: ValueKey(met),
          size: 14,
          color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, RegexModel rule, bool met) {
    final scheme = Theme.of(context).colorScheme;
    final color = met
        ? rule.textColorTrue ?? widget.textColorTrue ?? scheme.onSurface
        : rule.textColorFalse ??
              widget.textColorFalse ??
              scheme.onSurfaceVariant;
    final base =
        rule.textStyle ??
        widget.textStyle ??
        Theme.of(context).textTheme.bodyMedium ??
        const TextStyle();
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: base.copyWith(color: color),
      child: Text(rule.title),
    );
  }

  // ratio fills the bar; level (0–1) picks the label.
  ({double ratio, double level}) _strength(List<bool> results) {
    if (widget.strengthMode == RegexUIStrength.password) {
      final text = widget.controller.text;
      if (text.isEmpty) return (ratio: 0, level: 0);
      final score = passwordStrength(text);
      return (ratio: (score + 1) / 5, level: score / 4);
    }
    final ratio = results.isEmpty
        ? 0.0
        : results.where((ok) => ok).length / results.length;
    return (ratio: ratio, level: ratio);
  }

  Color _metColor(BuildContext context, RegexModel? rule) =>
      rule?.colorTrue ?? widget.iconColorTrue ?? Colors.green.shade600;

  Color _unmetColor(BuildContext context, RegexModel rule) =>
      rule.colorFalse ??
      widget.iconColorFalse ??
      Theme.of(context).colorScheme.outlineVariant;

  void _onTextChanged() {
    if (!mounted) return;
    setState(() {});
    final valid = widget.regexList.every(
      (rule) => rule.matches(widget.controller.text),
    );
    widget.validate?.call(valid);
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }
}
