import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egg_incubator_app/main.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/models/farmer_notice.dart';
import 'package:egg_incubator_app/widgets/common/farmer_notice_card.dart';

/// In-memory stand-in for [SupabaseService] so the profile flow can be tested
/// without touching the network.
class FakeSupabaseService extends SupabaseService {
  String? name;
  int saveCalls = 0;
  bool failNextSave = false;

  @override
  String? getDisplayName() => name;

  @override
  Future<String> updateDisplayName(String value) async {
    saveCalls++;
    if (failNextSave) {
      failNextSave = false;
      throw Exception('network down');
    }
    name = value;
    return value;
  }
}

Future<void> openEditProfile(WidgetTester tester) async {
  await tester.tap(find.text('Edit Profile'));
  await tester.pumpAndSettle();
  expect(find.byType(EditProfileScreen), findsOneWidget);
}

void main() {
  for (final failure in [false, true]) {
    testWidgets('Latest save replaces empty-name warning: failure=$failure', (
      tester,
    ) async {
      final service = FakeSupabaseService()..failNextSave = failure;
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen(service: service)),
      );
      await tester.pumpAndSettle();
      await openEditProfile(tester);
      // Repeated validation must not leave queued warnings either.
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('Save Changes'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Display name cannot be empty.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Sample Farmer');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(find.text('Display name cannot be empty.'), findsNothing);
      expect(
        find.text(
          failure
              ? 'Could not save profile. Please try again.'
              : 'Profile updated!',
        ),
        findsOneWidget,
      );
      expect(service.saveCalls, 1);
      expect(
        find.byType(EditProfileScreen),
        failure ? findsOneWidget : findsNothing,
      );
    });
  }
  testWidgets('Profile screen shows the saved display name', (tester) async {
    final service = FakeSupabaseService()..name = 'Grace Hopper';

    await tester.pumpWidget(MaterialApp(home: ProfileScreen(service: service)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Grace Hopper'), findsOneWidget);
    expect(find.text('SmartHatch User'), findsNothing);
  });

  testWidgets('Profile screen falls back to the default label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(service: FakeSupabaseService())),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('SmartHatch User'), findsOneWidget);
  });

  testWidgets('Saving a name shows it on the profile screen afterwards', (
    tester,
  ) async {
    final service = FakeSupabaseService();

    await tester.pumpWidget(MaterialApp(home: ProfileScreen(service: service)));
    await tester.pumpAndSettle();
    expect(find.text('SmartHatch User'), findsOneWidget);

    await openEditProfile(tester);

    await tester.enterText(find.byType(TextField), 'Ada Lovelace');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // The name was persisted, the success message shown, and the caller
    // returned to the profile screen.
    expect(service.saveCalls, 1);
    expect(service.name, 'Ada Lovelace');
    expect(find.text('Profile updated!'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(
      tester.getTopLeft(find.byType(FarmerNoticeCard)).dy,
      lessThan(tester.getTopLeft(find.text('Ada Lovelace')).dy),
    );
    expect(
      tester
          .widget<FarmerNoticeCard>(find.byType(FarmerNoticeCard))
          .notice
          .tone,
      FarmerNoticeTone.success,
    );
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
    expect(find.text('Ada Lovelace'), findsOneWidget);
  });

  testWidgets('Edit screen opens with the current name already filled in', (
    tester,
  ) async {
    final service = FakeSupabaseService()..name = 'Marie Curie';

    await tester.pumpWidget(MaterialApp(home: ProfileScreen(service: service)));
    await tester.pumpAndSettle();

    await openEditProfile(tester);

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Marie Curie',
    );
  });

  testWidgets('Empty display name is rejected and nothing is saved', (
    tester,
  ) async {
    final service = FakeSupabaseService();

    await tester.pumpWidget(MaterialApp(home: ProfileScreen(service: service)));
    await tester.pumpAndSettle();

    await openEditProfile(tester);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(find.text('Display name cannot be empty.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(
      tester.getTopLeft(find.byType(FarmerNoticeCard)).dy,
      lessThan(tester.getTopLeft(find.byType(TextField)).dy),
    );
    expect(
      tester
          .widget<FarmerNoticeCard>(find.byType(FarmerNoticeCard))
          .notice
          .tone,
      FarmerNoticeTone.warning,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(service.saveCalls, 0);
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Profile updated!'), findsNothing);
  });

  testWidgets('A failed save is reported instead of faking success', (
    tester,
  ) async {
    final service = FakeSupabaseService()..failNextSave = true;

    await tester.pumpWidget(MaterialApp(home: ProfileScreen(service: service)));
    await tester.pumpAndSettle();

    await openEditProfile(tester);

    await tester.enterText(find.byType(TextField), 'Ada Lovelace');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    expect(service.name, isNull);
    expect(find.textContaining('Could not save profile'), findsOneWidget);
    expect(find.textContaining('network down'), findsNothing);
    expect(
      tester
          .widget<FarmerNoticeCard>(find.byType(FarmerNoticeCard))
          .notice
          .tone,
      FarmerNoticeTone.error,
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Profile updated!'), findsNothing);
    // The user stays on the edit screen and can retry.
    expect(find.byType(EditProfileScreen), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}
