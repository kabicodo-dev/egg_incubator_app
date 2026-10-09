import 'package:flutter_test/flutter_test.dart';
import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/controllers/incubator_controller.dart';

void main() {
  testWidgets('SmartHatch Incubator Dashboard smoke test with Day 7 start and 6-12 egg capacity', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify key titles, Day 7 post-candling start, and egg capacity card are displayed
    expect(find.text('SmartHatch Controller'), findsOneWidget);
    expect(find.text('Day 7'), findsOneWidget);
    expect(find.text('Fertile Egg Tray & Capacity'), findsOneWidget);
    expect(find.text('Incubator Chamber'), findsOneWidget);
    expect(find.text('Brooder Chamber'), findsOneWidget);
    expect(find.textContaining('Fertile Verified'), findsWidgets);
  });

  test('Egg count validation: starts at 6, enforces 6-12 range, strictly disallows 0 eggs', () {
    final controller = IncubatorController(profile: IncubationProfile.chicken);

    // Initial state: starts at 6 fertile eggs and Day 7 post-candling
    expect(controller.eggCount, 6);
    expect(controller.startDay, 7);
    expect(controller.currentIncubationDay, 7);

    // Valid range: 6 to 12 eggs
    controller.setEggCount(8);
    expect(controller.eggCount, 8);

    controller.setEggCount(12);
    expect(controller.eggCount, 12);

    controller.setEggCount(6);
    expect(controller.eggCount, 6);

    // Strict validation: system shall not allow 0 eggs
    expect(
      () => controller.setEggCount(0),
      throwsA(isA<ArgumentError>().having(
        (e) => e.message,
        'message',
        contains('cannot be 0'),
      )),
    );

    // Starting batch with 0 eggs must also be rejected
    expect(
      () => controller.startNewBatch(IncubationProfile.chicken, 0),
      throwsA(isA<ArgumentError>().having(
        (e) => e.message,
        'message',
        contains('cannot be 0'),
      )),
    );

    // Values below 6 or above 12 must be rejected
    expect(() => controller.setEggCount(5), throwsA(isA<ArgumentError>()));
    expect(() => controller.setEggCount(13), throwsA(isA<ArgumentError>()));
    expect(() => controller.setEggCount(-1), throwsA(isA<ArgumentError>()));

    controller.dispose();
  });

  test('IncubatorController hysteresis and Day 7 post-candling stages for Chicken', () {
    final controller = IncubatorController(profile: IncubationProfile.chicken);

    // Initial Chicken incubation checks: begins after Day 7 candling
    expect(controller.currentIncubationDay, 7);
    expect(controller.startDay, 7);
    expect(controller.isLockdown, false);
    expect(controller.stageName, 'ACTIVE INCUBATION');
    expect(controller.humidityLowLimit, 45.0);
    expect(controller.humidityHighLimit, 55.0);

    // Temperature <= 37.5 -> Heat Bulb should turn ON
    controller.updateSensors(incTemp: 37.3, incHumidity: 48.0);
    expect(controller.incubatorBulbState, true);

    // Temperature >= 38.0 -> Heat Bulb should turn OFF
    controller.updateSensors(incTemp: 38.1, incHumidity: 48.0);
    expect(controller.incubatorBulbState, false);

    // Humidity < 45.0 -> Humidifier should turn ON
    controller.updateSensors(incTemp: 37.6, incHumidity: 42.0);
    expect(controller.incubatorHumidifierState, true);

    // Humidity >= 55.0 -> Humidifier should turn OFF
    controller.updateSensors(incTemp: 37.6, incHumidity: 56.0);
    expect(controller.incubatorHumidifierState, false);

    // Advance to Lockdown Day (Day 19 = (19 - 7) * 86400 seconds in the incubator)
    controller.elapsedSeconds = (19 - 7) * 86400;
    expect(controller.currentIncubationDay, 19);
    expect(controller.isLockdown, true);
    expect(controller.stageName, 'LOCKDOWN / HATCHING');

    // Advance to Complete (Day 21 = (21 - 7) * 86400 seconds in the incubator)
    controller.elapsedSeconds = (21 - 7) * 86400;
    expect(controller.currentIncubationDay, 21);
    expect(controller.isBatchComplete, true);
    expect(controller.stageName, 'BATCH COMPLETE');

    controller.dispose();
  });

  test('IncubatorController Duck egg stages starting after Day 7 candling', () {
    final controller = IncubatorController(profile: IncubationProfile.duck);

    // Initial Duck batch checks: starts at Day 7, 28 days total hatch
    expect(controller.profile.speciesName, 'Duck');
    expect(controller.profile.hatchDay, 28);
    expect(controller.profile.lockdownStartDay, 26);
    expect(controller.startDay, 7);
    expect(controller.currentIncubationDay, 7);
    expect(controller.isLockdown, false);
    expect(controller.stageName, 'ACTIVE INCUBATION');
    expect(controller.eggTurningStatus, 'ACTIVE (EVERY 4 HOURS)');

    // Active Humidity range for Duck: 55.0 - 60.0 %
    expect(controller.humidityLowLimit, 55.0);
    expect(controller.humidityHighLimit, 60.0);

    // Active turning & humidifier test for Duck
    controller.updateSensors(incTemp: 37.5, incHumidity: 52.0);
    expect(controller.incubatorHumidifierState, true); // < 55.0% -> ON

    controller.updateSensors(incTemp: 37.5, incHumidity: 61.0);
    expect(controller.incubatorHumidifierState, false); // >= 60.0% -> OFF

    // Advance to Lockdown Day (Day 26 = (26 - 7) * 86400 = 19 * 86400 seconds)
    controller.elapsedSeconds = 19 * 86400;
    expect(controller.currentIncubationDay, 26);
    expect(controller.isLockdown, true);
    expect(controller.stageName, 'LOCKDOWN / HATCHING');
    expect(controller.eggTurningStatus, 'STOPPED (LOCKDOWN)');

    // Lockdown Humidity range for Duck: 70.0 - 75.0 %
    expect(controller.humidityLowLimit, 70.0);
    expect(controller.humidityHighLimit, 75.0);

    // Advance to Complete (Day 28 = (28 - 7) * 86400 = 21 * 86400 seconds)
    controller.elapsedSeconds = 21 * 86400;
    expect(controller.currentIncubationDay, 28);
    expect(controller.isBatchComplete, true);
    expect(controller.stageName, 'BATCH COMPLETE');

    controller.dispose();
  });

  test('IncubatorController Quail egg stages starting after Day 7 candling', () {
    final controller = IncubatorController(profile: IncubationProfile.quail);

    // Initial Quail batch checks matching SmartHatch_Quail_Automatic_Stages.ino
    expect(controller.profile.speciesName, 'Quail');
    expect(controller.profile.hatchDay, 18);
    expect(controller.profile.lockdownStartDay, 15);
    expect(controller.profile.eepromMagic, 0xA318);
    expect(controller.startDay, 7);
    expect(controller.currentIncubationDay, 7);
    expect(controller.isLockdown, false);
    expect(controller.stageName, 'ACTIVE INCUBATION');
    expect(controller.eggTurningStatus, 'ACTIVE (EVERY 4 HOURS)');

    // Active Humidity range for Quail: 45.0 - 55.0 %
    expect(controller.humidityLowLimit, 45.0);
    expect(controller.humidityHighLimit, 55.0);

    // Active turning & humidifier test for Quail
    controller.updateSensors(incTemp: 37.5, incHumidity: 43.0);
    expect(controller.incubatorHumidifierState, true); // < 45.0% -> ON

    controller.updateSensors(incTemp: 37.5, incHumidity: 56.0);
    expect(controller.incubatorHumidifierState, false); // >= 55.0% -> OFF

    // Advance to Lockdown Day (Day 15 = (15 - 7) * 86400 = 8 * 86400 seconds)
    controller.elapsedSeconds = 8 * 86400;
    expect(controller.currentIncubationDay, 15);
    expect(controller.isLockdown, true);
    expect(controller.stageName, 'LOCKDOWN / HATCHING');
    expect(controller.eggTurningStatus, 'STOPPED (LOCKDOWN)');

    // Lockdown Humidity range for Quail: 65.0 - 70.0 %
    expect(controller.humidityLowLimit, 65.0);
    expect(controller.humidityHighLimit, 70.0);

    // Advance to Complete (Day 18 = (18 - 7) * 86400 = 11 * 86400 seconds)
    controller.elapsedSeconds = 11 * 86400;
    expect(controller.currentIncubationDay, 18);
    expect(controller.isBatchComplete, true);
    expect(controller.stageName, 'BATCH COMPLETE');

    controller.dispose();
  });
}
