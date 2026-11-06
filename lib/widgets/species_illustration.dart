import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

// ── Shared species illustration ──

/// The local bird PNG from `assets/species/` on a soft-peach circle, used
/// everywhere a species-specific graphic appears.
///
/// Species names are matched case-insensitively ('Chicken', 'duck', …).
/// Unknown or missing species fall back to [emoji] (or a generic egg glyph)
/// so future presets never crash, and each illustration is announced to
/// screen readers as its own image node.
class SpeciesIllustration extends StatelessWidget {
  const SpeciesIllustration({
    super.key,
    required this.species,
    this.emoji,
    this.size = 56,
    this.artwork,
    this.label,
  });

  /// Species name, e.g. 'Chicken'. Case-insensitive; may be null/unknown.
  final String? species;

  /// Fallback glyph shown when [species] has no local illustration.
  final String? emoji;

  /// Diameter of the peach circle.
  final double size;

  /// Diameter of the artwork; defaults to ~76% of [size].
  final double? artwork;

  /// Screen-reader label; defaults to 'Illustration of a [species] bird'
  /// for known species and 'Species illustration' otherwise.
  final String? label;

  /// Species that have a local illustration asset.
  static const Set<String> _illustrated = {'chicken', 'duck', 'quail'};

  @override
  Widget build(BuildContext context) {
    final String key = (species ?? '').trim().toLowerCase();
    final bool hasArt = _illustrated.contains(key);
    final double art = artwork ?? size * 0.76;
    final String friendly = (species ?? '').trim();
    return Semantics(
      container: true,
      image: true,
      excludeSemantics: true,
      label:
          label ??
          (hasArt
              ? 'Illustration of a $friendly bird'
              : 'Species illustration'),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.peach,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: hasArt
              ? SizedBox(
                  width: art,
                  height: art,
                  child: Image.asset(
                    'assets/species/$key.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackGlyph(art),
                  ),
                )
              : _fallbackGlyph(art),
        ),
      ),
    );
  }

  /// Emoji when we have one, otherwise a generic egg mark - never a crash.
  Widget _fallbackGlyph(double art) {
    final String? glyph = emoji;
    if (glyph != null && glyph.isNotEmpty) {
      return Text(glyph, style: TextStyle(fontSize: art * 0.62));
    }
    return Icon(
      Icons.egg_outlined,
      size: art * 0.75,
      color: AppColors.primaryDark,
    );
  }
}
