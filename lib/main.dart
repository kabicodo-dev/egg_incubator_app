import 'package:flutter/material.dart';
import 'controllers/incubator_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHatch Incubator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8752A),
          primary: const Color(0xFFE8752A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const IncubatorDashboardPage(),
    );
  }
}

class IncubatorDashboardPage extends StatefulWidget {
  const IncubatorDashboardPage({super.key});

  @override
  State<IncubatorDashboardPage> createState() => _IncubatorDashboardPageState();
}

class _IncubatorDashboardPageState extends State<IncubatorDashboardPage> {
  late final IncubatorController _controller;

  // Local simulated slider values to test the controller logic
  double _simulatedIncTemp = 37.2;
  double _simulatedIncHumidity = 48.0;
  double _simulatedBroodTemp = 31.0;
  double _simulatedBroodHumidity = 50.0;

  @override
  void initState() {
    super.initState();
    _controller = IncubatorController(profile: IncubationProfile.chicken);

    // Initial sensor update to trigger hysteresis rules
    _controller.updateSensors(
      incTemp: _simulatedIncTemp,
      incHumidity: _simulatedIncHumidity,
      broodTemp: _simulatedBroodTemp,
      broodHumidity: _simulatedBroodHumidity,
    );
  }

  void _onSensorChanged() {
    _controller.updateSensors(
      incTemp: _simulatedIncTemp,
      incHumidity: _simulatedIncHumidity,
      broodTemp: _simulatedBroodTemp,
      broodHumidity: _simulatedBroodHumidity,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final profile = _controller.profile;
        final currentDay = _controller.currentIncubationDay;
        final isLockdown = _controller.isLockdown;

        final hours = _controller.elapsedSeconds ~/ 3600;
        final minutes = (_controller.elapsedSeconds % 3600) ~/ 60;
        final seconds = _controller.elapsedSeconds % 60;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.egg_rounded, color: Color(0xFFE8752A), size: 28),
                const SizedBox(width: 8),
                const Text(
                  'SmartHatch Controller',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8752A).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.egg_rounded, size: 15, color: Color(0xFFE8752A)),
                    const SizedBox(width: 4),
                    Text(
                      '${_controller.eggCount} Fertile Eggs',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE8752A),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE8752A),
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
                tooltip: 'Start New Batch / Reset',
                onPressed: _showSpeciesSelectDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. SPECIES QUICK SWITCHER (Chicken / Duck / Quail)
                _buildSpeciesQuickSelector(),
                const SizedBox(height: 12),

                // 1. STAGE & BATCH BANNER (Starts after Day 7 candling)
                _buildBatchHeaderCard(currentDay, profile, isLockdown, hours, minutes, seconds),
                const SizedBox(height: 16),

                // 2. FERTILE EGG TRAY & CAPACITY CARD (6-12 Eggs, No 0 eggs)
                _buildEggCapacityCard(),
                const SizedBox(height: 16),

                // 3. INCUBATOR CHAMBER
                _buildIncubatorChamberCard(),
                const SizedBox(height: 16),

                // 4. BROODER CHAMBER
                _buildBrooderChamberCard(),
                const SizedBox(height: 16),

                // 5. TEST SENSOR SLIDERS (Hardware Simulator)
                _buildSimulatorCard(),
              ],
            ),
          ),
        );
      },
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
                  _controller.startNewBatch(p, _controller.eggCount, _controller.startDay);
                  _onSensorChanged();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8752A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFE8752A).withValues(alpha: 0.3),
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
                      '${p.hatchDay} Days (Day 7+)',
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade600,
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
    int currentDay,
    IncubationProfile profile,
    bool isLockdown,
    int hours,
    int minutes,
    int seconds,
  ) {
    final remainingDays = (profile.hatchDay - currentDay).clamp(0, profile.hatchDay);

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
            color: (isLockdown ? Colors.red : Colors.deepOrange).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Species: ${profile.speciesName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Day ${_controller.startDay} Candled • Fertile (${_controller.eggCount} Eggs)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _controller.stageName,
                  style: TextStyle(
                    color: isLockdown ? const Color(0xFFC9302C) : const Color(0xFFE8752A),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Day $currentDay',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${profile.hatchDay} days',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$remainingDays days left',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Hatching started after 7 days in candling (Fertile Verified)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (currentDay / profile.hatchDay).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incubator Elapsed: ${hours}h ${minutes}m ${seconds}s',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
              Text(
                isLockdown
                    ? 'Lockdown Active (Turning Halted)'
                    : 'Lockdown starts on Day ${profile.lockdownStartDay}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    Icon(Icons.verified_rounded, size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Fertile Verified',
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
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
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
                  tooltip: _controller.eggCount > IncubatorController.minEggCount
                      ? 'Decrease Egg Count'
                      : 'Minimum batch is 6 eggs. System prohibits 0 eggs.',
                  onPressed: _controller.eggCount > IncubatorController.minEggCount
                      ? () => _controller.setEggCount(_controller.eggCount - 1)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('The system shall not allow 0 eggs. Minimum batch is 6 eggs.'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.deepOrange,
                            ),
                          );
                        },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      color: Color(0xFFE8752A),
                    ),
                  ),
                ),
                // Stepper [+]
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: _controller.eggCount < IncubatorController.maxEggCount
                      ? const Color(0xFFE8752A)
                      : Colors.grey.shade400,
                  tooltip: _controller.eggCount < IncubatorController.maxEggCount
                      ? 'Increase Egg Count'
                      : 'Maximum tray capacity is 12 eggs.',
                  onPressed: _controller.eggCount < IncubatorController.maxEggCount
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
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                for (int count = IncubatorController.minEggCount;
                    count <= IncubatorController.maxEggCount;
                    count++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('$count Eggs'),
                      selected: _controller.eggCount == count,
                      selectedColor: const Color(0xFFE8752A),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _controller.eggCount == count ? Colors.white : Colors.black87,
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.9,
            ),
            itemCount: IncubatorController.maxEggCount,
            itemBuilder: (context, index) {
              final slotNumber = index + 1;
              final isFilled = slotNumber <= _controller.eggCount;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isFilled ? const Color(0xFFFFF3E0) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFilled ? const Color(0xFFE8752A) : Colors.grey.shade300,
                    width: isFilled ? 1.5 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFilled ? Icons.egg_rounded : Icons.egg_outlined,
                      size: 20,
                      color: isFilled ? const Color(0xFFE8752A) : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$slotNumber',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isFilled ? const Color(0xFFE8752A) : Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      isFilled ? 'Fertile' : 'Empty',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isFilled ? Colors.green.shade700 : Colors.grey.shade400,
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
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pre-Candling Note: Eggs loaded have completed Day 7 candling and are confirmed fertile. 0 eggs is not permitted.',
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
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
          const Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Color(0xFFE8752A), size: 22),
              SizedBox(width: 8),
              Text(
                'Incubator Chamber',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Temperature & Humidity metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Incubator Temp',
                  value: _controller.incubatorTemperature != null
                      ? '${_controller.incubatorTemperature!.toStringAsFixed(1)} °C'
                      : 'ERROR',
                  target: 'Target: ${_controller.profile.temperatureTarget} °C',
                  isTargetMet: _controller.incubatorTemperature != null &&
                      (_controller.incubatorTemperature! - _controller.profile.temperatureTarget).abs() <= 0.5,
                  icon: Icons.thermostat_rounded,
                  iconColor: Colors.deepOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  label: 'Incubator Humidity',
                  value: _controller.incubatorHumidity != null
                      ? '${_controller.incubatorHumidity!.toStringAsFixed(1)} %'
                      : 'ERROR',
                  target: 'Target: ${_controller.humidityLowLimit.toInt()}-${_controller.humidityHighLimit.toInt()} %',
                  isTargetMet: _controller.incubatorHumidity != null &&
                      _controller.incubatorHumidity! >= _controller.humidityLowLimit &&
                      _controller.incubatorHumidity! <= _controller.humidityHighLimit,
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
            'Relay & Actuator Outputs',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
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
              ),
              _buildRelayChip(
                name: 'Humidifier (D6)',
                isOn: _controller.incubatorHumidifierState,
                activeColor: Colors.blue,
                icon: Icons.cloud_outlined,
              ),
              _buildRelayChip(
                name: 'Circulation Fan (D12)',
                isOn: _controller.incubatorFanState,
                activeColor: Colors.teal,
                icon: Icons.wind_power,
              ),
              _buildRelayChip(
                name: 'Egg Turner: ${_controller.eggTurningStatus}',
                isOn: !_controller.isLockdown,
                activeColor: Colors.purple,
                icon: Icons.autorenew_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrooderChamberCard() {
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
          const Row(
            children: [
              Icon(Icons.nest_cam_wired_stand, color: Colors.indigo, size: 22),
              SizedBox(width: 8),
              Text(
                'Brooder Chamber',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Brooder Temp',
                  value: _controller.brooderTemperature != null
                      ? '${_controller.brooderTemperature!.toStringAsFixed(1)} °C'
                      : 'ERROR',
                  target: 'Target: 30.0 - 32.0 °C',
                  isTargetMet: _controller.brooderTemperature != null &&
                      _controller.brooderTemperature! >= 30.0 &&
                      _controller.brooderTemperature! <= 32.0,
                  icon: Icons.thermostat_outlined,
                  iconColor: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  label: 'Brooder Humidity',
                  value: _controller.brooderHumidity != null
                      ? '${_controller.brooderHumidity!.toStringAsFixed(1)} %'
                      : 'ERROR',
                  target: 'Target: 45 - 60 %',
                  isTargetMet: _controller.brooderHumidity != null &&
                      _controller.brooderHumidity! >= 45.0 &&
                      _controller.brooderHumidity! <= 60.0,
                  icon: Icons.water_drop_outlined,
                  iconColor: Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildRelayChip(
                name: 'Brooder Bulb (D11)',
                isOn: _controller.brooderBulbState,
                activeColor: Colors.indigo,
                icon: Icons.lightbulb_outline,
              ),
              _buildRelayChip(
                name: 'Brooder Humidifier (D5)',
                isOn: _controller.brooderHumidifierState,
                activeColor: Colors.cyan,
                icon: Icons.cloud_outlined,
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
              const Text(
                'Hardware Telemetry Simulator',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Move the sliders to simulate live DHT readings and observe how the controller automatically triggers the bulb and humidifier relays based on hysteresis thresholds.',
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
          Text('Incubator Humidity: ${_simulatedIncHumidity.toStringAsFixed(1)} %'),
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
          const SizedBox(height: 8),

          // Brooder Temp Slider
          Text('Brooder Temp: ${_simulatedBroodTemp.toStringAsFixed(1)} °C'),
          Slider(
            value: _simulatedBroodTemp,
            min: 25.0,
            max: 38.0,
            divisions: 52,
            activeColor: Colors.indigo,
            onChanged: (val) {
              setState(() => _simulatedBroodTemp = val);
              _onSensorChanged();
            },
          ),

          // Brooder Humidity Slider
          Text('Brooder Humidity: ${_simulatedBroodHumidity.toStringAsFixed(1)} %'),
          Slider(
            value: _simulatedBroodHumidity,
            min: 30.0,
            max: 80.0,
            divisions: 50,
            activeColor: Colors.cyan,
            onChanged: (val) {
              setState(() => _simulatedBroodHumidity = val);
              _onSensorChanged();
            },
          ),
        ],
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
                    color: isTargetMet ? Colors.green.shade700 : Colors.amber.shade900,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOn ? activeColor.withValues(alpha: 0.12) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOn ? activeColor.withValues(alpha: 0.3) : Colors.grey.shade300,
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
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOn ? activeColor : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isOn ? activeColor : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isOn ? 'ON' : 'OFF',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
          final isEggCountValid = selectedEggs >= IncubatorController.minEggCount &&
              selectedEggs <= IncubatorController.maxEggCount;

          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.tune_rounded, color: Color(0xFFE8752A), size: 24),
                SizedBox(width: 8),
                Text(
                  'Configure Incubation Batch',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Species Selection
                  const Text(
                    '1. Select Species Profile',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  ...IncubationProfile.allProfiles.map((p) {
                    final isSelected = selectedProfile.speciesName == p.speciesName;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8752A).withValues(alpha: 0.1) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE8752A) : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          '${p.speciesName} Eggs',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFFE8752A) : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Hatch: Day ${p.hatchDay} | Lockdown: Day ${p.lockdownStartDay}\nActive RH: ${p.activeHumidityLow.toInt()}-${p.activeHumidityHigh.toInt()}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFFE8752A), size: 20)
                            : const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
                        onTap: () {
                          setDialogState(() {
                            selectedProfile = p;
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 12),

                  // Section 2: Fertile Egg Quantity Selection (6 - 12 eggs, strictly no 0)
                  const Text(
                    '2. Fertile Egg Quantity (Batch Capacity: 6–12)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'The system strictly prohibits 0 eggs. Please select between 6 and 12 fertile eggs:',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fertile Eggs:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: selectedEggs > IncubatorController.minEggCount
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade400,
                              onPressed: selectedEggs > IncubatorController.minEggCount
                                  ? () {
                                      setDialogState(() {
                                        selectedEggs--;
                                        validationMsg = null;
                                      });
                                    }
                                  : () {
                                      setDialogState(() {
                                        validationMsg = 'The system shall not allow 0 eggs. Minimum batch is 6.';
                                      });
                                    },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8752A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE8752A)),
                              ),
                              child: Text(
                                '$selectedEggs',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8752A),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: selectedEggs < IncubatorController.maxEggCount
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade400,
                              onPressed: selectedEggs < IncubatorController.maxEggCount
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
                      for (int c = IncubatorController.minEggCount;
                          c <= IncubatorController.maxEggCount;
                          c++)
                        InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedEggs = c;
                              validationMsg = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                color: selectedEggs == c ? Colors.white : Colors.black87,
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
                          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              validationMsg!,
                              style: TextStyle(fontSize: 11, color: Colors.red.shade700),
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
                            Icon(Icons.check_circle_rounded, size: 16, color: Colors.green.shade800),
                            const SizedBox(width: 6),
                            Text(
                              'Hatching Starts After Day 7 Candling',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Eggs have completed Day 7 candling to confirm fertility. SmartHatch starts automated incubation from Day 7 with $selectedEggs fertile eggs.',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade900),
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
                  backgroundColor: const Color(0xFFE8752A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('Start Batch ($selectedEggs Eggs)'),
                onPressed: isEggCountValid
                    ? () {
                        _controller.startNewBatch(selectedProfile, selectedEggs, IncubatorController.defaultStartDay);
                        _onSensorChanged();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Started ${selectedProfile.speciesName} batch from Day 7 with $selectedEggs fertile eggs.',
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