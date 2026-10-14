import 'dart:io';

import 'package:egg_incubator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Configuration tests use FAKE values only. They never read or print the
// real contents of any configuration file - the allowlist guard inspects
// variable NAMES exclusively and never their values.
void main() {
  group('missingSupabaseConfigKeys (fake values only)', () {
    test('complete configuration reports nothing missing', () {
      expect(
        missingSupabaseConfigKeys(
          url: 'https://fake-project.supabase.co',
          anonKey: 'fake-anon-key-for-tests',
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
          anonKey: '',
        ),
        ['SUPABASE_ANON_KEY'],
      );
    });

    test('both empty reports both names', () {
      expect(
        missingSupabaseConfigKeys(url: '', anonKey: ''),
        ['SUPABASE_URL', 'SUPABASE_ANON_KEY'],
      );
    });
  });

  group('MissingSupabaseConfigScreen', () {
    testWidgets('names the missing variables and the fix, never values',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MissingSupabaseConfigScreen(missingKeys: ['SUPABASE_URL']),
        ),
      );

      expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
      expect(find.textContaining('.env.example'), findsOneWidget);
      expect(
        find.textContaining('--dart-define-from-file=.env'),
        findsOneWidget,
      );
      expect(find.textContaining('service_role'), findsOneWidget);
    });

    testWidgets('displays no configuration value content', (tester) async {
      const fakeValue = 'fake-value-that-must-never-appear';
      // The screen receives only variable NAMES, so no value-shaped content
      // can be rendered; assert that explicitly.
      await tester.pumpWidget(
        const MaterialApp(
          home: MissingSupabaseConfigScreen(missingKeys: ['SUPABASE_ANON_KEY']),
        ),
      );

      expect(find.textContaining(fakeValue), findsNothing);
    });
  });

  group('configuration allowlist guard', () {
    test('local .env, when present, uses only allowed variable names', () {
      final envFile = File('.env');
      if (!envFile.existsSync()) {
        // No local .env (fresh clone or CI without config): nothing to
        // guard here. Required-configuration behavior is covered by the
        // fake-value tests above.
        return;
      }

      final names = <String>{};
      for (final line in envFile.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) {
          continue;
        }
        final separator = trimmed.indexOf('=');
        if (separator <= 0) {
          continue;
        }
        names.add(trimmed.substring(0, separator).trim());
      }

      const allowed = {'SUPABASE_URL', 'SUPABASE_ANON_KEY'};
      final unexpected = names.difference(allowed);
      expect(
        unexpected,
        isEmpty,
        reason: 'Unexpected variable NAMES in .env: '
            '${unexpected.join(', ')}. Only public client configuration '
            '(SUPABASE_URL, SUPABASE_ANON_KEY) belongs there; privileged '
            'keys such as service_role must never be added.',
      );
      expect(names, containsAll(allowed));
    });
  });
}
