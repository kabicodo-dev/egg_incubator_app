import 'package:egg_incubator_app/controllers/incubator_controller.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('team-approved Quail duration is 18 in defaults and name lookup', () {
    final quail = defaultSpeciesList.singleWhere((s) => s.name == 'Quail');
    expect(approvedQuailIncubationDays, 18);
    expect(quail.incubationDays, 18);
    expect(speciesDataForName('Quail').incubationDays, 18);
    // Consistency only: not approval of controller stages or thresholds.
    expect(IncubationProfile.quail.hatchDay, quail.incubationDays);
  });

  for (final duration in [null, 17, 18, 21]) {
    test('Quail preset duration $duration cannot replace approved 18 days', () {
      final quail = SpeciesData.fromPreset({
        'id': 3,
        'egg_type': 'Quail',
        'incubation_days': duration,
        'target_temperature': 37.5,
        'target_humidity': 58,
      });
      expect(quail.incubationDays, 18);
      expect(quail.id, 3);
      expect(quail.targetHumidity, 58); // Existing mapping, not approval.
    });
  }

  test('other species mappings and historical input maps are unchanged', () {
    for (final name in ['Chicken', 'Duck']) {
      final row = <String, dynamic>{
        'egg_type': name,
        'incubation_days': 31,
        'target_temperature': 36.9,
        'target_humidity': 61,
      };
      final species = SpeciesData.fromPreset(row);
      expect(species.incubationDays, 31);
      expect(species.targetHumidity, 61);
      expect(row['incubation_days'], 31);
    }
    final oldQuailRow = <String, dynamic>{
      'egg_type': 'Quail',
      'incubation_days': 17,
    };
    expect(SpeciesData.fromPreset(oldQuailRow).incubationDays, 18);
    expect(oldQuailRow['incubation_days'], 17);
  });
}
