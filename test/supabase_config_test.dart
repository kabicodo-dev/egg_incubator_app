import 'dart:io';

import 'package:egg_incubator_app/config/supabase_config.dart';
import 'package:egg_incubator_app/screens/startup/missing_config_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Configuration tests use FAKE values only. They never read, print or compare
// the real contents of any configuration file; the allowlist guard inspects
// variable NAMES exclusively.
void main() {
  group('missingSupabaseConfigKeys', () {
    test('complete hosted configuration reports nothing missing', () {
      expect(
        missingSupabaseConfigKeys(
          url: 'https://fake-project.supabase.co',
          anonKey: 'fake-anon-key-for-tests',
        ),
        isEmpty,
      );
    });

    test('surrounding whitespace is tolerated, not treated as a value', () {
      expect(
        missingSupabaseConfigKeys(
          url: '  https://fake-project.supabase.co  ',
          anonKey: '  fake-anon-key-for-tests  ',
        ),
        isEmpty,
      );
    });

    test('empty url reports only SUPABASE_URL', () {
      expect(
        missingSupabaseConfigKeys(
          url: '',
          anonKey: 'fake-anon-key-for-tests',
        ),
        ['SUPABASE_URL'],
      );
    });

    test('empty anon key reports only SUPABASE_ANON_KEY', () {
      expect(
        missingSupabaseConfigKeys(
          url: 'https://fake-project.supabase.co',
          anonKey: '   ',
        ),
        ['SUPABASE_ANON_KEY'],
      );
    });

    test('both empty reports both names', () {
      expect(missingSupabaseConfigKeys(url: '', anonKey: ''), [
        'SUPABASE_URL',
        'SUPABASE_ANON_KEY',
      ]);
    });

    test('credentials, paths, queries and fragments are not project URLs', () {
      for (final url in [
        'https://user:secret@fake-project.supabase.co',
        'https://fake-project.supabase.co/rest/v1',
        'https://fake-project.supabase.co/?apikey=secret',
        'https://fake-project.supabase.co/#fragment',
        'fake-project.supabase.co',
        'ftp://fake-project.supabase.co',
      ]) {
        expect(
          missingSupabaseConfigKeys(url: url, anonKey: 'fake'),
          ['SUPABASE_URL'],
          reason: 'unexpected acceptance of $url',
        );
      }
    });

    test('plain http is allowed only for a local stack', () {
      expect(isUsableSupabaseUrl('http://127.0.0.1:54321'), isTrue);
      expect(isUsableSupabaseUrl('http://localhost:54321'), isTrue);
      expect(isUsableSupabaseUrl('http://fake-project.supabase.co'), isFalse);
    });
  });

  group('SupabaseConfig', () {
    test('normalizes whitespace without inventing values', () {
      const config = SupabaseConfig(
        url: '  https://fake-project.supabase.co ',
        anonKey: ' fake-anon-key ',
      );
      expect(config.normalizedUrl, 'https://fake-project.supabase.co');
      expect(config.normalizedAnonKey, 'fake-anon-key');
      expect(config.isComplete, isTrue);
    });

    test('a build without definitions is incomplete, not silently defaulted', () {
      const config = SupabaseConfig(url: '', anonKey: '');
      expect(config.isComplete, isFalse);
      expect(
        missingSupabaseConfigKeys(url: config.url, anonKey: config.anonKey),
        ['SUPABASE_URL', 'SUPABASE_ANON_KEY'],
      );
    });
  });

  group('MissingConfigScreen', () {
    testWidgets('names the missing settings and the run command, never values', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissingConfigScreen(missingKeys: ['SUPABASE_URL']),
        ),
      );

      expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
      expect(find.textContaining('.env.example'), findsOneWidget);
      expect(
        find.textContaining('--dart-define-from-file=.env'),
        findsOneWidget,
      );
      expect(find.textContaining('service_role'), findsOneWidget);
      expect(find.textContaining('does not start incubation'), findsNothing);
    });

    testWidgets('renders no configuration value content', (tester) async {
      const fakeValue = 'fake-value-that-must-never-appear';
      await tester.pumpWidget(
        const MaterialApp(
          home: MissingConfigScreen(missingKeys: ['SUPABASE_ANON_KEY']),
        ),
      );

      // The screen only receives names, so no value-shaped content can render.
      expect(find.textContaining(fakeValue), findsNothing);
      expect(find.textContaining('SUPABASE_ANON_KEY'), findsOneWidget);
    });

    testWidgets('fits a 320 px screen at 2x text scale', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: MissingConfigScreen(
            missingKeys: ['SUPABASE_URL', 'SUPABASE_ANON_KEY'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('configuration allowlist guard', () {
    test('local .env, when present, uses only public client variable names', () {
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        // Fresh clone or CI without config: nothing to inspect here. Required
        // configuration behavior is covered by the fake-value tests above.
        return;
      }

      final names = <String>{};
      for (final line in envFile.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final separator = trimmed.indexOf('=');
        if (separator <= 0) continue;
        names.add(trimmed.substring(0, separator).trim());
      }

      const allowed = {'SUPABASE_URL', 'SUPABASE_ANON_KEY'};
      final unexpected = names.difference(allowed);
      expect(
        unexpected,
        isEmpty,
        reason:
            'Unexpected variable NAMES in .env: ${unexpected.join(', ')}. '
            'Only public client configuration belongs there; privileged keys '
            'such as service_role must never be added.',
      );
    });

    test('the example file contains placeholders, not real values', () {
      final example = File('.env.example');
      expect(example.existsSync(), isTrue);
      final text = example.readAsStringSync();
      expect(text, contains('SUPABASE_URL='));
      expect(text, contains('SUPABASE_ANON_KEY='));
      // Guard against pasting a real JWT-shaped key into the example file.
      expect(RegExp(r'eyJ[A-Za-z0-9_-]{10,}').hasMatch(text), isFalse);
    });
  });
}
