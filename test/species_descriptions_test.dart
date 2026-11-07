import 'package:egg_incubator_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const speciesNames = {
    'Chicken': 'Chickens',
    'Duck': 'Philippine Mallard Duck',
    'Quail': 'Japanese Quail',
  };

  for (final species in defaultSpeciesList) {
    test(
      '${species.name} default and preset use farmer-facing information',
      () {
        expect(species.shortDescription, isNotEmpty);
        expect(species.description, contains(speciesNames[species.name]!));
        expect(species.description, contains('fertile'));
        for (final jargon in [
          'pilot',
          'software scope',
          'approval',
          'verified',
        ]) {
          expect(species.shortDescription, isNot(contains(jargon)));
          expect(species.description, isNot(contains(jargon)));
        }
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
        expect(loaded.shortDescription, species.shortDescription);
        expect(loaded.description, species.description);
        expect(loaded.temperature, species.temperature);
        expect(loaded.targetHumidity, species.targetHumidity);
        expect(loaded.incubationDays, species.incubationDays);
      },
    );
  }

  test('unknown species keeps its existing fallback', () {
    final loaded = SpeciesData.fromPreset({'egg_type': 'Unknown fixture'});
    expect(loaded.shortDescription, isEmpty);
    expect(loaded.description, 'Incubate eggs carefully.');
  });
}
