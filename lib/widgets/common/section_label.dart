import 'package:flutter/material.dart';

// ══════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }
}
