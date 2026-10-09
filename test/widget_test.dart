import 'package:flutter_test/flutter_test.dart';
import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/controllers/incubator_controller.dart';

void main() {
  testWidgets('App starts and shows landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartHatchApp());

    expect(find.text('Smarter Hatching,\nBetter Results.'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  test('IncubatorController hysteresis and stage test', () {
    final controller = IncubatorController(profile: IncubationProfile.chicken);

    // Initial Chicken incubation checks
    expect(controller.currentIncubationDay, 1);
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

    controller.dispose();
  });

  test('IncubatorController Duck egg stages and thresholds test', () {
    final controller = IncubatorController(profile: IncubationProfile.duck);

    // Initial Duck batch checks
    expect(controller.profile.speciesName, 'Duck');
    expect(controller.profile.hatchDay, 28);
    expect(controller.profile.lockdownStartDay, 26);
    expect(controller.currentIncubationDay, 1);
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

    // Advance to Lockdown Day (Day 26 = 25 * 86400 seconds elapsed)
    controller.elapsedSeconds = 25 * 86400 + 10;
    expect(controller.currentIncubationDay, 26);
    expect(controller.isLockdown, true);
    expect(controller.stageName, 'LOCKDOWN / HATCHING');
    expect(controller.eggTurningStatus, 'STOPPED (LOCKDOWN)');

    // Lockdown Humidity range for Duck: 70.0 - 75.0 %
    expect(controller.humidityLowLimit, 70.0);
    expect(controller.humidityHighLimit, 75.0);

    controller.dispose();
  });

  test('IncubatorController Quail egg stages and thresholds test', () {
    final controller = IncubatorController(profile: IncubationProfile.quail);

    // Initial Quail batch checks matching SmartHatch_Quail_Automatic_Stages.ino
    expect(controller.profile.speciesName, 'Quail');
    expect(controller.profile.hatchDay, 18);
    expect(controller.profile.lockdownStartDay, 15);
    expect(controller.profile.eepromMagic, 0xA318);
    expect(controller.currentIncubationDay, 1);
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

    // Advance to Lockdown Day (Day 15 = 14 * 86400 seconds elapsed)
    controller.elapsedSeconds = 14 * 86400 + 10;
    expect(controller.currentIncubationDay, 15);
    expect(controller.isLockdown, true);
    expect(controller.stageName, 'LOCKDOWN / HATCHING');
    expect(controller.eggTurningStatus, 'STOPPED (LOCKDOWN)');

    // Lockdown Humidity range for Quail: 65.0 - 70.0 %
    expect(controller.humidityLowLimit, 65.0);
    expect(controller.humidityHighLimit, 70.0);

    // Advance to Complete (Day 18 complete = 18 * 86400 seconds elapsed)
    controller.elapsedSeconds = 18 * 86400;
    expect(controller.isBatchComplete, true);
    expect(controller.stageName, 'BATCH COMPLETE');

    controller.dispose();
  });
}
