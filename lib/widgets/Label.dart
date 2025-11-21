import 'package:flutter/material.dart';

Widget buildLabel(String text, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
  );
}