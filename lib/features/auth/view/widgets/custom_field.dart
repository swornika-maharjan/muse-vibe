import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String hintText;
  const CustomField({
    super.key,
    required this.hintText,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: widget.hintText, // Access hintText from the widget
      ),
    );
  }
}
