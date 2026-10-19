import 'dart:ui';
import 'package:flutter/material.dart';

class IOSColors {
  static const Color background = Color(0xFFF2F2F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF2F2F7);
  static const Color separator = Color(0xFFC6C6C8);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSurfaceSecondary = Color(0xFF2C2C2E);
  static const Color darkSeparator = Color(0xFF38383A);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color blue = Color(0xFF007AFF);
  static const Color green = Color(0xFF34C759);
  static const Color red = Color(0xFFFF3B30);
  static const Color orange = Color(0xFFFF9500);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color purple = Color(0xFFAF52DE);
  static const Color pink = Color(0xFFFF2D55);
  static const Color teal = Color(0xFF5AC8FA);
  static const Color indigo = Color(0xFF5856D6);
}

class IOSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final bool blur;
  final VoidCallback? onTap;

  const IOSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.color,
    this.blur = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? IOSColors.darkSurface : IOSColors.surface);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: isDark ? IOSColors.darkSeparator : IOSColors.separator.withOpacity(0.5), width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: blur
              ? ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: child))
              : child,
        ),
      ),
    );
  }
}

class IOSButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color color;
  final bool filled;
  final bool small;

  const IOSButton({super.key, required this.label, required this.onPressed, this.icon, this.color = IOSColors.blue, this.filled = true, this.small = false});

  @override
  Widget build(BuildContext context) {
    final height = small ? 32.0 : 44.0;
    final fontSize = small ? 13.0 : 16.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(height / 2),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: small ? 12 : 20),
          decoration: BoxDecoration(color: filled ? color : color.withOpacity(0.15), borderRadius: BorderRadius.circular(height / 2)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: small ? 14 : 18, color: filled ? Colors.white : color), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: filled ? Colors.white : color, fontSize: fontSize, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class IOSInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const IOSInput({super.key, required this.controller, required this.label, this.hint, this.icon, this.keyboardType, this.maxLines = 1, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textSecondary))),
      Container(
        decoration: BoxDecoration(color: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          style: TextStyle(fontSize: 16, color: isDark ? IOSColors.darkTextPrimary : IOSColors.textPrimary),
          decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: isDark ? IOSColors.textTertiary : IOSColors.textTertiary), prefixIcon: icon != null ? Icon(icon, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textSecondary) : null, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        ),
      ),
    ]);
  }
}

class IOSKPI extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const IOSKPI({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(isDark ? 0.25 : 0.15), color.withOpacity(isDark ? 0.15 : 0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? IOSColors.darkTextPrimary : IOSColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textSecondary, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class IOSSegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const IOSSegmentedControl({super.key, required this.options, required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: isDark ? IOSColors.darkSurfaceSecondary : IOSColors.surfaceSecondary, borderRadius: BorderRadius.circular(10)),
      child: Row(children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = index == selectedIndex;
        return Expanded(child: GestureDetector(onTap: () => onSelected(index), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: isSelected ? (isDark ? IOSColors.darkSurface : IOSColors.surface) : Colors.transparent, borderRadius: BorderRadius.circular(8), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : null), child: Center(child: Text(option, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? (isDark ? IOSColors.darkTextPrimary : IOSColors.textPrimary) : (isDark ? IOSColors.darkTextSecondary : IOSColors.textSecondary)))))));
      }).toList()),
    );
  }
}

class IOSBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const IOSBadge({super.key, required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: filled ? color : color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: filled ? Colors.white : color)));
  }
}

class IOSLargeTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const IOSLargeTitle({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: isDark ? IOSColors.darkTextPrimary : IOSColors.textPrimary, letterSpacing: -0.5)),
      if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: TextStyle(fontSize: 15, color: isDark ? IOSColors.darkTextSecondary : IOSColors.textSecondary))],
    ]));
  }
}