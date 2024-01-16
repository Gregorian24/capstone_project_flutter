import 'package:flutter/material.dart';

var primaryColor = Color.fromARGB(255, 97, 136, 244);
var secondaryColor = Color.fromARGB(255, 77, 107, 190);
var negativeColor = const Color(0xFFE76F51);
var positiveColor = const Color(0xFF2A9D8F);
var backgroundColorSubtle = Color.fromARGB(255, 197, 241, 255);
var greyColor = const Color(0xFFAFAFAF);

TextStyle headerStyle({int level = 1, bool dark = true}) {
  List<double> levelSize = [30, 24, 20];
  return TextStyle(
      fontSize: levelSize[level - 1],
      fontWeight: FontWeight.bold,
      color: dark ? Colors.black : Colors.white);
}

TextStyle transactionStyle(int amount) {
  return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: amount < 0 ? negativeColor : positiveColor);
}

TextStyle transactionStyleBig(int amount) {
  return TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: amount < 0 ? negativeColor : positiveColor);
}

transactionColor(String category) {}

var buttonStyle = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    backgroundColor: primaryColor);
