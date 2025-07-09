import 'package:azkar_admin/widget/arabic_text_widget.dart';
import 'package:flutter/material.dart';

showMessageBar(String contexts, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: ArabicText(contexts), duration: Duration(seconds: 3)),
  );
}
