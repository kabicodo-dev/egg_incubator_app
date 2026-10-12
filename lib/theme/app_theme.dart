import 'package:flutter/material.dart';

// ──────────────────────────────────────────────
// SmartHatch design tokens
//
// Single source of truth for the "Modern and Farmer-Friendly" redesign.
// Widgets reference these constants instead of raw hex values so a palette
// change stays a one-line edit.
//
// Contrast ratios quoted below were measured with the WCAG 2.x relative
// luminance formula against the stated background. Text tokens aim for
// WCAG AA (>= 4.5:1 for normal-size text).
// ──────────────────────────────────────────────

abstract final class AppColors {
  // ── Brand oranges ─────────────────────────────────────

  /// Bright SmartHatch orange for accents that do not carry small text:
  /// decorative accents and icons on dark surfaces.
  ///
  /// Only 2.9:1 on white, so it must **not** be used for text on light
  /// surfaces - use [primaryDark] there instead.
  static const Color primary = Color(0xFFFF6B00);

  /// Pressed tone of the bright [primary] accent.
  static const Color primaryPressed = Color(0xFFE85D00);

  /// Readable orange for light surfaces: orange text on white/cream and the
  /// background of primary buttons with white labels. 4.8:1 in both
  /// directions, so both stay within WCAG AA.
  static const Color primaryDark = Color(0xFFC24E00);

  /// Pressed state of [primaryDark]; white labels stay at 6.1:1.
  static const Color primaryDarkPressed = Color(0xFFA84200);

  // ── Surfaces ──────────────────────────────────────────

  /// Warm cream page background.
  static const Color background = Color(0xFFF9F6F0);

  /// White card surface on [background].
  static const Color card = Color(0xFFFFFFFF);

  /// Soft peach accent surface (e.g. the disconnected hardware state and
  /// the selected navigation indicator).
  static const Color peach = Color(0xFFFFF0E5);

  /// Very subtle warm hairline for white surfaces floating on the cream
  /// background (e.g. the navigation pill).
  static const Color borderWarm = Color(0xFFF0E5DB);

  /// Light cream surface for subtle warm highlights.
  static const Color cream = Color(0xFFFFF8F0);

  /// White surface of the floating bottom navigation pill.
  static const Color navigationSurface = Color(0xFFFFFFFF);

  /// Inactive icon and label colour on the white navigation pill. 5.6:1.
  static const Color navigationInactive = Color(0xFF686868);

  // ── Text ──────────────────────────────────────────────

  /// Primary text colour. 19:1 on white.
  static const Color textPrimary = Color(0xFF121212);

  /// Secondary text colour. 6.9:1 on white.
  static const Color textSecondary = Color(0xFF5A5A5E);

  // ── Status ────────────────────────────────────────────

  /// Success text and badges. 5.1:1 on white.
  static const Color success = Color(0xFF2E7D32);

  /// Danger text and badges. 5.6:1 on white.
  static const Color danger = Color(0xFFC62828);

  /// Darker amber for readable "connecting"/warning text and icons. 5.4:1 on
  /// white - the bright amber stays reserved for decorative accents.
  static const Color warning = Color(0xFF9A5B00);
}

/// Corner radii used across the redesigned screens.
abstract final class AppRadius {
  /// Rounded corners of cards.
  static const double card = 20;

  /// Full pill radius for primary buttons and the floating navigation.
  static const double pill = 28;

  /// Inputs, search fields and smaller controls.
  static const double control = 16;

  /// Fully rounded badges and chips (clamped by the widget size).
  static const double badge = 999;
}

/// Spacing steps for consistent padding and gaps.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Soft elevation shadows - no heavy or coloured shadows.
abstract final class AppShadows {
  /// Subtle lift for cards (black at 4%).
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Elevation of the floating navigation pill (black at 18%).
  static const List<BoxShadow> navigationPill = [
    BoxShadow(color: Color(0x2E000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  /// Warm glow under primary buttons ([AppColors.primaryDark] at 25%).
  static const List<BoxShadow> primaryButton = [
    BoxShadow(color: Color(0x40C24E00), blurRadius: 16, offset: Offset(0, 6)),
  ];
}
