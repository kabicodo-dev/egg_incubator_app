import 'package:egg_incubator_app/models/species_descriptions.dart';

/// Kath relayed the team's final Quail duration on 2026-10-31.
/// See docs/reference/SmartHatch_Final_Species_Reference.md. This is not a physical clock,
/// automatic completion rule, or approval of unrelated stage/control values.
const approvedQuailIncubationDays = 18;

class SpeciesData {
  final int? id;
  final String name;
  final String emoji;
  final int incubationDays;
  final String temperature;
  final int targetHumidity;
  final String description;
  final String shortDescription;

  const SpeciesData({
    this.id,
    required this.name,
    required this.emoji,
    required this.incubationDays,
    required this.temperature,
    required this.targetHumidity,
    required this.description,
    this.shortDescription = '',
  });

  factory SpeciesData.fromPreset(Map<String, dynamic> preset) {
    final type = preset['egg_type'] as String? ?? '';
    final emojiMap = {
      'Chicken': '\uD83D\uDC14',
      'Duck': '\uD83D\uDC26',
      'Quail': '\uD83E\uDD5A',
    };
    final descMap = {
      'Chicken': chickenDetailedDescription,
      'Duck': duckDetailedDescription,
      'Quail': quailDetailedDescription,
    };
    final shortDescMap = {
      'Chicken': chickenShortDescription,
      'Duck': duckShortDescription,
      'Quail': quailShortDescription,
    };
    final temp = preset['target_temperature'];
    final tempStr = temp != null ? '$temp\u00B0C' : '37.5\u00B0C';
    return SpeciesData(
      id: preset['id'] as int?,
      name: type,
      emoji: emojiMap[type] ?? '\uD83E\uDD5A',
      // Stale/missing preset data must not undo the approved Quail duration.
      // Other species mappings stay unchanged; no stored row is modified here.
      incubationDays: type == 'Quail'
          ? approvedQuailIncubationDays
          : preset['incubation_days'] as int? ?? 21,
      temperature: tempStr,
      targetHumidity: (preset['target_humidity'] as num?)?.round() ?? 55,
      description: descMap[type] ?? 'Incubate eggs carefully.',
      shortDescription: shortDescMap[type] ?? '',
    );
  }
}

const List<SpeciesData> defaultSpeciesList = [
  SpeciesData(
    name: 'Chicken',
    emoji: '\uD83D\uDC14',
    incubationDays: 21,
    temperature: '37.5\u00B0C',
    targetHumidity: 55,
    description: chickenDetailedDescription,
    shortDescription: chickenShortDescription,
  ),
  SpeciesData(
    name: 'Duck',
    emoji: '\uD83D\uDC26',
    incubationDays: 28,
    temperature: '37.5\u00B0C',
    targetHumidity: 65,
    description: duckDetailedDescription,
    shortDescription: duckShortDescription,
  ),
  SpeciesData(
    name: 'Quail',
    emoji: '\uD83E\uDD5A',
    incubationDays: approvedQuailIncubationDays,
    temperature: '37.5\u00B0C',
    targetHumidity: 58,
    description: quailDetailedDescription,
    shortDescription: quailShortDescription,
  ),
];

/// Species description for a stored session's egg_type: the shared defaults
/// when the name matches, or a safe generic fallback for an unknown/legacy
/// value so the real batch still renders. Top-level so Home, the setup
/// guard, and Batch Details all resolve species identically.
SpeciesData speciesDataForName(String name) {
  for (final s in defaultSpeciesList) {
    if (s.name == name) return s;
  }
  return SpeciesData(
    name: name.isEmpty ? 'Eggs' : name,
    emoji: '\uD83E\uDD5A',
    incubationDays: 21,
    temperature: '37.5\u00B0C',
    targetHumidity: 55,
    description: '',
  );
}
