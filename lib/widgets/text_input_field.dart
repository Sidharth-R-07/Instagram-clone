import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  final bool obscureInput;
  final String hint;
  final Function(String?) validatorFn;
  final TextInputType keyboardType;
  final TextEditingController controller;
  const TextInputField({
    super.key,
    required this.hint,
    required this.keyboardType,
    required this.controller,
    this.obscureInput = false,
    required this.validatorFn,
  });
  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));

    return TextFormField(
      controller: controller,
      validator: (value) => validatorFn(value),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: keyboardType,
      obscureText: obscureInput,
    );
  }
}
