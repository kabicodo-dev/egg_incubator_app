import 'package:flutter/material.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/controllers/incubator_controller.dart';
import 'package:egg_incubator_app/controllers/arduino_controller.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/widgets/incubator_readings.dart';
import 'package:egg_incubator_app/widgets/app_derived_schedule.dart';
import 'package:egg_incubator_app/models/species_data.dart';
import 'package:egg_incubator_app/navigation/incubation_routes.dart';
import 'package:egg_incubator_app/utils/actual_readings.dart';
import 'package:egg_incubator_app/widgets/hardware/arduino_connection_card.dart';
import 'package:egg_incubator_app/widgets/hardware/live_incubator_status_card.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';

// ------------------------------------------------------------
// IncubatorDashboardPage (merged in from origin/main)
// ------------------------------------------------------------
class IncubatorDashboardPage extends StatefulWidget {
  const IncubatorDashboardPage({super.key});

  @override
  State<IncubatorDashboardPage> createState() => _IncubatorDashboardPageState();
}

class _IncubatorDashboardPageState extends State<IncubatorDashboardPage> {
  late final IncubatorController _controller;
  final ArduinoController _arduino = ArduinoController.instance;

  // Local simulated slider values to test the controller logic
  double _simulatedIncTemp = 37.2;
  double _simulatedIncHumidity = 48.0;
  final double _simulatedBroodTemp = 31.0;
  final double _simulatedBroodHumidity = 50.0;

  /// The REAL batch incubating right now, loaded from Supabase. The
  /// simulator on this screen is local-only and never touches it.
  Map<String, dynamic>? _realBatch;
  bool _realBatchLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = IncubatorController(profile: IncubationProfile.chicken);
    _arduino.addListener(_syncFromArduino);
    _loadRealBatch();

