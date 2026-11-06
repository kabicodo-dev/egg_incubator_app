import 'package:flutter/material.dart';
import 'package:egg_incubator_app/app.dart';
import 'package:egg_incubator_app/screens/admin/admin_preview_screen.dart';

/// Isolated UI entry point: intentionally no Supabase, credentials or hardware.
void main() => runApp(const AdminPreviewApp());

class AdminPreviewApp extends StatelessWidget {
  const AdminPreviewApp({super.key});

  @override
  Widget build(BuildContext context) => const SmartHatchApp(
    home: AdminPreviewScreen(),
  );
}
