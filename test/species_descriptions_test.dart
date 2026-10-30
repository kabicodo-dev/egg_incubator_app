import 'package:egg_incubator_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Exact user-approved wording, not approval of incubation profile numbers.
  const wording = {
    'Chicken': (
      'Chicken eggs — the planned physical-pilot species.',
      'Use fresh, fertile chicken eggs only. The Chicken pilot requires '
          'readiness and safety approval before use. Incubation settings must '
          'follow the team-approved Chicken profile. Viewing details does not '
          'start incubation, confirm fertility, or guarantee hatching.',
    ),
    'Duck': (
      'Duck eggs — included in the intended software scope; not the current '
          'physical pilot.',
      'SmartHatch includes a Duck selection in its intended software scope. '
          'Physical Duck incubation has not been verified for this project. The '
          'current physical pilot is Chicken-only. Any later Duck testing '
          'requires fresh, fertile eggs, approved profiles, and separate '
          'readiness and safety authorization.',
    ),
    'Quail': (
      'Quail eggs — included in the intended software scope; not the current '
          'physical pilot.',
      'SmartHatch includes a Quail selection in its intended software scope. '
          'Physical Quail incubation has not been verified for this project. The '
          'current physical pilot is Chicken-only. Any later Quail testing '
          'requires fresh, fertile eggs, approved profiles, and separate '
          'readiness and safety authorization.',
    ),
  };

  for (final species in defaultSpeciesList) {
    test('${species.name} default and preset use exact approved wording', () {
      final expected = wording[species.name]!;
      expect(species.shortDescription, expected.$1);
      expect(species.description, expected.$2);
      // Preserve the current schema and numerical mapping. Values copied from
      // existing defaults solely for a mapping test, not profile approval.
      final temperature = double.parse(
        species.temperature.replaceAll('°C', ''),
      );
      final loaded = SpeciesData.fromPreset({
        'id': 1,
        'egg_type': species.name,
        'target_temperature': temperature,
        'target_humidity': species.targetHumidity,
        'incubation_days': species.incubationDays,
      });
      expect(loaded.shortDescription, expected.$1);
      expect(loaded.description, expected.$2);
      expect(loaded.temperature, species.temperature);
      expect(loaded.targetHumidity, species.targetHumidity);
      expect(loaded.incubationDays, species.incubationDays);
    });
  }

  test('unknown species keeps its existing fallback', () {
    final loaded = SpeciesData.fromPreset({'egg_type': 'Unknown fixture'});
    expect(loaded.shortDescription, isEmpty);
    expect(loaded.description, 'Incubate eggs carefully.');
  });
}
