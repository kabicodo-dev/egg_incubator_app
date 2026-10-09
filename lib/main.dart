import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';

// ──────────────────────────────────────────────
// App Entry Point
// ──────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    await Supabase.instance.client.auth.signInAnonymously();
  }

  runApp(const SmartHatchApp());
}

// ──────────────────────────────────────────────
// Root Widget
// ──────────────────────────────────────────────

class SmartHatchApp extends StatelessWidget {
  const SmartHatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8752A),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const LandingPage(),
    );
  }
}

// ══════════════════════════════════════════════
// MOCK DATA
// ══════════════════════════════════════════════

enum AlertMode { normal, temperature, humidity, incubator, eggTurning }

class SpeciesData {
  final int? id;
  final String name;
  final String emoji;
  final int incubationDays;
  final String temperature;
  final int targetHumidity;
  final String description;

  const SpeciesData({
    this.id,
    required this.name,
    required this.emoji,
    required this.incubationDays,
    required this.temperature,
    required this.targetHumidity,
    required this.description,
  });

  factory SpeciesData.fromPreset(Map<String, dynamic> preset) {
    final type = preset['egg_type'] as String? ?? '';
    final emojiMap = {
      'Chicken': '\uD83D\uDC14',
      'Duck': '\uD83D\uDC26',
      'Quail': '\uD83E\uDD5A',
    };
    final descMap = {
      'Chicken':
          'Chicken eggs typically require 21 days of incubation. Maintain a steady temperature of 37.5\u00B0C and humidity around 50\u201355%. Turn the eggs regularly for best results.',
      'Duck':
          'Duck eggs need about 28 days to hatch. Keep the temperature at 37.5\u00B0C with higher humidity (60\u201365%) compared to chicken eggs. Increase humidity in the last 3 days.',
      'Quail':
          'Quail eggs hatch in about 17\u201318 days. Maintain 37.5\u00B0C with 55\u201360% humidity. Quail eggs are small and require careful handling during incubation.',
    };
    final temp = preset['target_temperature'];
    final tempStr = temp != null ? '$temp\u00B0C' : '37.5\u00B0C';
    return SpeciesData(
      id: preset['id'] as int?,
      name: type,
      emoji: emojiMap[type] ?? '\uD83E\uDD5A',
      incubationDays: preset['incubation_days'] as int? ?? 21,
      temperature: tempStr,
      targetHumidity: (preset['target_humidity'] as num?)?.round() ?? 55,
      description: descMap[type] ?? 'Incubate eggs carefully.',
    );
  }
}

const List<SpeciesData> defaultSpeciesList = [
  SpeciesData(
    name: 'Chicken',
    emoji: '\uD83D\uDC14',
    incubationDays: 21,
    temperature: '37.5\u00B0C',
    targetHumidity: 55,
    description:
        'Chicken eggs typically require 21 days of incubation. Maintain a steady temperature of 37.5\u00B0C and humidity around 50\u201355%. Turn the eggs regularly for best results.',
  ),
  SpeciesData(
    name: 'Duck',
    emoji: '\uD83D\uDC26',
    incubationDays: 28,
    temperature: '37.5\u00B0C',
    targetHumidity: 65,
    description:
        'Duck eggs need about 28 days to hatch. Keep the temperature at 37.5\u00B0C with higher humidity (60\u201365%) compared to chicken eggs. Increase humidity in the last 3 days.',
  ),
  SpeciesData(
    name: 'Quail',
    emoji: '\uD83E\uDD5A',
    incubationDays: 17,
    temperature: '37.5\u00B0C',
    targetHumidity: 58,
    description:
        'Quail eggs hatch in about 17\u201318 days. Maintain 37.5\u00B0C with 55\u201360% humidity. Quail eggs are small and require careful handling during incubation.',
  ),
];

class BatchData {
  final int id;
  final String batchNumber;
  final String species;
  final String startDate;
  final String endDate;
  final int eggsTotal;
  final int eggsHatched;
  final String temperature;
  final String status;
  final bool isSuccess;

  const BatchData({
    required this.id,
    required this.batchNumber,
    required this.species,
    required this.startDate,
    required this.endDate,
    required this.eggsTotal,
    required this.eggsHatched,
    required this.temperature,
    required this.status,
    required this.isSuccess,
  });

  factory BatchData.fromSession(Map<String, dynamic> session) {
    final id = session['id'] as int;
    final species = session['egg_type'] as String? ?? '';
    final startDate = session['start_date'] as String? ?? '';
    final endDate = session['end_date'] as String? ?? '';
    final eggQty = session['egg_quantity'] as int? ?? 0;
    final hatched = session['eggs_hatched'] as int? ?? 0;
    final temp = session['temperature'];
    final tempStr = temp != null ? '$temp\u00B0C' : '37.5\u00B0C';
    final status = session['status'] as String? ?? 'Active';
    final isCompleted = status == 'Completed';
    final formattedStart = startDate.length >= 10 ? startDate.substring(0, 10) : startDate;
    final formattedEnd = endDate.length >= 10 ? endDate.substring(0, 10) : endDate;
    return BatchData(
      id: id,
      batchNumber: 'Batch #$id',
      species: species,
      startDate: formattedStart,
      endDate: formattedEnd,
      eggsTotal: eggQty,
      eggsHatched: hatched,
      temperature: tempStr,
      status: status,
      isSuccess: isCompleted && hatched > 0,
    );
  }
}

// ══════════════════════════════════════════════
// LANDING PAGE
// ══════════════════════════════════════════════

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.egg_outlined,
      title: 'Smarter Hatching,\nBetter Results.',
      body:
          'SmartHatch helps you monitor and manage your egg incubation with ease.',
    ),
    _OnboardingSlide(
      icon: Icons.monitor_heart_outlined,
      title: 'Track Your\nIncubation',
      body:
          'Keep track of your eggs, incubation progress, temperature, and expected hatch date in one place.',
    ),
    _OnboardingSlide(
      icon: Icons.inventory_2_outlined,
      title: 'Manage Your\nBatches',
      body:
          'Review previous incubation batches and easily check your results anytime.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Skip button — top-right
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _goHome,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),

                // Page view
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                slide.icon,
                                size: 60,
                                color: const Color(0xFFE8752A),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Title
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Body
                            Text(
                              slide.body,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: Column(
                    children: [
                      // Page indicator dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_slides.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE8752A)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),

                      // Main action button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _slides.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _goHome();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8752A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentPage < _slides.length - 1 ? 'Next' : 'Get Started',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign in link removed — no auth required
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });
}

