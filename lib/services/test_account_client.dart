import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_backend_configuration.dart';

/// Standalone, memory-only Auth client; never initializes Supabase.instance.
///
/// Does not load existing .env or production sessions. Constructing it performs
/// no login, account creation, record lookup or hardware operation. Explicit
/// account actions on the separate test screen can make test-project requests.
GoTrueClient createTestAccountClient(TestBackendConfiguration configuration) {
  return GoTrueClient(
    url: '${configuration.url}/auth/v1',
    headers: {'apikey': configuration.clientKey},
    autoRefreshToken: false,
    asyncStorage: _MemoryPkceStorage(),
  );
}

/// PKCE state for this process only. This is not approved durable evidence/key
/// storage, protected offline access, callback recovery or a production vault.
class _MemoryPkceStorage implements GotrueAsyncStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }
}