    // Initial sensor update to trigger hysteresis rules
    _controller.updateSensors(
      incTemp: _simulatedIncTemp,
      incHumidity: _simulatedIncHumidity,
      broodTemp: _simulatedBroodTemp,
      broodHumidity: _simulatedBroodHumidity,
      source: SensorDataSource.simulated,
    );
  }

  /// Loads the single active batch so the console identifies it clearly and
  /// separates it from the simulation. Offline: nothing renders, the
  /// SIMULATION labels still describe the simulator accurately.
  Future<void> _loadRealBatch() async {
    try {
      final row = await SupabaseService().getActiveSession();
      if (mounted) {
        setState(() {
          _realBatch = row;
          _realBatchLoaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _realBatchLoaded = true);
    }
  }

  /// The simulator's stage, labeled so it can never read as a real batch:
  /// the active-humidity phase says "ACTIVE PHASE", not "ACTIVE INCUBATION".
  String get _simStageLabel {
    final stage = _controller.stageName;
    return stage == 'ACTIVE INCUBATION'
        ? 'SIMULATED PHASE'
        : 'SIMULATED $stage';
  }

  /// Mirrors live Arduino telemetry into the controller. While an Arduino is
  /// connected the hardware owns the relays (manual commands win); otherwise
  /// the local simulator keeps driving the controller exactly as before.
  void _syncFromArduino() {
    final connected = _arduino.isConnected;
    _controller.externalControl = connected;
    if (connected && _arduino.isLive) {
      // Live telemetry: mirror real readings and reported relay states.
      final reading = _arduino.telemetry!;
      _controller.updateSensors(
        incTemp: _arduino.incubatorTemperature,
        incHumidity: _arduino.incubatorHumidity,
        broodTemp: _arduino.brooderTemperature,
        broodHumidity: _arduino.brooderHumidity,
        source: SensorDataSource.physical,
        receivedAt: reading.receivedAt,
      );
      _controller.applyActuatorStates({
        'incubatorBulb': _arduino.actuatorOn('incubatorBulb'),
        'incubatorHumidifier': _arduino.actuatorOn('incubatorHumidifier'),
        'incubatorFan': _arduino.actuatorOn('incubatorFan'),
        'exhaustFan': _arduino.actuatorOn('exhaustFan'),
        'brooderBulb': _arduino.actuatorOn('brooderBulb'),
        'brooderHumidifier': _arduino.actuatorOn('brooderHumidifier'),
      });
    } else if (connected) {
      // Connected but no fresh frame yet: never show simulated readings as
      // live, and do not keep stale physical values labeled as live.
      _controller.updateSensors(source: SensorDataSource.none);
    } else if (!connected) {
      // Simulator owns the readings while no Arduino is attached.
      _controller.updateSensors(
        incTemp: _simulatedIncTemp,
        incHumidity: _simulatedIncHumidity,
        broodTemp: _simulatedBroodTemp,
        broodHumidity: _simulatedBroodHumidity,
        source: SensorDataSource.simulated,
      );
    }
    if (mounted) setState(() {});
  }

  void _onSensorChanged() {
    if (_arduino.isConnected) {
      _syncFromArduino();
      return;
    }
    _controller.updateSensors(
      incTemp: _simulatedIncTemp,
      incHumidity: _simulatedIncHumidity,
      broodTemp: _simulatedBroodTemp,
      broodHumidity: _simulatedBroodHumidity,
      source: SensorDataSource.simulated,
    );
  }

  Future<void> _toggleActuator(String actuator) async {
    if (!_arduino.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect the Arduino first.')),
      );
      return;
    }
    final ok = await _arduino.setActuator(
      actuator,
      !_arduino.actuatorOn(actuator),
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_arduino.lastError ?? 'Command failed.')),
      );
    }
  }

  @override
  void dispose() {
    _arduino.removeListener(_syncFromArduino);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _arduino]),
      builder: (context, _) {
        final profile = _controller.profile;
        final isLockdown = _controller.isLockdown;

        final hours = _controller.elapsedSeconds ~/ 3600;
        final minutes = (_controller.elapsedSeconds % 3600) ~/ 60;
        final seconds = _controller.elapsedSeconds % 60;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: const Text(
              'Hardware Console',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              if (MediaQuery.sizeOf(context).width >= 400 &&
                  MediaQuery.textScalerOf(context).scale(12) <= 18)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8752A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8752A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.egg_rounded,
                        size: 15,
                        color: Color(0xFFE8752A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sim: ${_controller.eggCount} eggs',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDarkPressed,
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text(
                  _controller.profile.speciesName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _showSpeciesSelectDialog,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Simulator: reset or change profile',
                onPressed: _showSpeciesSelectDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. ARDUINO CONNECTION
                ArduinoConnectionCard(controller: _arduino),
                const SizedBox(height: 12),

                // 0b. THE ONE REAL BATCH (P6.4) - always identified first so
                // the simulator below can never be mistaken for it.
                _buildRealBatchBand(),
                _buildNoRealBatchNote(),

                // SIMULATOR PROFILE - LOCAL PREVIEW ONLY (P6.4): switching
                // changes the simulation, never the real batch or hardware.
                _buildSimulatorProfileLabel(),
                const SizedBox(height: 6),
                _buildSpeciesQuickSelector(),
                const SizedBox(height: 12),

                // Local simulation only; never an app or physical day counter.
                _buildBatchHeaderCard(
                  profile,
                  isLockdown,
                  hours,
                  minutes,
                  seconds,
                ),
                const SizedBox(height: 16),

                // 2. FERTILE EGG TRAY & CAPACITY CARD (6-12 Eggs, No 0 eggs)
                _buildEggCapacityCard(),
                const SizedBox(height: 16),

                // 3. INCUBATOR CHAMBER
                _buildIncubatorChamberCard(),
                const SizedBox(height: 16),

                // 4. TEST SENSOR SLIDERS (Hardware Simulator) / live notice
                if (_arduino.isConnected)
                  _buildLiveNoticeCard()
                else
                  _buildSimulatorCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The single real incubation, named at the top of the console so the
  /// simulation below can never be mistaken for it. Tapping the band opens
  /// the Active Incubation screen for that batch.
  Widget _buildRealBatchBand() {
    if (!_realBatchLoaded) return const SizedBox.shrink();
    final row = _realBatch;
    if (row == null) return const SizedBox.shrink();
    final species = speciesDataForName((row['egg_type'] as String?) ?? '');
    final id = row['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.25),
        ),
      ),
      child: Semantics(
        button: true,
        label: 'Open current incubation, Batch #$id',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => activeIncubationScreenFor(row),
                ),
              ).then((_) => _loadRealBatch());
            },
            child: Row(
              children: [
                SpeciesIllustration(species: species.name, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAVED APP BATCH \u00B7 Batch #$id \u00B7 '
                        '${species.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AppSchedule(storedStart: row['start_date']),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primaryDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shown when no batch is incubating: everything below is a simulation.
  Widget _buildNoRealBatchNote() {
    if (!_realBatchLoaded || _realBatch != null) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.science_outlined, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No app batch data available. Physical state is unknown. '
              'The preview below is a SIMULATION.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  /// Titles the profile switcher and states plainly that it is a preview -
  /// it never touches the real batch or the hardware.
  Widget _buildSimulatorProfileLabel() {
    return Row(
      children: [
        const Icon(Icons.tune_rounded, size: 16, color: Color(0xFFE8752A)),
        const SizedBox(width: 6),
        const Text(
          'SIMULATOR PROFILE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Color(0xFF6B6B6B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'preview only - does not change the real batch',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesQuickSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: IncubationProfile.allProfiles.map((p) {
          final isSelected = _controller.profile.speciesName == p.speciesName;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isSelected) {
                  _controller.startNewBatch(
                    p,
                    _controller.eggCount,
                    _controller.startDay,
                  );
                  _onSensorChanged();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE8752A)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFFE8752A,
                            ).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      p.speciesName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unapproved preview',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBatchHeaderCard(
    IncubationProfile profile,
    bool isLockdown,
    int hours,
    int minutes,
    int seconds,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLockdown
              ? [const Color(0xFFD9534F), const Color(0xFFC9302C)]
              : [const Color(0xFFE8752A), const Color(0xFFF39C12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isLockdown ? Colors.red : Colors.deepOrange).withValues(
              alpha: 0.25,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SIMULATION chips (P6.4): this whole card is the local simulator,
          // so every label here is explicitly simulated - never a real batch.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SIMULATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Profile: ${profile.speciesName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Simulated quantity: ${_controller.eggCount} eggs',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _simStageLabel,
                  style: TextStyle(
                    color: isLockdown
                        ? const Color(0xFFC9302C)
                        : AppColors.primaryDarkPressed,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Preview only — not physical',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Simulator settings are unapproved; no physical Start is confirmed.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schedule unavailable in simulator',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Simulation elapsed: ${hours}h ${minutes}m ${seconds}s',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isLockdown
                      ? 'Simulated lockdown phase'
                      : 'Simulated pre-lockdown phase',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dedicated 6-12 Fertile Egg Tray and Batch Capacity Card
  Widget _buildEggCapacityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.egg_rounded, color: Color(0xFFE8752A), size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fertile Egg Tray & Capacity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Testing Batch: 6–12 eggs (0 eggs prohibited)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Simulated eggs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stepper and Quick Selector Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Egg Count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Must be 6–12 fertile eggs',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Stepper [-]
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: _controller.eggCount > IncubatorController.minEggCount
                      ? const Color(0xFFE8752A)
                      : Colors.grey.shade400,
                  tooltip:
                      _controller.eggCount > IncubatorController.minEggCount
                      ? 'Decrease Egg Count'
                      : 'Minimum batch is 6 eggs. System prohibits 0 eggs.',
                  onPressed:
                      _controller.eggCount > IncubatorController.minEggCount
                      ? () => _controller.setEggCount(_controller.eggCount - 1)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'The system shall not allow 0 eggs. Minimum batch is 6 eggs.',
                              ),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.deepOrange,
                            ),
                          );
                        },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8752A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE8752A)),
                  ),
                  child: Text(
                    '${_controller.eggCount}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDarkPressed,
                    ),
                  ),
                ),
                // Stepper [+]
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: _controller.eggCount < IncubatorController.maxEggCount
                      ? const Color(0xFFE8752A)
                      : Colors.grey.shade400,
                  tooltip:
                      _controller.eggCount < IncubatorController.maxEggCount
                      ? 'Increase Egg Count'
                      : 'Maximum tray capacity is 12 eggs.',
                  onPressed:
                      _controller.eggCount < IncubatorController.maxEggCount
                      ? () => _controller.setEggCount(_controller.eggCount + 1)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick selection chips 6 to 12
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Quick Select:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                for (
                  int count = IncubatorController.minEggCount;
                  count <= IncubatorController.maxEggCount;
                  count++
                )
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('$count Eggs'),
                      selected: _controller.eggCount == count,
                      selectedColor: AppColors.primaryDark,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _controller.eggCount == count
                            ? Colors.white
                            : Colors.black87,
                      ),
                      onSelected: (_) => _controller.setEggCount(count),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Visual Egg Tray Grid (12 slots)
          const Text(
            'Physical Tray Slot Distribution (12-Egg Capacity):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width < 400 ? 3 : 6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              mainAxisExtent: 48 + MediaQuery.textScalerOf(context).scale(28),
            ),
            itemCount: IncubatorController.maxEggCount,
            itemBuilder: (context, index) {
              final slotNumber = index + 1;
              final isFilled = slotNumber <= _controller.eggCount;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isFilled
                      ? const Color(0xFFFFF3E0)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFilled
                        ? const Color(0xFFE8752A)
                        : Colors.grey.shade300,
                    width: isFilled ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFilled ? Icons.egg_rounded : Icons.egg_outlined,
                      size: 20,
                      color: isFilled
                          ? const Color(0xFFE8752A)
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$slotNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isFilled
                            ? AppColors.primaryDarkPressed
                            : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      isFilled ? 'Fertile' : 'Empty',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isFilled
                            ? Colors.green.shade700
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.amber.shade900,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Simulation quantity only. This preview does not verify egg fertility or physical egg loading.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncubatorChamberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFFE8752A),
                size: 22,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Incubator Chamber',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _sourceChip(_controller.sensorSource),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Physical 16x2 I2C LCD Screen Display (Temperature, Humidity, Days of eggs)
          _buildIncubatorLcdScreen(),
          const SizedBox(height: 14),

          IncubatorReadings(
            reading: actualReadings(_arduino),
            targetTemperature: '${_controller.profile.temperatureTarget} °C',
            targetHumidity:
                '${_controller.humidityLowLimit.toInt()}-${_controller.humidityHighLimit.toInt()} %',
          ),
          const SizedBox(height: 12),
          // Preserve the separate simulator preview; never put it in Actual.
          if (_controller.sensorsAreSimulated)
            const Text('SIMULATION preview — not physical readings'),
          if (_controller.sensorsAreSimulated)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Simulated Temp',
                    value: _controller.incubatorTemperature != null
                        ? '${_controller.incubatorTemperature!.toStringAsFixed(1)} °C'
                        : 'ERROR',
                    target:
                        'Unapproved simulator target: ${_controller.profile.temperatureTarget} °C',
                    isTargetMet:
                        _controller.incubatorTemperature != null &&
                        (_controller.incubatorTemperature! -
                                    _controller.profile.temperatureTarget)
                                .abs() <=
                            0.5,
                    icon: Icons.thermostat_rounded,
                    iconColor: Colors.deepOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Simulated Humidity',
                    value: _controller.incubatorHumidity != null
                        ? '${_controller.incubatorHumidity!.toStringAsFixed(1)} %'
                        : 'ERROR',
                    target:
                        'Unapproved simulator target: ${_controller.humidityLowLimit.toInt()}-${_controller.humidityHighLimit.toInt()} %',
                    isTargetMet:
                        _controller.incubatorHumidity != null &&
                        _controller.incubatorHumidity! >=
                            _controller.humidityLowLimit &&
                        _controller.incubatorHumidity! <=
                            _controller.humidityHighLimit,
                    icon: Icons.water_drop_rounded,
                    iconColor: Colors.blue,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Relay States
          const Text(
            'Simulator outputs / unverified reported states',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRelayChip(
                name: 'Heat Bulb (D10)',
                isOn: _controller.incubatorBulbState,
                activeColor: Colors.orange,
                icon: Icons.lightbulb_outline,
                status: _arduino.commandStatus('incubatorBulb'),
                onTap: () => _toggleActuator('incubatorBulb'),
              ),
              _buildRelayChip(
                name: 'Humidifier (D6)',
                isOn: _controller.incubatorHumidifierState,
                activeColor: Colors.blue,
                icon: Icons.cloud_outlined,
                status: _arduino.commandStatus('incubatorHumidifier'),
                onTap: () => _toggleActuator('incubatorHumidifier'),
              ),
              _buildRelayChip(
                name: 'Circulation Fan (D12)',
                isOn: _controller.incubatorFanState,
                activeColor: Colors.teal,
                icon: Icons.wind_power,
                status: _arduino.commandStatus('incubatorFan'),
                onTap: () => _toggleActuator('incubatorFan'),
              ),
              _buildRelayChip(
                name: 'Exhaust Fan (D9)',
                isOn: _controller.exhaustFanState,
                activeColor: Colors.brown,
                icon: Icons.mode_fan_off,
                status: _arduino.commandStatus('exhaustFan'),
                onTap: () => _toggleActuator('exhaustFan'),
              ),
              _buildRelayChip(
                name:
                    'Egg Turner: '
                    '${_arduino.isConnected ? (_arduino.turningActive ? 'AUTO' : 'OFF') : _controller.eggTurningStatus}',
                isOn: _arduino.isConnected
                    ? _arduino.turningActive
                    : !_controller.isLockdown,
                activeColor: Colors.purple,
                icon: Icons.autorenew_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          EggTurningStatus(controller: _arduino),
        ],
      ),
    );
  }

  Widget _buildIncubatorLcdScreen() {
    final isSimulation =
        !_arduino.isConnected && _controller.sensorsAreSimulated;
    final actual = actualReadings(_arduino);
    final temp = _arduino.isConnected
        ? (actual.canShowReportedValues ? actual.temperature : null)
        : (_controller.sensorsAreSimulated
              ? _controller.incubatorTemperature
              : null);
    final humidity = _arduino.isConnected
        ? (actual.canShowReportedValues ? actual.humidity : null)
        : (_controller.sensorsAreSimulated
              ? _controller.incubatorHumidity
              : null);
    final tempStr = temp != null && temp.isFinite
        ? '${temp.toStringAsFixed(1)}°C'
        : '—';
    final humStr = humidity != null && humidity.isFinite
        ? '${humidity.toStringAsFixed(0)}%'
        : '—';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2630),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The diagnostic address/title must wrap instead of clipping at 2x.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                isSimulation
                    ? 'SIMULATOR LCD PREVIEW'
                    : 'UNVERIFIED LCD PREVIEW',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: const Text(
                  'I2C: 0x27 (A4/A5)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Inner Glass LCD Screen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF003865),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF002244), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap the preview at narrow widths and large text sizes.
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'T: $tempStr',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFFE0F7FA),
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 6),
                        ],
                      ),
                    ),
                    Text(
                      'H: $humStr',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Color(0xFFE0F7FA),
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 6),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Unknown schedule/preview label, never a physical day count.
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'DAY: —',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFFB2EBF2),
                        shadows: [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 4),
                        ],
                      ),
                    ),
                    Text(
                      isSimulation ? '[PREVIEW]' : '[UNKNOWN]',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: _controller.isLockdown
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF80DEEA),
                        shadows: const [
                          Shadow(color: Color(0xFF00E5FF), blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isSimulation)
            const Text(
              'Waiting for confirmed start',
              style: TextStyle(color: Colors.white),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.tv_rounded, size: 12, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'App preview — not a verified physical LCD',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.grey.shade700, size: 20),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'Hardware Telemetry Simulator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Move the sliders to simulate live DHT readings and observe how the controller automatically triggers the bulb and humidifier relays based on hysteresis and safety cutoff rules.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // Incubator Temp Slider
          Text('Incubator Temp: ${_simulatedIncTemp.toStringAsFixed(1)} °C'),
          Slider(
            value: _simulatedIncTemp,
            min: 35.0,
            max: 40.0,
            divisions: 50,
            activeColor: const Color(0xFFE8752A),
            onChanged: (val) {
              setState(() => _simulatedIncTemp = val);
              _onSensorChanged();
            },
          ),

          // Incubator Humidity Slider
          Text(
            'Incubator Humidity: ${_simulatedIncHumidity.toStringAsFixed(1)} %',
          ),
          Slider(
            value: _simulatedIncHumidity,
            min: 30.0,
            max: 85.0,
            divisions: 55,
            activeColor: Colors.blue,
            onChanged: (val) {
              setState(() => _simulatedIncHumidity = val);
              _onSensorChanged();
            },
          ),
        ],
      ),
    );
  }

  /// Chip labeling whether the chamber readings are live physical data,
  /// simulator preview data, or unavailable.
  Widget _sourceChip(SensorDataSource source) {
    final (String text, Color color, Color bg) = switch (source) {
      SensorDataSource.physical => (
        'UNVERIFIED',
        Colors.grey.shade700,
        Colors.grey.withValues(alpha: 0.10),
      ),
      SensorDataSource.simulated => (
        'SIMULATED',
        Colors.orange.shade700,
        Colors.orange.withValues(alpha: 0.10),
      ),
      SensorDataSource.none => (
        '—',
        Colors.grey.shade500,
        Colors.grey.withValues(alpha: 0.08),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String target,
    required bool isTargetMet,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isTargetMet ? Icons.check_circle : Icons.warning_amber_rounded,
                size: 13,
                color: isTargetMet ? Colors.green : Colors.amber.shade800,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  target,
                  style: TextStyle(
                    fontSize: 11,
                    color: isTargetMet
                        ? Colors.green.shade700
                        : Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelayChip({
    required String name,
    required bool isOn,
    required Color activeColor,
    required IconData icon,
    ActuatorCommandStatus status = ActuatorCommandStatus.idle,
    VoidCallback? onTap,
  }) {
    final pending = status == ActuatorCommandStatus.pending;
    final failed =
        status == ActuatorCommandStatus.failed ||
        status == ActuatorCommandStatus.rejected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isOn
              ? activeColor.withValues(alpha: 0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: failed
                ? const Color(0xFFD32F2F)
                : (isOn
                      ? activeColor.withValues(alpha: 0.3)
                      : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isOn ? activeColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isOn ? activeColor : Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: failed
                    ? const Color(0xFFD32F2F)
                    : (pending
                          ? Colors.amber.shade700
                          : (isOn ? activeColor : Colors.grey.shade400)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                failed ? 'ERR' : (pending ? '…' : (isOn ? 'ON' : 'OFF')),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.usb, color: Color(0xFF4CAF50)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App transport diagnostics — unverified source',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _arduino.isLive
                      ? 'Port open: ${_arduino.portName ?? "serial port"}. Data received, but measurement freshness and physical activity are unverified. Simulator paused.'
                      : 'Connected. Waiting for the first telemetry frame…',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeciesSelectDialog() {
    IncubationProfile selectedProfile = _controller.profile;
    int selectedEggs = _controller.eggCount;
    String? validationMsg;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isEggCountValid =
              selectedEggs >= IncubatorController.minEggCount &&
              selectedEggs <= IncubatorController.maxEggCount;

          return AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFFE8752A),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Simulator Profile',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview a species\' programmed incubation profile '
                    '(temperatures, stages, humidity, and lockdown day), then '
                    'pick the simulated egg count below. This changes the '
                    'simulator only - never the real batch or the hardware:',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  // Section 1: Species Selection
                  const Text(
                    '1. Select Species Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...IncubationProfile.allProfiles.map((p) {
                    final isSelected =
                        selectedProfile.speciesName == p.speciesName;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8752A).withValues(alpha: 0.1)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE8752A)
                              : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Material(
                        // Local material: the decorated Container above would
                        // otherwise hide the ListTile's own background and
                        // ink splash (framework assertion).
                        color: Colors.transparent,
                        child: ListTile(
                          dense: true,
                          title: Text(
                            '${p.speciesName} Eggs',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryDarkPressed
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            'Hatch: Day ${p.hatchDay} | Lockdown: Day ${p.lockdownStartDay}\nActive RH: ${p.activeHumidityLow.toInt()}-${p.activeHumidityHigh.toInt()}%',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFE8752A),
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                          onTap: () {
                            setDialogState(() {
                              selectedProfile = p;
                            });
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Section 2: Fertile Egg Quantity Selection (6 - 12 eggs, strictly no 0)
                  const Text(
                    '2. Fertile Egg Quantity (Batch Capacity: 6–12)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The system strictly prohibits 0 eggs. Please select between 6 and 12 fertile eggs:',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Fertile Eggs:',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color:
                                  selectedEggs > IncubatorController.minEggCount
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade400,
                              onPressed:
                                  selectedEggs > IncubatorController.minEggCount
                                  ? () {
                                      setDialogState(() {
                                        selectedEggs--;
                                        validationMsg = null;
                                      });
                                    }
                                  : () {
                                      setDialogState(() {
                                        validationMsg =
                                            'The system shall not allow 0 eggs. Minimum batch is 6.';
                                      });
                                    },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8752A,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE8752A),
                                ),
                              ),
                              child: Text(
                                '$selectedEggs',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDarkPressed,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color:
                                  selectedEggs < IncubatorController.maxEggCount
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade400,
                              onPressed:
                                  selectedEggs < IncubatorController.maxEggCount
                                  ? () {
                                      setDialogState(() {
                                        selectedEggs++;
                                        validationMsg = null;
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick chips 6 to 12
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (
                        int c = IncubatorController.minEggCount;
                        c <= IncubatorController.maxEggCount;
                        c++
                      )
                        InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedEggs = c;
                              validationMsg = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selectedEggs == c
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selectedEggs == c
                                    ? const Color(0xFFE8752A)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '$c Eggs',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: selectedEggs == c
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (validationMsg != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              validationMsg!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Section 3: Post-candling starting day notice
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Colors.green.shade800,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Simulator settings only',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This changes only the local preview for $selectedEggs simulated eggs. No fertility, physical Start or profile approval is confirmed.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Start Batch ($selectedEggs Eggs)'),
                onPressed: isEggCountValid
                    ? () {
                        _controller.startNewBatch(
                          selectedProfile,
                          selectedEggs,
                          IncubatorController.defaultStartDay,
                        );
                        _onSensorChanged();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Updated ${selectedProfile.speciesName} simulator preview for $selectedEggs eggs; no physical Start.',
                            ),
                            backgroundColor: Colors.green.shade700,
                          ),
                        );
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
