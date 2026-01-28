import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController controller; // ✅ SALVA O CONTROLLER

  const AppInput({
    super.key,
    required this.hint,
    required this.controller, // ✅ RECEBE
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller, // 🔥 USA O CONTROLLER
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
