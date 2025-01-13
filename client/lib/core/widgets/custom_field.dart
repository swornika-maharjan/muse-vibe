import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isObscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator; // Optional custom validator

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      validator: (val) {
        // Default validation for empty fields
        if (val == null || val.trim().isEmpty) {
          return "$hintText is missing!";
        }

        // Apply custom validation if provided
        if (validator != null) {
          return validator!(val);
        }

        return null; // Passes validation if no issues
      },
      obscureText: isObscureText,
    );
  }
}
