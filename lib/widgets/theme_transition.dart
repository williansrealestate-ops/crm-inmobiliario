import 'package:flutter/material.dart';

class ThemeTransition extends StatelessWidget {
  final Widget child;

  const ThemeTransition({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: Theme.of(context),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }
}