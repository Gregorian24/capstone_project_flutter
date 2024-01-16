import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputLayout extends StatelessWidget {
  StatefulWidget inputField;

  InputLayout(
    this.inputField, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        child: inputField,
      ),
      const SizedBox(
        height: 15,
      ),
    ]);
  }
}

InputDecoration customInputDecoration(String hintText,
    {Widget? prefixIcon, Widget? suffixIcon}) {
  return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      floatingLabelBehavior: FloatingLabelBehavior.never);
}

InputDecoration notesInputDecoration(String hintText, {Widget? suffixIcon}) {
  return InputDecoration(
      hintText: hintText,
      label: Text(hintText),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));
}
