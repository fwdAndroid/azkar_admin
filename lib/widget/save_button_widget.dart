import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SaveButton extends StatelessWidget {
  String title;
  final void Function()? onTap;

  SaveButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(335, 60),
        backgroundColor: Color(0xFF097132),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: ArabicText(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
