import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool isObsecure;
  final TextEditingController controller;

  final Color fillColor;
  final bool filled;

  final Color borderColor;
  final Color focusedBorderColor;
  final double borderRadius;

  final Icon? prefixIcon;
  final IconButton? suffixIcon;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.isObsecure,
    required this.controller,
    required this.fillColor,
    required this.filled,
    required this.borderColor,
    required this.focusedBorderColor,
    required this.borderRadius,
    required this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
          controller: controller,
          obscureText: isObsecure,
          decoration: InputDecoration(
            hintText: hintText,
            filled: filled,
            fillColor: fillColor,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor),
                borderRadius: BorderRadius.circular(borderRadius)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: focusedBorderColor),
                borderRadius: BorderRadius.circular(borderRadius)),
            prefixIcon: prefixIcon, 
            suffixIcon: suffixIcon
          )),
    );
  }
}
