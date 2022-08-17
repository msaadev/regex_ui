import 'package:flutter/material.dart';

import '../models/regex_model.dart';

class RegexUI extends StatefulWidget {
  final Function(bool isValid)? validate;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<RegexModel> regexList;
  final EdgeInsets? padding, margin;
  final IconData? iconTrue, iconFalse;
  final Color? textColorTrue, textColorFalse, iconColorTrue, iconColorFalse;
  final BoxDecoration? boxDecoration;
  final TextStyle? textStyle;

  const RegexUI(
      {Key? key,
      required this.controller,
      required this.regexList,
      required this.focusNode,
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
      this.validate})
      : super(key: key);

  @override
  State<RegexUI> createState() => _RegexUIState();
}

class _RegexUIState extends State<RegexUI> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    focusNode = widget.focusNode;
    controller.addListener(() {
      if (mounted) {
        setState(() {
          if (widget.validate != null) {
            widget.validate!(_check);
          }
        });
      }
    });
    focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get mounted => super.mounted;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        child: child,
      ),
      duration: const Duration(milliseconds: 300),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (focusNode.hasFocus) {
      return Container(
        padding: widget.padding,
        margin: widget.margin,
        decoration: widget.boxDecoration,
        child: Column(
          children: widget.regexList
              .map((e) => row(
                  condition: e.regExp.hasMatch(controller.text),
                  text: e.title,
                  colorFalse:
                      e.colorFalse ?? widget.iconColorFalse ?? Colors.red,
                  colorTrue:
                      e.colorTrue ?? widget.iconColorTrue ?? Colors.green,
                  iconFalse: e.iconFalse ?? widget.iconFalse ?? Icons.clear,
                  textColorFalse:
                      e.textColorFalse ?? widget.textColorFalse ?? Colors.black,
                  textColorTrue:
                      e.textColorTrue ?? widget.textColorTrue ?? Colors.black,
                  iconTrue: e.iconTrue ?? widget.iconTrue ?? Icons.check,
                  textStyle: e.textStyle ?? widget.textStyle))
              .toList(),
        ),
      );
    }
    return const SizedBox();
  }

  Widget row({
    required bool condition,
    required String text,
    required Color colorFalse,
    required Color colorTrue,
    required Color textColorFalse,
    required Color textColorTrue,
    required IconData iconTrue,
    required IconData iconFalse,
    TextStyle? textStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
              maxRadius: 10,
              backgroundColor: condition ? colorTrue : colorFalse,
              child: Icon(
                condition ? iconTrue : iconFalse,
                color: Colors.white,
                size: 15,
              )),
          const SizedBox(
            width: 10,
          ),
          Text(
            text,
            style: (textStyle ?? Theme.of(context).textTheme.bodyText1)!
                .copyWith(color: condition ? textColorTrue : textColorFalse),
          )
        ],
      ),
    );
  }

  bool get _check {
    bool isDone = true;
    for (var element in widget.regexList) {
      if (!element.regExp.hasMatch(controller.text)) {
        isDone = false;
        break;
      }
    }

    return isDone;
  }
}
