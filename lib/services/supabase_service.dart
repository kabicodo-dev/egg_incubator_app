import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Lazy so the service can be constructed even when Supabase has not been
  // initialised yet (e.g. widget tests); only calls that touch the client fail.
  SupabaseClient get _client => Supabase.instance.client;

  // ── Profile ──

  String? _displayNameCache;

  /// Saved display name: in-memory cache first, then the signed-in user's
  /// auth metadata. Returns null when nothing has been saved yet.
  String? getDisplayName() {
    final cached = _displayNameCache;
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();

    try {
      final name = _displayNameFromMetadata(_client.auth.currentUser?.userMetadata);
      if (name != null) _displayNameCache = name;
      return name;
    } catch (_) {
      // Supabase unavailable - caller falls back to its default label.
      return null;
    }
  }

  String? _displayNameFromMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null) return null;
    for (final key in ['display_name', 'name']) {
      final value = metadata[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Persists [name] to the signed-in user's auth metadata and returns the
  /// value that was actually stored. Throws when the update fails so the UI
  /// can report the error instead of claiming a save that never happened.
  Future<String> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Display name cannot be empty');
    }

    final response = await _client.auth
        .updateUser(UserAttributes(data: {'display_name': trimmed}));
    final saved =
        _displayNameFromMetadata(response.user?.userMetadata) ?? trimmed;
    _displayNameCache = saved;
    return saved;
  }

  // ── Species Presets ──

  Future<List<Map<String, dynamic>>> getPresets() async {
    final response = await _client
        .from('incubator_presets')
        .select()
        .order('id');
    return response;
  }

  // ── Active Settings ──

  Future<void> updateActiveSettings({
    required String eggType,
    required double temperature,
    required int humidity,
    required int incubationDays,
  }) async {
    final existing = await _client
        .from('active_settings')
        .select('id')
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('active_settings')
          .update({
            'egg_type': eggType,
            'target_temperature': temperature,
            'target_humidity': humidity,
            'incubation_days': incubationDays,
          })
          .eq('id', existing['id']);
    } else {
      await _client.from('active_settings').insert({
        'egg_type': eggType,
        'target_temperature': temperature,
        'target_humidity': humidity,
        'incubation_days': incubationDays,
      });
    }
  }

  // ── Incubation Sessions ──

  Future<int> createSession({
    required String eggType,
    required DateTime startDate,
    required int eggQuantity,
    double? temperature,
  }) async {
    final response = await _client
        .from('incubator_sessions')
        .insert({
          'egg_type': eggType,
          'start_date': startDate.toIso8601String(),
          'egg_quantity': eggQuantity,
          'temperature': temperature,
          'status': 'Active',
        })
        .select('id')
        .single();
    return response['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final response = await _client
        .from('incubator_sessions')
        .select()
        .order('start_date', ascending: false);
    return response;
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    final response = await _client
        .from('incubator_sessions')
        .select()
        .eq('status', 'Active')
        .order('start_date', ascending: false)
        .maybeSingle();
    return response;
  }

  Future<void> completeSession({
    required int sessionId,
    DateTime? endDate,
    int? eggsHatched,
  }) async {
    await _client
        .from('incubator_sessions')
        .update({
          'status': 'Completed',
          'end_date': (endDate ?? DateTime.now()).toIso8601String(),
          'eggs_hatched': eggsHatched,
        })
        .eq('id', sessionId);
  }

  // ── Stats ──

  Future<int> getTotalSessions() async {
    final response = await _client
        .from('incubator_sessions')
        .select('id')
        .count();
    return response.count;
  }

  Future<int> getCompletedSessions() async {
    final response = await _client
        .from('incubator_sessions')
        .select('id')
        .eq('status', 'Completed')
        .count();
    return response.count;
  }

  Future<String?> getTopSpecies() async {
    final response = await _client
        .from('incubator_sessions')
        .select('egg_type')
        .limit(1000);
    if (response.isEmpty) return null;

    final counts = <String, int>{};
    for (final row in response) {
      final type = row['egg_type'] as String;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    if (counts.isEmpty) return null;
    return (counts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .first
        .key;
  }

  // ── Sensor Readings ──

  Future<Map<String, dynamic>?> getLatestReading() async {
    // limit(1) keeps maybeSingle() valid once the table holds many rows.
    final response = await _client
        .from('sensor_readings')
        .select()
        .order('recorded_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }
}