// ══════════════════════════════════════════════
// BOTTOM NAVIGATION HOST
// ══════════════════════════════════════════════

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  /// Switches the shell to its [index] section (0 Home, 1 Species,
  /// 2 History) and pops every route pushed on top of it. This lets a section
  /// that was opened as a route - History from the overview cards, Species
  /// from the "Top Species" card - hand navigation back to the shell, so the
  /// bottom bar of such a screen can jump straight to another section
  /// (issue #14).
  static void openTab(BuildContext context, int index) {
    final shell = _MainNavigationState._shell;
    if (shell == null || !shell.mounted) return;
    final shellRoute = ModalRoute.of(shell.context);
    if (shellRoute == null) return;
    shell._selectTab(index);
    Navigator.popUntil(context, (route) => route == shellRoute);
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  /// The shell that is currently on screen, so pushed routes can reach it.
  static _MainNavigationState? _shell;

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SpeciesScreen(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _shell = this;
  }

  @override
  void dispose() {
    if (identical(_shell, this)) _shell = null;
    super.dispose();
  }

  /// Shows the [index] section (0 Home, 1 Species, 2 History).
  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _TabShell(child: _screens[_currentIndex]),
      bottomNavigationBar: _MainBottomBar(
        selectedIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

/// The SmartHatch bottom navigation bar. The shell provides it for its tabs;
/// History and Species render the same bar when they are opened as routes so
/// Home, Species and History stay one tap away there too (issue #14).
class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({required this.selectedIndex, required this.onSelected});

  /// The currently shown section: 0 Home, 1 Species, 2 History.
  final int selectedIndex;

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8752A).withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Color(0xFFE8752A)),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.egg_outlined),
          selectedIcon: Icon(Icons.egg, color: Color(0xFFE8752A)),
          label: 'Species',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history, color: Color(0xFFE8752A)),
          label: 'History',
        ),
      ],
    );
  }
}

/// Marks the bottom-navigation shell so the screens inside it can tell that
/// they are a tab rather than a screen that was pushed onto the navigator.
/// Tabs are switched with the bottom bar and must not offer a back arrow;
/// the same screen opened from somewhere else must show one so the user can
/// return to where they came from (issue #12).
class _TabShell extends InheritedWidget {
  const _TabShell({required super.child});

