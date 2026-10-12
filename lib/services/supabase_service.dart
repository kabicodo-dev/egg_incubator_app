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

  /// Minimum supported batch size of the SmartHatch incubator.
  static const int minBatchSize = 6;

  /// Maximum number of eggs the SmartHatch incubator can hold.
  static const int maxCapacity = 12;

  /// Egg quantity rule shared by the setup screen and [createSession].
  ///
  /// Returns a farmer-friendly message when [quantity] cannot be used to
  /// start an incubation, or `null` when it is valid.
  ///
  /// SmartHatch holds 6 to 12 eggs, so every amount below [minBatchSize]
  /// (zero included) or above [maxCapacity] is rejected.
  static String? eggQuantityError(int quantity) {
    if (quantity < minBatchSize) {
      return 'Please choose at least $minBatchSize eggs. '
          'SmartHatch incubates $minBatchSize to $maxCapacity eggs at a time.';
    }
    if (quantity > maxCapacity) {
      return 'Please choose no more than $maxCapacity eggs. '
          'SmartHatch holds $minBatchSize to $maxCapacity eggs at a time.';
    }
    return null;
  }

  Future<int> createSession({
    required String eggType,
    required DateTime startDate,
    required int eggQuantity,
    double? temperature,
  }) async {
    // Never store an unusable quantity (outside 6-12 eggs) in
    // incubator_sessions.egg_quantity.
    final quantityError = eggQuantityError(eggQuantity);
    if (quantityError != null) throw EggQuantityException(quantityError);

    // ── ONE active incubation at a time (P6.1) ──
    // Friendly pre-check before anything is written: while another batch -
    // of ANY species - is still incubating, no new session may be created.
    final existing = await getActiveSession();
    if (existing != null) {
      throw ActiveBatchException(activeBatchMessage(existing));
    }

    int sessionId;
    try {
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
      sessionId = response['id'] as int;
    } on PostgrestException catch (e) {
      // 23505: the database one-active unique index rejected a second
      // 'Active' row - another device or tab won the race after our
      // pre-check passed. Surface it as the same farmer-friendly refusal.
      if (e.code == '23505') {
        throw ActiveBatchException(await _lostRaceMessage());
      }
      rethrow;
    }
    return sessionId;
  }

  /// Farmer-friendly sentence naming the batch that is still incubating.
  static String activeBatchMessage(Map<String, dynamic> session) {
    final id = session['id'];
    final species = session['egg_type'] as String? ?? 'egg';
    return 'Batch #$id ($species) is still incubating. '
        'Finish it before starting a new batch.';
  }

  /// Wording for a lost one-active race where the winning batch could not be
  /// read back (rare): still a clean refusal, never a crash.
  Future<String> _lostRaceMessage() async {
    try {
      final winner = await getActiveSession();
      if (winner != null) return activeBatchMessage(winner);
    } catch (_) {
      // Ignore: the generic sentence below is safe in every case.
    }
    return 'A new batch was just started on another screen. '
        'Open the current incubation before starting another one.';
  }

  Future<List<Map<String, dynamic>>> getSessions() async {
    final response = await _client
        .from('incubator_sessions')
        .select()
        .order('start_date', ascending: false);
    return response;
  }

  /// The batch that is currently incubating, or null when none is.
  ///
  /// With the one-active rule the table holds at most one 'Active' row (the
  /// database unique index enforces it); limit(1) keeps this safe even for
  /// stray duplicates created before the rule existed.
  Future<Map<String, dynamic>?> getActiveSession() async {
    final response = await _client
        .from('incubator_sessions')
        .select()
        .eq('status', 'Active')
        .order('id', ascending: false)
        .limit(1);
    if (response.isEmpty) return null;
    return response.first;
  }

  /// One stored batch by id, or null when it no longer exists.
  ///
  /// The Active Incubation screen uses this to always act on the REAL saved
  /// session (status, quantity, start date) instead of screen parameters.
  Future<Map<String, dynamic>?> getSessionById(int id) async {
    final response = await _client
        .from('incubator_sessions')
        .select()
        .eq('id', id)
        .limit(1);
    if (response.isEmpty) return null;
    return response.first;
  }

  /// Completes the batch with the farmer-entered hatch count. The single
  /// UPDATE is the only write: status, end timestamp and eggs_hatched are
  /// saved together or not at all - nothing is ever fabricated.
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

/// Thrown when an incubation would be saved with an unusable egg quantity.
///
/// [message] is written for farmers, so screens can show it as-is.
class EggQuantityException implements Exception {
  EggQuantityException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a start is refused because another batch is still incubating.
///
/// SmartHatch runs ONE incubation at a time: the farmer finishes the current
/// batch - whatever its species - before starting a new one. [message] is
/// written for farmers and safe to show as-is.
class ActiveBatchException implements Exception {
  ActiveBatchException(this.message);

  final String message;

  @override
  String toString() => message;
}
