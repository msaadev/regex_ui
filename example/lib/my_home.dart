import 'package:flutter/material.dart';
import 'package:regex_ui/models/regex_model.dart';
import 'package:regex_ui/regex_ui.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late final TextEditingController textEditingController,
      textEditingController2;
  late final FocusNode focusNode, focusNode2;

  @override
  void initState() {
    textEditingController = TextEditingController();
    textEditingController2 = TextEditingController();
    focusNode = FocusNode();
    focusNode2 = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textEditingController2.dispose();
    focusNode.dispose();
    focusNode2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textEditingController,
              focusNode: focusNode,
            ),
            ValidatorView(
              controller: textEditingController,
              focusNode: focusNode,
              regexList: [
                RegexModel(
                    title: 'Password must be at least 6 character',
                    regExp: RegExp(r'^.{6,50}$'),
                    colorFalse: Colors.red,
                    colorTrue: Colors.yellow,
                    iconFalse: Icons.dangerous,
                    iconTrue: Icons.abc),
                RegexModel(
                    title: 'Password must be at least 6 character',
                    regExp: RegExp(r'^(?=.*\d)|(?=.*[^\w\s]).{1,}$')),
                RegexModel(
                    title: 'Password must be at least 6 character',
                    regExp: RegExp(r'^(?=.*[\D]).{1,}$')),
              ],
            ),
            TextField(
              controller: textEditingController2,
              focusNode: focusNode2,
            ),
            ValidatorView(
              controller: textEditingController2,
              focusNode: focusNode2,
              regexList: [
                RegexModel(
                  title: 'Password must be at least 10 character',
                  regExp: RegExp(r'^.{10,50}$'),
                ),
                RegexModel(
                    title: 'add one number',
                    regExp: RegExp(r'^(?=.*\d)|(?=.*[^\w\s]).{1,}$')),
                RegexModel(
                    title: 'add one letter',
                    regExp: RegExp(r'^(?=.*[\D]).{1,}$')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
