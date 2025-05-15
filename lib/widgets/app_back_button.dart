// Flutter imports:
import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