  /// True when [context] belongs to a screen rendered inside the shell.
  static bool isTab(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_TabShell>() != null;

  @override
  bool updateShouldNotify(_TabShell oldWidget) => false;
}

// ══════════════════════════════════════════════
// HOME SCREEN — Improved hierarchy
// ══════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BatchData> _batches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final sessions = await SupabaseService().getSessions();
      if (mounted) {
        setState(() {
          _batches = sessions.map((s) => BatchData.fromSession(s)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBatches = _batches.length;
    final completedBatches = _batches.where((b) => b.status == 'Completed').toList();
    final bestRate = completedBatches.isNotEmpty
        ? completedBatches
            .map((b) => b.eggsTotal > 0 ? b.eggsHatched / b.eggsTotal : 0.0)
            .reduce((a, b) => a > b ? a : b)
        : 0.0;
    final topSpecies = _batches.isNotEmpty
        ? (() {
            final counts = <String, int>{};
            for (final b in _batches) {
              counts[b.species] = (counts[b.species] ?? 0) + 1;
            }
            return (counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;
          })()
        : '-';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncubationSetupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Start New Incubation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            const _SectionLabel(text: 'OVERVIEW'),
            const SizedBox(height: 10),
            _OverviewCards(
              totalBatches: '$totalBatches',
              bestSuccess: '${(bestRate * 100).round()}%',
              topSpecies: topSpecies,
              onTotalBatchesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              onBestSuccessTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              onTopSpeciesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SpeciesScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            const _SectionLabel(text: 'LAST BATCH'),
            const SizedBox(height: 10),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_batches.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatchDetailsScreen(batch: _batches.first),
                    ),
                  );
                },
                child: _LastBatchCard(batch: _batches.first),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Center(
                  child: Text(
                    'No batches yet. Start your first incubation!',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SPECIES SCREEN
// ══════════════════════════════════════════════

class SpeciesScreen extends StatefulWidget {
  const SpeciesScreen({super.key});

  @override
  State<SpeciesScreen> createState() => _SpeciesScreenState();
}

class _SpeciesScreenState extends State<SpeciesScreen> {
  List<SpeciesData> _species = defaultSpeciesList;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final presets = await SupabaseService().getPresets();
      if (presets.isNotEmpty && mounted) {
        setState(() {
          _species = presets.map((p) => SpeciesData.fromPreset(p)).toList();
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load species: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Egg Species'),
        // Same as the History tab: no arrow inside the bottom-navigation
        // shell, one when the screen was pushed (e.g. "Top Species" card).
        automaticallyImplyLeading: !_TabShell.isTab(context),
      ),
      // Same as History: a pushed Species screen gets the bottom bar so the
      // main sections remain reachable (issue #14).
      bottomNavigationBar: _TabShell.isTab(context)
          ? null
          : _MainBottomBar(
              selectedIndex: 1,
              onSelected: (index) {
                if (index == 1) return; // already showing Species
                MainNavigation.openTab(context, index);
              },
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose the type of eggs you want to incubate.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ..._species.map(
                  (species) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SpeciesCard(
                      name: species.name,
                      description: species.description,
                      emoji: species.emoji,
                      incubationDays: species.incubationDays,
                      temperature: species.temperature,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpeciesDetailsScreen(species: species),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SPECIES DETAILS SCREEN
// ══════════════════════════════════════════════

class SpeciesDetailsScreen extends StatelessWidget {
  final SpeciesData species;
  const SpeciesDetailsScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(species.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(species.emoji, style: const TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              species.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Incubation Period',
              value: '${species.incubationDays} days',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.thermostat,
              label: 'Temperature',
              value: species.temperature,
            ),
            const SizedBox(height: 20),
            const _SectionLabel(text: 'ABOUT THIS SPECIES'),
            const SizedBox(height: 8),
            Text(
              species.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          IncubationSetupScreen(selectedSpecies: species),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// INCUBATION SETUP — Step 1 & 2 (improved UX)
// ══════════════════════════════════════════════

class IncubationSetupScreen extends StatefulWidget {
  final SpeciesData? selectedSpecies;
  const IncubationSetupScreen({super.key, this.selectedSpecies});

  @override
  State<IncubationSetupScreen> createState() => _IncubationSetupScreenState();
}

class _IncubationSetupScreenState extends State<IncubationSetupScreen> {
  SpeciesData? _selectedSpecies;
  int _eggCount = 20;
  int _currentStep = 1;
  List<SpeciesData> _speciesList = defaultSpeciesList;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.selectedSpecies;
    if (_selectedSpecies != null) _currentStep = 2;
    _loadSpecies();
  }

  Future<void> _loadSpecies() async {
    try {
      final presets = await SupabaseService().getPresets();
      if (presets.isNotEmpty && mounted) {
        setState(() {
          _speciesList = presets.map((p) => SpeciesData.fromPreset(p)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load species: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentStep == 1 ? 'Select Species' : 'Egg Quantity')),
      body: _currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  // ── Step 1: What are you hatching? ──

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1, 3),
          const SizedBox(height: 24),
          const Text(
            'What are you hatching?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap to select a species',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          ..._speciesList.map(
            (species) {
              final isSelected = _selectedSpecies?.name == species.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecies = species;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFDF3EC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE8752A)
                            : Colors.grey.shade100,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFE8752A).withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.04),
                          blurRadius: isSelected ? 12 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE8752A).withValues(alpha: 0.15)
                                : const Color(0xFFE8752A).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              species.emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                species.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFE8752A)
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  _InfoChip(
                                    icon: Icons.calendar_today_rounded,
                                    label: '${species.incubationDays} days',
                                  ),
                                  const SizedBox(width: 8),
                                  _InfoChip(
                                    icon: Icons.thermostat,
                                    label: species.temperature,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                species.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFE8752A),
                                  size: 24,
                                )
                              : const Icon(Icons.chevron_right,
                                  color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedSpecies != null
                  ? () {
                      setState(() {
                        _currentStep = 2;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8752A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _selectedSpecies != null ? 2 : 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Step 2: How many eggs? ──

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2, 3),
          const SizedBox(height: 24),
          const Text(
            'How many eggs?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set the number of ${_selectedSpecies?.name.toLowerCase() ?? 'eggs'} to incubate',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),

          // Selected species summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Text(
                  _selectedSpecies?.emoji ?? '\uD83E\uDD5A',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSpecies?.name ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_selectedSpecies?.incubationDays ?? 0} days \u2022 ${_selectedSpecies?.temperature ?? ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Egg counter with +/- buttons
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onTap: _eggCount > 1
                        ? () => setState(() => _eggCount--)
                        : null,
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      '$_eggCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onTap: _eggCount < 999
                        ? () => setState(() => _eggCount++)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'eggs',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _eggCount > 0
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IncubationChecklistScreen(
                            species: _selectedSpecies!,
                            eggCount: _eggCount,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8752A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: _eggCount > 0 ? 2 : 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFFE8752A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ── Small info chip (calendar / thermostat) ──

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.black45),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Large counter +/- button ──

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: onTap != null
              ? const Color(0xFFE8752A).withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 28,
          color: onTap != null ? const Color(0xFFE8752A) : Colors.grey.shade400,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// INCUBATION CHECKLIST — Step 3 (improved UX)
// ══════════════════════════════════════════════

class IncubationChecklistScreen extends StatefulWidget {
  final SpeciesData species;
  final int eggCount;
  const IncubationChecklistScreen({
    super.key,
    required this.species,
    required this.eggCount,
  });

  @override
  State<IncubationChecklistScreen> createState() =>
      _IncubationChecklistScreenState();
}

class _IncubationChecklistScreenState extends State<IncubationChecklistScreen> {
  final List<String> _checklistItems = [
    'Incubator is clean',
    'Temperature is stable',
    'Water level is checked',
    'Eggs are properly positioned',
  ];
  final List<bool> _checked = [false, false, false, false];

  bool get _allChecked => _checked.every((c) => c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incubation Checklist')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepIndicator(3, 3),
            const SizedBox(height: 24),
            const Text(
              'Before we start',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please check that everything is ready',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),

            // Species + egg count summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Text(widget.species.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.species.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${widget.eggCount} eggs \u2022 ${widget.species.incubationDays} days',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Checklist
            ...List.generate(_checklistItems.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: CheckboxListTile(
                    value: _checked[index],
                    onChanged: (val) {
                      setState(() {
                        _checked[index] = val ?? false;
                      });
                    },
                    title: Text(
                      _checklistItems[index],
                      style: const TextStyle(fontSize: 15),
                    ),
                    activeColor: const Color(0xFFE8752A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              );
            }),
            const Spacer(),

            // Helper text when incomplete
            if (!_allChecked)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Please complete the checklist before starting',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _allChecked
                    ? () async {
                        try {
                          final service = SupabaseService();
                          final now = DateTime.now();
                          final tempNum = double.tryParse(
                            widget.species.temperature.replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ?? 37.5;

                          // 1. Update active_settings with current config
                          await service.updateActiveSettings(
                            eggType: widget.species.name,
                            temperature: tempNum,
                            humidity: 55,
                            incubationDays: widget.species.incubationDays,
                          );

                          // 2. Create the incubation session
                          final sessionId = await service.createSession(
                            eggType: widget.species.name,
                            startDate: now,
                            eggQuantity: widget.eggCount,
                            temperature: tempNum,
                          );
                           if (mounted) {
                            Navigator.pushReplacement(
                              this.context,
                              MaterialPageRoute(
                                builder: (_) => IncubationStartedScreen(
                                  species: widget.species,
                                  eggCount: widget.eggCount,
                                  sessionId: sessionId,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: _allChecked ? 2 : 0,
                ),
                child: const Text(
                  'Start Incubation',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFFE8752A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════
// INCUBATION STARTED CONFIRMATION
// ══════════════════════════════════════════════

String _monthNameShort(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month];
}

class IncubationStartedScreen extends StatelessWidget {
  final SpeciesData species;
  final int eggCount;
  final int sessionId;
  const IncubationStartedScreen({
    super.key,
    required this.species,
    required this.eggCount,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hatchDate = now.add(Duration(days: species.incubationDays));
    final batchNum = 'Batch #$sessionId';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Incubation Started!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your eggs are now incubating',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _DetailRow(label: 'Batch', value: batchNum),
                      const SizedBox(height: 12),
                      _DetailRow(
                          label: 'Species',
                          value: '${species.emoji} ${species.name}'),
                      const SizedBox(height: 12),
                      _DetailRow(label: 'Eggs', value: '$eggCount'),
                      const SizedBox(height: 12),
                      _DetailRow(
                          label: 'Start Date',
                          value:
                              '${_monthNameShort(now.month)} ${now.day}, ${now.year}'),
                      const SizedBox(height: 12),
                      _DetailRow(
                          label: 'Expected Hatch',
                          value:
                              '${_monthNameShort(hatchDate.month)} ${hatchDate.day}, ${hatchDate.year}'),
                      const SizedBox(height: 12),
                      _DetailRow(
                          label: 'Temperature',
                          value: species.temperature),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8752A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Back to Dashboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveIncubationScreen(
                            species: species,
                            eggCount: eggCount,
                            batchId: batchNum,
                            sessionId: sessionId,
                            startDate: now,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View Incubation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE8752A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ACTIVE INCUBATION SCREEN
// ══════════════════════════════════════════════

class ActiveIncubationScreen extends StatefulWidget {
  final SpeciesData species;
  final int eggCount;
  final String batchId;
  final int sessionId;
  final DateTime startDate;
  final int currentDay;
  const ActiveIncubationScreen({
    super.key,
    required this.species,
    required this.eggCount,
    required this.batchId,
    required this.sessionId,
    required this.startDate,
    this.currentDay = 8,
  });

  @override
  State<ActiveIncubationScreen> createState() => _ActiveIncubationScreenState();
}

class _ActiveIncubationScreenState extends State<ActiveIncubationScreen> {
  bool _fanOn = true;
  bool _eggTurningOn = true;
  bool _temperatureAuto = true;
  final AlertMode _alertMode = AlertMode.normal;

  @override
  Widget build(BuildContext context) {
    final species = widget.species;
    final eggCount = widget.eggCount;
    final batchId = widget.batchId;
    final startDate = widget.startDate;
    final currentDay = widget.currentDay;
    final totalDays = species.incubationDays;
    final progress = currentDay / totalDays;
    final hatchDate = startDate.add(Duration(days: totalDays));
    final isComplete = currentDay >= totalDays;

    final statusLabel = isComplete ? 'Completed' : 'On track';
    final statusColor = isComplete
        ? const Color(0xFF4CAF50)
        : const Color(0xFF4CAF50);
    final statusIcon = isComplete ? Icons.check_circle : Icons.play_circle_fill;

    final startDateStr =
        '${_monthName(startDate.month)} ${startDate.day}, ${startDate.year}';
    final hatchDateStr =
        '${_monthName(hatchDate.month)} ${hatchDate.day}, ${hatchDate.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Current Incubation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STATUS BANNER ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          isComplete
                              ? 'Hatching day has arrived!'
                              : 'Everything is going well',
                          style: TextStyle(
                            fontSize: 13,
                            color: statusColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── INCUBATOR STATUS ──
            const _SectionLabel(text: 'INCUBATOR STATUS'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Incubator is working normally',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _StatusIndicatorRow(
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    statusText: _temperatureAuto ? 'Normal' : 'Manual',
                    statusColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    statusText: 'Normal',
                    statusColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.air,
                    label: 'Fan',
                    statusText: _fanOn ? 'On' : 'Off',
                    statusColor:
                        _fanOn ? const Color(0xFF4CAF50) : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.sync,
                    label: 'Egg Turning',
                    statusText: _eggTurningOn ? 'On' : 'Off',
                    statusColor: _eggTurningOn
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade500,
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.wifi,
                    label: 'Connection',
                    statusText: 'Connected',
                    statusColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── SPECIES + BATCH ──
            Row(
              children: [
                Text(species.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        batchId,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── DAY / PROGRESS ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day $currentDay of $totalDays',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE8752A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFFE8752A),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── TEMPERATURE GAUGE ──
            TemperatureGauge(
              currentTemp: double.tryParse(
                    species.temperature.replaceAll(RegExp(r'[^0-9.]'), ''),
                  ) ??
                  37.5,
            ),
            const SizedBox(height: 20),

            // ── HUMIDITY GAUGE ──
            const HumidityGauge(
              currentHumidity: 55.0,
            ),
            const SizedBox(height: 16),

            // ── EGGS ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5A623).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.egg_outlined,
                      color: Color(0xFFF5A623),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Eggs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'In incubation',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$eggCount',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── DATES ──
            const _SectionLabel(text: 'DATES'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Start Date', value: startDateStr),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Expected Hatch', value: hatchDateStr),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── INCUBATION CONTROLS ──
            const _SectionLabel(text: 'INCUBATION CONTROLS'),
            const SizedBox(height: 10),
            _IncubationControlTile(
              icon: Icons.air,
              label: 'Fan',
              subtitle: _fanOn ? 'Circulating air' : 'Off',
              isOn: _fanOn,
              onToggle: () => setState(() => _fanOn = !_fanOn),
            ),
            const SizedBox(height: 10),
            _IncubationControlTile(
              icon: Icons.sync,
              label: 'Egg Turning',
              subtitle: _eggTurningOn ? 'Automatic' : 'Manual',
              isOn: _eggTurningOn,
              onToggle: () => setState(() => _eggTurningOn = !_eggTurningOn),
            ),
            const SizedBox(height: 10),
            _IncubationControlTile(
              icon: Icons.thermostat,
              label: 'Temperature',
              subtitle: _temperatureAuto ? 'Automatic' : 'Manual',
              isOn: _temperatureAuto,
              onToggle: () =>
                  setState(() => _temperatureAuto = !_temperatureAuto),
            ),
            const SizedBox(height: 10),

            // ── ALERTS & REMINDERS ──
            const _SectionLabel(text: 'ALERTS & REMINDERS'),
            const SizedBox(height: 10),
            _buildAlertCard(),
            const SizedBox(height: 10),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigation(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8752A),
                  side: const BorderSide(color: Color(0xFFE8752A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View History',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8752A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard() {
    switch (_alertMode) {
      case AlertMode.normal:
        return _AlertCard(
          icon: Icons.check_circle_outline,
          title: 'Everything looks good',
          message: 'Your incubation is on track. No issues right now.',
          accentColor: const Color(0xFF4CAF50),
        );
      case AlertMode.temperature:
        return _AlertCard(
          icon: Icons.thermostat,
          title: 'Temperature needs attention',
          message:
              'The temperature is outside the recommended range. Check the incubator settings.',
          accentColor: const Color(0xFFFF9800),
        );
      case AlertMode.humidity:
        return _AlertCard(
          icon: Icons.water_drop_outlined,
          title: 'Humidity needs attention',
          message:
              'The humidity is outside the recommended range. Check the water tray.',
          accentColor: const Color(0xFFFF9800),
        );
      case AlertMode.incubator:
        return _AlertCard(
          icon: Icons.warning_amber_rounded,
          title: 'Check the incubator',
          message:
              'Something may need your attention. Open the incubator and inspect.',
          accentColor: const Color(0xFFE8752A),
        );
      case AlertMode.eggTurning:
        return _AlertCard(
          icon: Icons.sync,
          title: 'Time to check egg turning',
          message:
              'Make sure the eggs are being turned as scheduled.',
          accentColor: const Color(0xFF2196F3),
        );
    }
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

// ══════════════════════════════════════════════
// HISTORY SCREEN
// ══════════════════════════════════════════════

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<BatchData> _batches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    try {
      final sessions = await SupabaseService().getSessions();
      if (mounted) {
        setState(() {
          _batches = sessions.map((s) => BatchData.fromSession(s)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load history: $e')),
        );
      }
    }
  }

  List<BatchData> get _filteredBatches {
    if (_searchQuery.isEmpty) return _batches;
    final q = _searchQuery.toLowerCase();
    return _batches.where((b) {
      return b.batchNumber.toLowerCase().contains(q) ||
          b.species.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final batches = _filteredBatches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incubation History'),
        // As a bottom-navigation tab this screen is switched with the bottom
        // bar (nothing to pop); opened from somewhere else - the overview
        // cards on Home or the "View History" button - it needs the arrow so
        // the user can go back to where they came from (issue #12).
        automaticallyImplyLeading: !_TabShell.isTab(context),
      ),
      // Opened as a route the shell's bottom bar is not around, so render it
      // here too: Home, Species and History stay one tap away (issue #14).
      // As a tab the shell already provides it.
      bottomNavigationBar: _TabShell.isTab(context)
          ? null
          : _MainBottomBar(
              selectedIndex: 2,
              onSelected: (index) {
                if (index == 2) return; // already showing History
                MainNavigation.openTab(context, index);
              },
            ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'View and search your previous batches.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search batches...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFFE8752A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (batches.isEmpty) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      _searchQuery.isEmpty
                          ? Icons.egg_outlined
                          : Icons.search_off,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No batches yet'
                          : 'No batches found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _searchQuery.isEmpty
                          ? 'Start your first incubation!'
                          : 'Try a different search.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ] else
              ...batches.map(
                (batch) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HistoryBatchCard(
                    id: batch.id,
                    batchNumber: batch.batchNumber,
                    species: batch.species,
                    startDate: batch.startDate,
                    endDate: batch.endDate,
                    eggsTotal: batch.eggsTotal,
                    eggsHatched: batch.eggsHatched,
                    status: batch.status,
                    isSuccess: batch.isSuccess,
                  ),
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// BATCH DETAILS SCREEN
// ══════════════════════════════════════════════

class BatchDetailsScreen extends StatefulWidget {
  final BatchData batch;
  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  Map<String, dynamic>? _reading;
  SpeciesData? _preset;

  @override
  void initState() {
    super.initState();
    _loadLiveData();
  }

  /// Loads the latest sensor reading and the preset for this batch's species.
  /// Every step degrades gracefully so the status cards always render.
  Future<void> _loadLiveData() async {
    Map<String, dynamic>? reading;
    SpeciesData? preset;

    try {
      reading = await SupabaseService().getLatestReading();
    } catch (_) {
      reading = null;
    }

    try {
      final presets = await SupabaseService().getPresets();
      for (final p in presets) {
        if (p['egg_type'] == widget.batch.species) {
          preset = SpeciesData.fromPreset(p);
          break;
        }
      }
    } catch (_) {
      preset = null;
    }

    if (mounted) {
      setState(() {
        _reading = reading;
        _preset = preset;
      });
    }
  }

  SpeciesData get _species =>
      _preset ??
      defaultSpeciesList.firstWhere(
        (s) => s.name == widget.batch.species,
        orElse: () => defaultSpeciesList[0],
      );

  bool get _isCompleted => widget.batch.status.toLowerCase() == 'completed';

  double? _liveValue(List<String> keys) {
    final reading = _reading;
    if (reading == null) return null;
    for (final key in keys) {
      final value = reading[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  /// Target temperature for this species (preset when available).
  double get _targetTemperature =>
      double.tryParse(
          _species.temperature.replaceAll(RegExp(r'[^0-9.]'), '')) ??
      double.tryParse(
          widget.batch.temperature.replaceAll(RegExp(r'[^0-9.]'), '')) ??
      37.5;

  /// Set point saved on the session itself.
  double get _setTemperature =>
      double.tryParse(
          widget.batch.temperature.replaceAll(RegExp(r'[^0-9.]'), '')) ??
      _targetTemperature;

  double? get _liveTemperature => _liveValue(['temperature', 'temp']);

  double? get _liveHumidity =>
      _liveValue(['humidity', 'relative_humidity']);

  double get _temperature => _liveTemperature ?? _setTemperature;

  double get _humidity =>
      _liveHumidity ?? _species.targetHumidity.toDouble();

  int get _totalDays => _species.incubationDays;

  int get _currentDay {
    final total = _totalDays;
    final start = DateTime.tryParse(widget.batch.startDate);
    int day;
    if (start == null) {
      day = _isCompleted ? total : 0;
    } else if (_isCompleted) {
      final end = DateTime.tryParse(widget.batch.endDate);
      day = end == null ? total : end.difference(start).inDays;
    } else {
      day = DateTime.now().difference(start).inDays;
    }
    if (day < 0) day = 0;
    if (day > total) day = total;
    return day;
  }

  double get _progress =>
      _totalDays > 0 ? (_currentDay / _totalDays).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final hatchRate =
        batch.eggsTotal > 0 ? batch.eggsHatched / batch.eggsTotal : 0.0;
    final speciesData = _species;
    final currentDay = _currentDay;
    final totalDays = _totalDays;
    final progress = _progress;
    final temperature = _temperature;
    final humidity = _humidity;
    final targetTemperature = _targetTemperature;
    final targetHumidity = speciesData.targetHumidity;
    final liveTemperature = _liveTemperature;
    final liveHumidity = _liveHumidity;
    final hasLiveData = liveTemperature != null || liveHumidity != null;

    final effectiveTemperature = liveTemperature ?? targetTemperature;
    final effectiveHumidity = liveHumidity ?? targetHumidity.toDouble();
    final withinRange =
        (effectiveTemperature - targetTemperature).abs() <= 0.5 &&
            (effectiveHumidity - targetHumidity).abs() <= 5.0;

    final String statusText;
    final String statusHint;
    final Color statusColor;
    final IconData statusIcon;
    if (_isCompleted) {
      statusText = 'Completed';
      statusHint = 'Batch finished';
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
    } else if (!hasLiveData) {
      statusText = 'Standby';
      statusHint = 'Waiting for sensor data';
      statusColor = Colors.grey.shade500;
      statusIcon = Icons.pause_circle_outline;
    } else if (withinRange) {
      statusText = 'Normal';
      statusHint = 'Within target range';
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.check_circle;
    } else {
      statusText = 'Needs attention';
      statusHint = 'Outside target range';
      statusColor = const Color(0xFFF5A623);
      statusIcon = Icons.warning_amber_rounded;
    }

    final temperatureHint = liveTemperature != null
        ? 'Target ${targetTemperature.toStringAsFixed(1)}\u00B0C'
        : 'Set point';

    return Scaffold(
      appBar: AppBar(title: Text(batch.batchNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(speciesData.emoji,
                      style: const TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                batch.batchNumber,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${batch.species} \u2022 ${batch.status}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _DetailRow(label: 'Species', value: batch.species),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Start Date', value: batch.startDate),
                  const SizedBox(height: 12),
                  _DetailRow(label: 'Hatch Date', value: batch.endDate),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: 'Total Eggs', value: '${batch.eggsTotal}'),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: 'Hatched', value: '${batch.eggsHatched}'),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Success Rate',
                    value: '${(hatchRate * 100).toStringAsFixed(0)}%',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: 'Temperature', value: batch.temperature),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── TEMPERATURE / HUMIDITY / PROGRESS / STATUS CARDS ──
            const _SectionLabel(text: 'BATCH STATUS'),
            const SizedBox(height: 10),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BatchStatCard(
                      icon: Icons.thermostat,
                      color: const Color(0xFFE8752A),
                      label: 'Temperature',
                      value: '${temperature.toStringAsFixed(1)}\u00B0C',
                      subtitle: temperatureHint,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BatchStatCard(
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFF2196F3),
                      label: 'Humidity',
                      value: '${humidity.round()}%',
                      subtitle: 'Target $targetHumidity%',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _BatchStatCard(
                      icon: Icons.timelapse_outlined,
                      color: const Color(0xFF9C27B0),
                      label: 'Incubation Progress',
                      value: '${(progress * 100).round()}%',
                      subtitle: 'Day $currentDay of $totalDays',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BatchStatCard(
                      icon: statusIcon,
                      color: statusColor,
                      label: 'Incubator Status',
                      value: statusText,
                      subtitle: statusHint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: hatchRate,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFFE8752A),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8752A),
                  side: const BorderSide(color: Color(0xFFE8752A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PROFILE SCREEN
// ══════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  /// Optional service override, used by widget tests.
  const ProfileScreen({super.key, this.service});

  final SupabaseService? service;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _fallbackName = 'SmartHatch User';

  late final SupabaseService _service;
  String _displayName = _fallbackName;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SupabaseService();
    _displayName = _service.getDisplayName() ?? _fallbackName;
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (_) => EditProfileScreen(service: _service),
      ),
    );
    if (!mounted) return;
    setState(() {
      _displayName = updated ?? _service.getDisplayName() ?? _fallbackName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFE8752A),
                  child: Icon(Icons.person, size: 56, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel(text: 'ACCOUNT'),
              const SizedBox(height: 10),
              _ProfileOption(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                onTap: _openEditProfile,
              ),
              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Account',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AccountSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel(text: 'SETTINGS'),
              const SizedBox(height: 10),
              _ProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPlaceholderScreen(
                        title: 'Notifications',
                      ),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.thermostat_outlined,
                title: 'Temperature Unit',
                subtitle: 'Celsius',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPlaceholderScreen(
                        title: 'Temperature Unit',
                      ),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'English',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPlaceholderScreen(
                        title: 'Language',
                      ),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPlaceholderScreen(
                        title: 'Dark Mode',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const _SectionLabel(text: 'ABOUT'),
              const SizedBox(height: 10),
              _ProfileOption(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('SmartHatch v1.0.0')),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Help & Support will be available in a future version.'),
                    ),
                  );
                },
              ),
              _ProfileOption(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Privacy Policy will be available in a future version.'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// EDIT PROFILE SCREEN
// ══════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  /// Optional service override, used by widget tests.
  const EditProfileScreen({super.key, this.service});

  final SupabaseService? service;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final SupabaseService _service;
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SupabaseService();
    _nameController = TextEditingController(
      text: _service.getDisplayName() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final saved = await _service.updateDisplayName(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      Navigator.pop(context, saved);
    } catch (error) {
      if (!mounted) return;
      // Surface the failure instead of pretending the profile was saved.
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFFE8752A),
                child: Icon(Icons.person, size: 56, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Photo upload will be available in a future version.'),
                  ),
                );
              },
              child: const Text(
                'Change Photo',
                style: TextStyle(color: Color(0xFFE8752A)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              maxLength: 40,
              decoration: InputDecoration(
                labelText: 'Display Name',
                hintText: 'SmartHatch User',
                prefixIcon: const Icon(Icons.person_outlined),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE8752A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// ACCOUNT SETTINGS SCREEN
// ══════════════════════════════════════════════

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel(text: 'DATA'),
            const SizedBox(height: 10),
            _ProfileOption(
              icon: Icons.cloud_upload_outlined,
              title: 'Backup Data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Cloud backup will be available in a future version.'),
                  ),
                );
              },
            ),
            _ProfileOption(
              icon: Icons.cloud_download_outlined,
              title: 'Restore Data',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Data restore will be available in a future version.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// SETTINGS PLACEHOLDER SCREEN
// ══════════════════════════════════════════════

class SettingsPlaceholderScreen extends StatelessWidget {
  final String title;
  const SettingsPlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              Text(
                '$title settings will be\navailable in a future version.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE8752A),
                    side: const BorderSide(color: Color(0xFFE8752A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// TEMPERATURE GAUGE
// ══════════════════════════════════════════════

class _TemperatureGaugePainter extends CustomPainter {
  final double normalizedValue; // 0.0 (min) to 1.0 (max)

  _TemperatureGaugePainter({required this.normalizedValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = 3.14159; // π (left)
    const sweepAngle = 3.14159; // π (half circle)
    const strokeWidth = 14.0;

    // Background arc (full range)
    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Ideal range arc (green zone: 37.0–38.0 in a 35–40 range = 40%–60%)
    final idealStart = 0.4;
    final idealEnd = 0.6;
    final idealPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + idealStart * sweepAngle,
      (idealEnd - idealStart) * sweepAngle,
      false,
      idealPaint,
    );

    // Value arc
    final clampedValue = normalizedValue.clamp(0.0, 1.0);
    final valuePaint = Paint()
      ..color = _getTemperatureColor(clampedValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      clampedValue * sweepAngle,
      false,
      valuePaint,
    );

    // Needle dot
    final needleAngle = startAngle + clampedValue * sweepAngle;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);
    final dotPaint = Paint()
      ..color = _getTemperatureColor(clampedValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(needleX, needleY), 6, dotPaint);
    canvas.drawCircle(
      Offset(needleX, needleY),
      3,
      Paint()..color = Colors.white,
    );
  }

  static Color _getTemperatureColor(double normalized) {
    if (normalized < 0.35) return const Color(0xFF2196F3); // Blue - too low
    if (normalized > 0.65) return const Color(0xFFFF5722); // Red - too high
    return const Color(0xFF4CAF50); // Green - ideal
  }

  @override
  bool shouldRepaint(covariant _TemperatureGaugePainter oldDelegate) {
    return oldDelegate.normalizedValue != normalizedValue;
  }
}

class TemperatureGauge extends StatelessWidget {
  final double currentTemp;
  final double minTemp;
  final double maxTemp;
  final double idealMin;
  final double idealMax;

  const TemperatureGauge({
    super.key,
    required this.currentTemp,
    this.minTemp = 35.0,
    this.maxTemp = 40.0,
    this.idealMin = 37.0,
    this.idealMax = 38.0,
  });

  String get _statusText {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return 'Within the recommended range';
    } else if (currentTemp < idealMin) {
      return 'Below recommended range';
    } else {
      return 'Above recommended range';
    }
  }

  Color get _statusColor {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return const Color(0xFF4CAF50);
    } else if (currentTemp < idealMin) {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFFFF5722);
    }
  }

  IconData get _statusIcon {
    if (currentTemp >= idealMin && currentTemp <= idealMax) {
      return Icons.check_circle_outline;
    } else if (currentTemp < idealMin) {
      return Icons.arrow_downward;
    } else {
      return Icons.arrow_upward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized =
        ((currentTemp - minTemp) / (maxTemp - minTemp)).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.thermostat,
                  color: Color(0xFFE8752A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Temperature',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gauge
          SizedBox(
            width: 180,
            height: 100,
            child: CustomPaint(
              painter: _TemperatureGaugePainter(normalizedValue: normalized),
            ),
          ),
          const SizedBox(height: 8),

          // Temperature value
          Text(
            '${currentTemp.toStringAsFixed(1)}\u00B0C',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon, size: 16, color: _statusColor),
                const SizedBox(width: 6),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Recommended range
          Text(
            'Recommended: ${idealMin.toStringAsFixed(1)}\u00B0C – ${idealMax.toStringAsFixed(1)}\u00B0C',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HUMIDITY GAUGE
// ══════════════════════════════════════════════

class _HumidityGaugePainter extends CustomPainter {
  final double normalizedValue; // 0.0 (min) to 1.0 (max)

  _HumidityGaugePainter({required this.normalizedValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = 3.14159; // π (left)
    const sweepAngle = 3.14159; // π (half circle)
    const strokeWidth = 14.0;

    // Background arc (full range)
    final bgPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Ideal range arc (green zone: 50%–60%)
    final idealStart = 0.5;
    final idealEnd = 0.6;
    final idealPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + idealStart * sweepAngle,
      (idealEnd - idealStart) * sweepAngle,
      false,
      idealPaint,
    );

    // Value arc
    final clampedValue = normalizedValue.clamp(0.0, 1.0);
    final valuePaint = Paint()
      ..color = _getHumidityColor(clampedValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      clampedValue * sweepAngle,
      false,
      valuePaint,
    );

    // Needle dot
    final needleAngle = startAngle + clampedValue * sweepAngle;
    final needleX = center.dx + radius * cos(needleAngle);
    final needleY = center.dy + radius * sin(needleAngle);
    final dotPaint = Paint()
      ..color = _getHumidityColor(clampedValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(needleX, needleY), 6, dotPaint);
    canvas.drawCircle(
      Offset(needleX, needleY),
      3,
      Paint()..color = Colors.white,
    );
  }

  static Color _getHumidityColor(double normalized) {
    if (normalized < 0.45) return const Color(0xFF2196F3); // Blue - too low
    if (normalized > 0.65) return const Color(0xFFFF9800); // Orange - too high
    return const Color(0xFF4CAF50); // Green - ideal
  }

  @override
  bool shouldRepaint(covariant _HumidityGaugePainter oldDelegate) {
    return oldDelegate.normalizedValue != normalizedValue;
  }
}

class HumidityGauge extends StatelessWidget {
  final double currentHumidity;
  final double minHumidity;
  final double maxHumidity;
  final double idealMin;
  final double idealMax;

  const HumidityGauge({
    super.key,
    required this.currentHumidity,
    this.minHumidity = 0.0,
    this.maxHumidity = 100.0,
    this.idealMin = 50.0,
    this.idealMax = 60.0,
  });

  String get _statusText {
    if (currentHumidity >= idealMin && currentHumidity <= idealMax) {
      return 'Within the recommended range';
    } else if (currentHumidity < idealMin) {
      return 'Below recommended range';
    } else {
      return 'Above recommended range';
    }
  }

  Color get _statusColor {
    if (currentHumidity >= idealMin && currentHumidity <= idealMax) {
      return const Color(0xFF4CAF50);
    } else if (currentHumidity < idealMin) {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFFFF9800);
    }
  }

  IconData get _statusIcon {
    if (currentHumidity >= idealMin && currentHumidity <= idealMax) {
      return Icons.check_circle_outline;
    } else if (currentHumidity < idealMin) {
      return Icons.arrow_downward;
    } else {
      return Icons.arrow_upward;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalized =
        ((currentHumidity - minHumidity) / (maxHumidity - minHumidity))
            .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF2196F3),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Humidity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gauge
          SizedBox(
            width: 180,
            height: 100,
            child: CustomPaint(
              painter: _HumidityGaugePainter(normalizedValue: normalized),
            ),
          ),
          const SizedBox(height: 8),

          // Humidity value
          Text(
            '${currentHumidity.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon, size: 16, color: _statusColor),
                const SizedBox(width: 6),
                Text(
                  _statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Recommended range
          Text(
            'Recommended: ${idealMin.toStringAsFixed(0)}% – ${idealMax.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// REUSABLE WIDGETS
// ══════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const _HomeHeader({required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${months[now.month]} ${now.day}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SmartHatch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              size: 22,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewCards extends StatelessWidget {
  final String totalBatches;
  final String bestSuccess;
  final String topSpecies;
  final VoidCallback onTotalBatchesTap;
  final VoidCallback onBestSuccessTap;
  final VoidCallback onTopSpeciesTap;

  const _OverviewCards({
    required this.totalBatches,
    required this.bestSuccess,
    required this.topSpecies,
    required this.onTotalBatchesTap,
    required this.onBestSuccessTap,
    required this.onTopSpeciesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTotalBatchesTap,
            child: _OverviewCard(
              value: totalBatches,
              label: 'TOTAL BATCHES',
              supportingText: 'completed',
              icon: Icons.inventory_2_outlined,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onBestSuccessTap,
            child: _OverviewCard(
              value: bestSuccess,
              label: 'BEST HATCH\nSUCCESS',
              supportingText: 'batch success',
              icon: Icons.emoji_events_outlined,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: onTopSpeciesTap,
            child: _OverviewCard(
              value: topSpecies,
              label: 'TOP SPECIES',
              supportingText: '',
              icon: Icons.egg_outlined,
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String value;
  final String label;
  final String supportingText;
  final IconData icon;

  const _OverviewCard({
    required this.value,
    required this.label,
    required this.supportingText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFE8752A), size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
              letterSpacing: 0.3,
            ),
          ),
          if (supportingText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              supportingText,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}

class _LastBatchCard extends StatelessWidget {
  final BatchData batch;
  const _LastBatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    final hatchRate = batch.eggsTotal > 0 ? batch.eggsHatched / batch.eggsTotal : 0.0;
    final percentage = '${(hatchRate * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.egg_outlined,
                  color: Color(0xFFE8752A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${batch.species.toUpperCase()} \u2022 ${batch.startDate}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESULT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${batch.eggsHatched}/${batch.eggsTotal} hatched',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.grey.shade200,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVG TEMP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch.temperature,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final String name;
  final String description;
  final String emoji;
  final int incubationDays;
  final String temperature;
  final VoidCallback onTap;

  const _SpeciesCard({
    required this.name,
    required this.description,
    required this.emoji,
    required this.incubationDays,
    required this.temperature,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_rounded,
                        label: '$incubationDays days',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.thermostat,
                        label: temperature,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBatchCard extends StatelessWidget {
  final int id;
  final String batchNumber;
  final String species;
  final String startDate;
  final String endDate;
  final int eggsTotal;
  final int eggsHatched;
  final String status;
  final bool isSuccess;

  const _HistoryBatchCard({
    required this.id,
    required this.batchNumber,
    required this.species,
    required this.startDate,
    required this.endDate,
    required this.eggsTotal,
    required this.eggsHatched,
    required this.status,
    required this.isSuccess,
  });

  String _formatDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    return '${months[month]} $day, ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final double hatchRate = eggsTotal > 0 ? eggsHatched / eggsTotal : 0;
    final percentage = '${(hatchRate * 100).round()}%';

    return GestureDetector(
      onTap: () {
        final batch = BatchData(
          id: id,
          batchNumber: batchNumber,
          species: species,
          startDate: startDate,
          endDate: endDate,
          eggsTotal: eggsTotal,
          eggsHatched: eggsHatched,
          temperature: '37.5\u00B0C',
          status: status,
          isSuccess: isSuccess,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BatchDetailsScreen(batch: batch),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    batchNumber,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isSuccess
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                        size: 14,
                        color: isSuccess
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSuccess
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              species,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$eggsHatched / $eggsTotal eggs hatched',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE8752A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(startDate),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE8752A),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFE8752A),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFFE8752A)),
          title: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          subtitle: subtitle != null
              ? Text(subtitle!, style: const TextStyle(fontSize: 13))
              : null,
          trailing:
              const Icon(Icons.chevron_right, color: Colors.black38),
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE8752A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String subtitle;

  const _BatchStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color accentColor;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicatorRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String statusText;
  final Color statusColor;

  const _StatusIndicatorRow({
    required this.icon,
    required this.label,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: statusColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _IncubationControlTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isOn;
  final VoidCallback onToggle;

  const _IncubationControlTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isOn
              ? const Color(0xFFE8752A).withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOn
                ? const Color(0xFFE8752A).withValues(alpha: 0.25)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isOn
                    ? const Color(0xFFE8752A).withValues(alpha: 0.12)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isOn ? const Color(0xFFE8752A) : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isOn
                          ? const Color(0xFFE8752A)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFFE8752A) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                children: [
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.only(
                      left: isOn ? 24 : 4,
                      right: isOn ? 4 : 24,
                    ),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
