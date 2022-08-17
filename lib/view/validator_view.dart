import 'package:flutter/material.dart';

import '../models/regex_model.dart';

class ValidatorView extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<RegexModel> regexList;
  const ValidatorView({
    Key? key,
    required this.controller,
    required this.regexList,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<ValidatorView> createState() => _ValidatorViewState();
}

class _ValidatorViewState extends State<ValidatorView> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    focusNode = widget.focusNode;
    controller.addListener(() {
      debugPrint('changed');
      if (mounted) {
        setState(() {});
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
      child: focusNode.hasFocus
          ? Column(
              children: widget.regexList
                  .map((e) => row(
                      condition: e.regExp.hasMatch(controller.text),
                      text: e.title,
                      colorFalse: e.colorFalse,
                      colorTrue: e.colorTrue,
                      iconFalse: e.iconFalse,
                      iconTrue: e.iconTrue))
                  .toList(),
            )
          : const SizedBox(),
    );
  }

  Widget row({
    required bool condition,
    required String text,
    required Color colorFalse,
    required Color colorTrue,
    required IconData iconTrue,
    required IconData iconFalse,
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
            style: Theme.of(context).textTheme.bodyText1,
          )
        ],
      ),
    );
  }
}
