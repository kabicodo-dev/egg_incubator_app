import 'package:egg_incubator_app/models/batch_data.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/screens/incubation/active_incubation_screen.dart';

/// The farmer-facing Active Incubation screen for a raw Supabase session
/// row. Its legacy start_date is not confirmed original-Start evidence.
/// Progress stays gated until the approved time adapter is supplied.
ActiveIncubationScreen activeIncubationScreenFor(Map<String, dynamic> row) {
  final species = speciesDataForName((row['egg_type'] as String?) ?? '');
  final startDate = DateTime.tryParse('${row['start_date']}');
  return ActiveIncubationScreen(
    species: species,
    eggCount: (row['egg_quantity'] as int?) ?? 0,
    batchId: 'Batch #${row['id']}',
    sessionId: (row['id'] as int?) ?? 0,
    startDate: startDate,
  );
}

/// The Active Incubation screen for an already-parsed [BatchData] batch
/// (Home's Current Incubation card).
ActiveIncubationScreen activeIncubationScreenForBatch(BatchData batch) {
  final species = speciesDataForName(batch.species);
  final startDate = DateTime.tryParse(batch.startDate);
  return ActiveIncubationScreen(
    species: species,
    eggCount: batch.eggsTotal,
    batchId: batch.batchNumber,
    sessionId: batch.id,
    startDate: startDate,
  );
}
