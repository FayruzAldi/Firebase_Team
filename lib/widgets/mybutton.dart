import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String? text;
  final String? imageAsset; 
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;
  final Color? sideColor;
  final double elevation;
  final VoidCallback onPressed;

  const MyButton({
    super.key,
    this.text,
    this.imageAsset, 
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.onPressed,
    required this.borderRadius,
    this.sideColor,
    required this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          side: sideColor != null ? BorderSide(color: sideColor!) : BorderSide.none,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevation,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              height: 24,
              width: 24,
            ),
          if (imageAsset != null) SizedBox(width: 8), 
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                text ?? "",
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
