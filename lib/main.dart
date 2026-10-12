import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'controllers/incubator_controller.dart';
import 'controllers/arduino_controller.dart';
import 'theme/app_theme.dart';

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
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
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

/// Species description for a stored session's egg_type: the shared defaults
/// when the name matches, or a safe generic fallback for an unknown/legacy
/// value so the real batch still renders. Top-level so Home, the setup
/// guard, and Batch Details all resolve species identically.
SpeciesData speciesDataForName(String name) {
  for (final s in defaultSpeciesList) {
    if (s.name == name) return s;
  }
  return SpeciesData(
    name: name.isEmpty ? 'Eggs' : name,
    emoji: '\uD83E\uDD5A',
    incubationDays: 21,
    temperature: '37.5\u00B0C',
    targetHumidity: 55,
    description: '',
  );
}

/// The farmer-facing Active Incubation screen for a raw Supabase session
/// row. The incubation day is always derived from the SAVED start date -
/// never a default or a simulation.
ActiveIncubationScreen activeIncubationScreenFor(Map<String, dynamic> row) {
  final species = speciesDataForName((row['egg_type'] as String?) ?? '');
  final startDate =
      DateTime.tryParse('${row['start_date']}') ?? DateTime.now();
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
  final startDate = DateTime.tryParse(batch.startDate) ?? DateTime.now();
  return ActiveIncubationScreen(
    species: species,
    eggCount: batch.eggsTotal,
    batchId: batch.batchNumber,
    sessionId: batch.id,
    startDate: startDate,
  );
}

/// Shows the validated Finish Batch dialog and runs the single completion
/// path shared by every entry point (Active Incubation screen, Batch
/// Details). Returns true only when the batch was Completed in the
/// database - never on a dismissed or failed dialog.
Future<bool> showFinishBatchDialog(
  BuildContext context, {
  required Map<String, dynamic> session,
}) async {
  final done = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _FinishBatchDialog(session: session),
  );
  return done ?? false;
}

/// The farmer's Finish Batch dialog: shows the batch details, requires a
/// manually entered hatched-egg count (0..egg_quantity, whole numbers only),
/// previews the hatch success percentage live, explains that finishing ends
/// the incubation, and saves exactly one UPDATE. The batch is only marked
/// Completed when the database confirms the write.
class _FinishBatchDialog extends StatefulWidget {
  const _FinishBatchDialog({required this.session});

  /// The raw Supabase row of the batch being finished.
  final Map<String, dynamic> session;

  @override
  State<_FinishBatchDialog> createState() => _FinishBatchDialogState();
}

class _FinishBatchDialogState extends State<_FinishBatchDialog> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  int get _quantity => (widget.session['egg_quantity'] as int?) ?? 0;
  String get _batchNumber => 'Batch #${widget.session['id']}';
  String get _species => (widget.session['egg_type'] as String?) ?? 'Eggs';

  int? get _entered => int.tryParse(_controller.text.trim());

  /// A count is valid only as a whole number from 0 through the original
  /// egg quantity, inclusive.
  bool get _valid {
    final v = _entered;
    return v != null && v >= 0 && v <= _quantity;
  }

  /// Live hatch-success preview for the entered count (null while invalid).
  double? get _hatchRate {
    if (!_valid) return null;
    if (_quantity == 0) return 0.0;
    return _entered! / _quantity;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final count = _entered;
    if (!_valid || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await SupabaseService().completeSession(
        sessionId: widget.session['id'] as int,
        endDate: DateTime.now(),
        eggsHatched: count,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // The batch stays Active: explain why and let the farmer retry.
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save the results. $_batchNumber is still '
              'incubating - check the connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = DateTime.tryParse('${widget.session['start_date']}');
    final startLabel = start == null
        ? ''
        : ' \u00B7 started ${start.day}/${start.month}/${start.year}';
    final rate = _hatchRate;

    return AlertDialog(
      title: Text('Finish $_batchNumber'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_species \u00B7 $_quantity eggs$startLabel',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Eggs hatched',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Enter the number of eggs that hatched',
                errorText: _valid || _controller.text.trim().isEmpty
                    ? null
                    : 'Enter a whole number from 0 to $_quantity.',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.peach,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rate == null
                    ? 'Enter the hatched count to preview the hatch success.'
                    : 'Hatch success: ${(rate * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: rate == null
                      ? AppColors.textSecondary
                      : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Finishing ends this incubation. The batch moves to History '
              'as Completed with the count you enter - it cannot go back '
              'to incubating.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _valid && !_saving ? _finish : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Finish Batch'),
        ),
      ],
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
      title: 'Smarter Hatching, Better Results.',
      body:
          'SmartHatch helps you monitor and manage your egg incubation with ease.',
    ),
    _OnboardingSlide(
      icon: Icons.monitor_heart_outlined,
      title: 'Track Your Incubation',
      body:
          'Keep track of your eggs, incubation progress, temperature, and expected hatch date in one place.',
    ),
    _OnboardingSlide(
      icon: Icons.inventory_2_outlined,
      title: 'Manage Your Batches',
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
                        // Scrollable so a slide never clips its text at very
                        // large accessibility text sizes; when the content
                        // fits it renders centered exactly as before.
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon - slide 1 carries the SmartHatch logo,
                            // the rest keep their illustrative icons.
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8752A).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: index == 0
                                    ? Container(
                                        width: 96,
                                        height: 96,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Semantics(
                                            image: true,
                                            label: 'SmartHatch logo',
                                            excludeSemantics: true,
                                            child: SizedBox(
                                              width: 84,
                                              height: 84,
                                              child: Image.asset(
                                                'assets/logo.png',
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(
                                                  slide.icon,
                                                  size: 56,
                                                  color: const Color(
                                                      0xFFE8752A),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        slide.icon,
                                        size: 60,
                                        color: const Color(0xFFE8752A),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Title - kept on one line whenever the natural
                            // width fits, natural word wrap otherwise. No
                            // hardcoded line breaks, no shrinking, no
                            // clipping.
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final style = const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                );
                                // Measure with the current text scale so 1.3x
                                // accessibility sizing decides correctly too.
                                final double fontSize = MediaQuery.textScalerOf(
                                        context)
                                    .scale(style.fontSize!);
                                final painter = TextPainter(
                                  text: TextSpan(
                                    text: slide.title,
                                    style: style.copyWith(
                                        fontSize: fontSize),
                                  ),
                                  textDirection: TextDirection.ltr,
                                )..layout();
                                final bool oneLine =
                                    painter.width <= constraints.maxWidth;
                                painter.dispose();
                                return Text(
                                  slide.title,
                                  textAlign: TextAlign.center,
                                  maxLines: oneLine ? 1 : null,
                                  style: style,
                                );
                              },
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
                          ),
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
///
/// Rendered as a floating dark-charcoal pill with a solid orange indicator
/// and a dark charcoal icon on top of it. The bar still lives in the
/// Scaffold's reserved bottom-navigation slot, so it can never cover the
/// content above it, and the pill gets its own safe-area spacing so it stays
/// clear of the Android/iOS system navigation.
class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({required this.selectedIndex, required this.onSelected});

  /// The currently shown section: 0 Home, 1 Species, 2 History.
  final int selectedIndex;

  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // Space below the pill for the system navigation bar / gesture area.
    // This is 0 when the window does not extend behind the system bars
    // (and in tests), so the pill never gets a double inset.
    final double systemInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      // Transparent margins around the pill let the screen background show.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm + systemInset,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.navigationSurface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          // Warm hairline so the white pill separates gently from the cream
          // page background.
          border: Border.all(color: AppColors.borderWarm),
          boxShadow: AppShadows.navigationPill,
        ),
        // The system inset is already applied above so the pill itself - not
        // only its content - clears the system navigation; without this the
        // NavigationBar's own SafeArea would apply it a second time.
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onSelected,
            // Transparent so the white pill shows through the bar.
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64,
            // Soft peach indicator behind a dark orange icon.
            indicatorColor: AppColors.peach,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            // Labels stay visible for every state; the selected one is the
            // brand orange and heavier so the active tab is obvious without
            // relying on colour alone.
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
                final bool selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.primaryDark : AppColors.navigationInactive,
                );
              },
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: AppColors.navigationInactive,
                ),
                selectedIcon: Icon(Icons.home, color: AppColors.primaryDark),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.egg_outlined,
                  color: AppColors.navigationInactive,
                ),
                selectedIcon: Icon(Icons.egg, color: AppColors.primaryDark),
                label: 'Species',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.history_outlined,
                  color: AppColors.navigationInactive,
                ),
                selectedIcon: Icon(
                  Icons.history,
                  color: AppColors.primaryDark,
                ),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
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
  final ArduinoController _arduino = ArduinoController.instance;

  @override
  void initState() {
    super.initState();
    _arduino.addListener(_onArduinoChanged);
    _loadData();
  }

  void _onArduinoChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _arduino.removeListener(_onArduinoChanged);
    super.dispose();
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

  /// Home's primary full-width pill in the readable dark orange with white
  /// AA-contrast labels. The label is flexible, so the button can never
  /// overflow on narrow screens - it shortens with an ellipsis instead.
  Widget _primaryPill({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    // P6.2 - at most ONE batch is ever Active (enforced in the service and
    // by the database index), so the first Active row IS the current batch.
    final activeBatch = _batches.cast<BatchData?>().firstWhere(
          (b) => b!.status == 'Active',
          orElse: () => null,
        );
    // "Last Batch" shows only the most recently COMPLETED batch - an
    // incubating batch is never presented as a finished result.
    final lastCompleted =
        completedBatches.isNotEmpty ? completedBatches.first : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
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

            // Primary action: a full-width pill in the readable dark orange
            // with white AA-contrast labels. The label is flexible, so the
            // button can never overflow on narrow screens - it shortens with
            // an ellipsis instead.
            //
            // P6.2 - one active batch: while a batch is incubating, Home
            // offers only "View Active Incubation"; "Start New Incubation"
            // appears solely when no batch is running.
            if (activeBatch != null) ...[
              const _SectionLabel(text: 'CURRENT INCUBATION'),
              const SizedBox(height: 10),
              _CurrentIncubationCard(
                batch: activeBatch,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          activeIncubationScreenForBatch(activeBatch),
                    ),
                  );
                  if (mounted) _loadData();
                },
              ),
              const SizedBox(height: 16),
              _primaryPill(
                icon: Icons.visibility_outlined,
                label: 'View Active Incubation',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          activeIncubationScreenForBatch(activeBatch),
                    ),
                  );
                  if (mounted) _loadData();
                },
              ),
            ] else
              _primaryPill(
                icon: Icons.add,
                label: 'Start New Incubation',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncubationSetupScreen(),
                    ),
                  );
                  // Returning from setup/starting a batch refreshes Home so
                  // the Current Incubation card appears immediately.
                  if (mounted) _loadData();
                },
              ),
            const SizedBox(height: 24),

            // Live incubator status (visible on the dashboard, no navigation needed)
            _LiveIncubatorStatusCard(controller: _arduino),
            const SizedBox(height: 24),

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

            // P6.2 - only a COMPLETED batch is shown as a finished result;
            // active batches live in the Current Incubation card above.
            const _SectionLabel(text: 'LAST COMPLETED BATCH'),
            const SizedBox(height: 10),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (lastCompleted != null)
              _LastBatchCard(
                batch: lastCompleted,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BatchDetailsScreen(batch: lastCompleted),
                    ),
                  );
                  if (mounted) _loadData();
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.12),
                  ),
                ),
                child: Center(
                  child: Text(
                    _batches.isEmpty
                        ? 'No batches yet. Start your first incubation!'
                        : 'No completed batches yet. Your hatch results '
                            'will appear here.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
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

/// The farmer's single source of truth for the batch incubating right now
/// (P6.2): real batch number, species, egg quantity, actual start date, the
/// incubation day calculated FROM THE SAVED START DATE, and progress over
/// the species' real duration - never simulated data. The whole card opens
/// the Active Incubation screen.
class _CurrentIncubationCard extends StatelessWidget {
  const _CurrentIncubationCard({required this.batch, required this.onTap});

  final BatchData batch;
  final VoidCallback onTap;

  static String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final species = speciesDataForName(batch.species);
    final totalDays = species.incubationDays;
    final start = DateTime.tryParse(batch.startDate) ?? DateTime.now();
    final elapsed = DateTime.now().difference(start).inDays;
    final day = (elapsed + 1).clamp(1, totalDays).toInt();
    final daysLeft = totalDays - day;
    final progress = (day / totalDays).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Semantics(
        button: true,
        label: 'Open current incubation, ${batch.batchNumber}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpeciesIllustration(species: batch.species, size: 48),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${batch.batchNumber} \u00B7 ${batch.species}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${batch.eggsTotal} eggs \u00B7 '
                              'Started ${_formatDate(start)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _StatusBadge(
                        label: 'Incubating',
                        color: AppColors.warning,
                        icon: Icons.play_circle_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day $day of $totalDays',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        daysLeft <= 0 ? 'Hatch day' : '$daysLeft days left',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.peach,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Short, plain-language intro under the screen heading.
              const Text(
                'Choose the type of eggs you want to incubate.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else
                ..._species.map(
                  (species) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
              child: SpeciesIllustration(
                species: species.name,
                emoji: species.emoji,
                size: 80,
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
  int _eggCount = SupabaseService.minBatchSize;
  int _currentStep = 1;
  List<SpeciesData> _speciesList = defaultSpeciesList;

  // Quantity state: [_eggCount] is the amount being chosen, [_customMode]
  // tracks the Custom quick choice (it reveals the typed amount), and
  // [_quantityError] holds the farmer-friendly message shown under the field
  // while a typed amount cannot be used. Quick choices and the +/− counter
  // always stay inside the SmartHatch capacity of 6 to 12 eggs.
  final TextEditingController _customEggController =
      TextEditingController(text: '${SupabaseService.minBatchSize}');
  bool _customMode = false;
  String? _quantityError;

  // P6.1 - one active incubation: while a batch is incubating this screen
  // shows a blocking panel (and the route to the current incubation) instead
  // of the setup form. [_activeSession] is the raw Supabase row.
  bool _checkingActive = true;
  Map<String, dynamic>? _activeSession;

  @override
  void initState() {
    super.initState();
    _selectedSpecies = widget.selectedSpecies;
    if (_selectedSpecies != null) _currentStep = 2;
    _loadSpecies();
    _checkActiveBatch();
  }

  @override
  void dispose() {
    _customEggController.dispose();
    super.dispose();
  }

  /// Continue is only offered for a quantity SmartHatch can incubate.
  bool get _quantityIsValid =>
      _quantityError == null &&
      SupabaseService.eggQuantityError(_eggCount) == null;

  /// Quick choice: the minimum batch size or the maximum capacity.
  void _selectQuickChoice(int eggs) {
    setState(() {
      _eggCount = eggs;
      _customMode = false;
      _quantityError = null;
      _setCustomQuantityText('$eggs');
    });
  }

  /// Custom choice: keep the current amount and show the typed entry.
  void _selectCustomChoice() {
    setState(() {
      _customMode = true;
      _quantityError = SupabaseService.eggQuantityError(_eggCount);
    });
  }

  /// The +/− counter can only land between the minimum batch size and the
  /// maximum capacity, and stepping away from a quick choice is a custom
  /// amount.
  void _stepEggCount(int delta) {
    var next = _eggCount + delta;
    if (next < SupabaseService.minBatchSize) {
      next = SupabaseService.minBatchSize;
    }
    if (next > SupabaseService.maxCapacity) {
      next = SupabaseService.maxCapacity;
    }
    setState(() {
      _eggCount = next;
      _customMode = true;
      _setCustomQuantityText('$next');
      _quantityError = null;
    });
  }

  /// Replaces the custom quantity text without throwing the cursor back to
  /// position zero.
  ///
  /// Writing `controller.text` clears the selection, so the caret jumped to
  /// the start of the field every time the +/− buttons were tapped. This
  /// keeps the caret where the farmer left it: at the end when it was at (or
  /// selecting up to) the end of the text, otherwise at the same spot clamped
  /// inside the new text - always a valid position, even when the field is
  /// empty.
  void _setCustomQuantityText(String text) {
    final selection = _customEggController.selection;
    final oldLength = _customEggController.text.length;
    // An unset selection (-1, as after a previous programmatic write) counts
    // as "at the end of the text" too.
    final atEnd = !selection.isValid || selection.end >= oldLength;
    final offset =
        atEnd ? text.length : selection.end.clamp(0, text.length).toInt();
    _customEggController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  // The typed amount is the only place an unusable value (empty, 0, below the
  // minimum or above the capacity) can appear, so the message shows right
  // where the farmer fixes it.
  void _onCustomEggCountChanged(String raw) {
    final text = raw.trim();
    setState(() {
      if (text.isEmpty) {
        _eggCount = 0;
        _quantityError = 'Please enter the number of eggs.';
        return;
      }
      final parsed = int.tryParse(text);
      _eggCount = parsed ?? 0;
      _quantityError = parsed == null
          ? 'Please enter a whole number of eggs.'
          : SupabaseService.eggQuantityError(parsed);
    });
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

  /// Blocks setup while a batch is incubating (P6.1).
  ///
  /// [SupabaseService.createSession] stays the authoritative guard; this
  /// only avoids offering a form the farmer cannot use. A failed lookup
  /// (e.g. offline) falls through to the form - the start button still
  /// refuses through the service.
  Future<void> _checkActiveBatch() async {
    try {
      final active = await SupabaseService().getActiveSession();
      if (mounted) {
        setState(() {
          _activeSession = active;
          _checkingActive = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _checkingActive = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // P6.1 - one active incubation: setup closes while a batch runs.
    if (_checkingActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Incubation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final active = _activeSession;
    if (active != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New Incubation')),
        body: _buildBlockedByActiveBatch(active),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(_currentStep == 1 ? 'Select Species' : 'Egg Quantity')),
      body: _currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  // ── P6.1: blocked while a batch is incubating ──

  /// Full-screen refusal shown while another batch is running: names the
  /// batch and sends the farmer to it instead of the setup form.
  Widget _buildBlockedByActiveBatch(Map<String, dynamic> active) {
    final batchId = 'Batch #${active['id']}';
    final speciesName = (active['egg_type'] as String?) ?? 'Eggs';
    final start = DateTime.tryParse('${active['start_date']}');
    final startLabel = start == null
        ? 'recently'
        : '${start.day}/${start.month}/${start.year}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpeciesIllustration(species: speciesName, size: 56),
          const SizedBox(height: 20),
          const Text(
            'A batch is already incubating',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$batchId ($speciesName) started on $startLabel and must be '
            'finished before a new incubation can start. '
            'SmartHatch runs one batch at a time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => _openCurrentIncubation(active),
              icon: const Icon(Icons.monitor_heart_outlined, size: 20),
              label: const Text(
                'View Current Incubation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8752A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go back'),
          ),
        ],
      ),
    );
  }

  /// Opens the farmer-facing Active Incubation screen for [active], and
  /// re-checks on return so the panel clears as soon as the batch is no
  /// longer active.
  Future<void> _openCurrentIncubation(Map<String, dynamic> active) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => activeIncubationScreenFor(active),
      ),
    );
    if (mounted) await _checkActiveBatch();
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
                        SpeciesIllustration(
                          species: species.name,
                          emoji: species.emoji,
                          size: 56,
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
                // Species illustration (quail glyph placeholder until a
                // species is chosen, exactly as before).
                SpeciesIllustration(
                  species: _selectedSpecies?.name,
                  emoji: _selectedSpecies?.emoji ?? '\uD83E\uDD5A',
                  size: 56,
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
          const SizedBox(height: 24),

          // Quick choices: the two supported batch sizes plus Custom.
          Text(
            'Quick choices',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuantityChoice(
                  label: '${SupabaseService.minBatchSize} eggs',
                  isSelected:
                      !_customMode && _eggCount == SupabaseService.minBatchSize,
                  onTap: () => _selectQuickChoice(SupabaseService.minBatchSize),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuantityChoice(
                  label: '${SupabaseService.maxCapacity} eggs',
                  isSelected:
                      !_customMode && _eggCount == SupabaseService.maxCapacity,
                  onTap: () => _selectQuickChoice(SupabaseService.maxCapacity),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuantityChoice(
                  label: 'Custom',
                  isSelected: _customMode,
                  onTap: _selectCustomChoice,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Egg counter with +/− buttons, held inside the capacity.
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
                    onTap: _eggCount > SupabaseService.minBatchSize
                        ? () => _stepEggCount(-1)
                        : null,
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      // An emptied custom field shows a dash instead of a
                      // zero, so "0 eggs" can never appear on this screen.
                      _eggCount > 0 ? '$_eggCount' : '\u2013',
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
                    onTap: _eggCount < SupabaseService.maxCapacity
                        ? () => _stepEggCount(1)
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

          // Custom amount: only shown for the Custom quick choice.
          if (_customMode) _buildCustomQuantity(),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _quantityIsValid
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
                elevation: _quantityIsValid ? 2 : 0,
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

  // Custom amount entry with the farmer-friendly message shown underneath.
  Widget _buildCustomQuantity() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _customEggController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onCustomEggCountChanged,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Custom quantity',
              labelStyle:
                  TextStyle(fontSize: 14, color: Colors.grey.shade600),
              hintText:
                  'Type ${SupabaseService.minBatchSize} to ${SupabaseService.maxCapacity}',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 15),
              suffixText: 'eggs',
              suffixStyle:
                  TextStyle(color: Colors.grey.shade500, fontSize: 14),
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
                borderSide:
                    const BorderSide(color: Color(0xFFE8752A), width: 1.5),
              ),
            ),
          ),

          // Farmer-friendly validation message for an unusable amount.
          if (_quantityError != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      size: 17, color: Colors.red.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _quantityError!,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.red.shade400,
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

  /// When true the chip uses the warm SmartHatch palette (soft peach surface,
  /// dark orange icon). The default keeps the original cool-grey look so
  /// other screens are unaffected.
  final bool warm;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.warm = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warm ? AppColors.peach : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: warm ? AppColors.primaryDark : Colors.black45,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: warm ? AppColors.textSecondary : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared species illustration ──

/// The local bird PNG from `assets/species/` on a soft-peach circle, used
/// everywhere a species-specific graphic appears.
///
/// Species names are matched case-insensitively ('Chicken', 'duck', …).
/// Unknown or missing species fall back to [emoji] (or a generic egg glyph)
/// so future presets never crash, and each illustration is announced to
/// screen readers as its own image node.
class SpeciesIllustration extends StatelessWidget {
  const SpeciesIllustration({
    super.key,
    required this.species,
    this.emoji,
    this.size = 56,
    this.artwork,
    this.label,
  });

  /// Species name, e.g. 'Chicken'. Case-insensitive; may be null/unknown.
  final String? species;

  /// Fallback glyph shown when [species] has no local illustration.
  final String? emoji;

  /// Diameter of the peach circle.
  final double size;

  /// Diameter of the artwork; defaults to ~76% of [size].
  final double? artwork;

  /// Screen-reader label; defaults to 'Illustration of a [species] bird'
  /// for known species and 'Species illustration' otherwise.
  final String? label;

  /// Species that have a local illustration asset.
  static const Set<String> _illustrated = {'chicken', 'duck', 'quail'};

  @override
  Widget build(BuildContext context) {
    final String key = (species ?? '').trim().toLowerCase();
    final bool hasArt = _illustrated.contains(key);
    final double art = artwork ?? size * 0.76;
    final String friendly = (species ?? '').trim();
    return Semantics(
      container: true,
      image: true,
      excludeSemantics: true,
      label: label ??
          (hasArt ? 'Illustration of a $friendly bird' : 'Species illustration'),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.peach,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: hasArt
              ? SizedBox(
                  width: art,
                  height: art,
                  child: Image.asset(
                    'assets/species/$key.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        _fallbackGlyph(art),
                  ),
                )
              : _fallbackGlyph(art),
        ),
      ),
    );
  }

  /// Emoji when we have one, otherwise a generic egg mark - never a crash.
  Widget _fallbackGlyph(double art) {
    final String? glyph = emoji;
    if (glyph != null && glyph.isNotEmpty) {
      return Text(glyph, style: TextStyle(fontSize: art * 0.62));
    }
    return Icon(
      Icons.egg_outlined,
      size: art * 0.75,
      color: AppColors.primaryDark,
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

// ── Quick quantity choice (6 eggs / 12 eggs / Custom) ──

class _QuantityChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuantityChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFDF3EC)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE8752A)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFFE8752A) : Colors.black87,
          ),
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

  // P6.1: blocks a second tap while the start request is in flight, so one
  // tap can never create two sessions.
  bool _starting = false;

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
                  SpeciesIllustration(
                    species: widget.species.name,
                    emoji: widget.species.emoji,
                    // Footprint-matched to the old 28px glyph: this screen's
                    // body is a non-scrollable column, so the circle must not
                    // grow the card.
                    size: 36,
                  ),
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
                onPressed: _allChecked && !_starting
                    ? () async {
                        // Re-entrancy gate for the whole handler: a second
                        // tap in the same frame (before the disabled rebuild
                        // lands) is ignored just the same.
                        if (_starting) return;

                        // Final gate: an incubation can never start with an
                        // unusable egg quantity.
                        final quantityError =
                            SupabaseService.eggQuantityError(widget.eggCount);
                        if (quantityError != null) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(content: Text(quantityError)),
                          );
                          return;
                        }

                        // One-active rule, tap edition: the button disables
                        // itself while the start request is in flight, so a
                        // double-tap can never create two sessions.
                        setState(() => _starting = true);

                        try {
                          final service = SupabaseService();
                          final now = DateTime.now();
                          final tempNum = double.tryParse(
                            widget.species.temperature.replaceAll(RegExp(r'[^0-9.]'), ''),
                          ) ?? 37.5;

                          // 1. Create the session - the one-active rule
                          // lives here: an active batch (any species) refuses
                          // the start, and the database unique index settles
                          // any tie between devices or tabs.
                          final sessionId = await service.createSession(
                            eggType: widget.species.name,
                            startDate: now,
                            eggQuantity: widget.eggCount,
                            temperature: tempNum,
                          );

                          // 2. Hardware targets are written only AFTER the
                          // batch exists, so a refused start can never
                          // overwrite the settings of a running batch.
                          await service.updateActiveSettings(
                            eggType: widget.species.name,
                            temperature: tempNum,
                            humidity: 55,
                            incubationDays: widget.species.incubationDays,
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
                        } on ActiveBatchException catch (e) {
                          // Farmer-friendly refusal: a batch is incubating.
                          if (mounted) {
                            setState(() => _starting = false);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() => _starting = false);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  // Egg quantity problems already read as a
                                  // friendly sentence - show them unchanged.
                                  e is EggQuantityException
                                      ? e.message
                                      : 'Error: $e',
                                ),
                              ),
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
                  elevation: _allChecked && !_starting ? 2 : 0,
                ),
                child: _starting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Start Incubation',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                          leading: SpeciesIllustration(
                            species: species.name,
                            emoji: species.emoji,
                            size: 32,
                          ),
                          value: species.name),
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
  const ActiveIncubationScreen({
    super.key,
    required this.species,
    required this.eggCount,
    required this.batchId,
    required this.sessionId,
    required this.startDate,
  });

  @override
  State<ActiveIncubationScreen> createState() => _ActiveIncubationScreenState();
}

class _ActiveIncubationScreenState extends State<ActiveIncubationScreen> {
  final ArduinoController _arduino = ArduinoController.instance;
  final AlertMode _alertMode = AlertMode.normal;

  /// The REAL saved session, loaded from Supabase on open. The finish flow
  /// only ever acts on this row - never on screen parameters.
  Map<String, dynamic>? _session;
  bool _sessionLoading = true;
  bool _sessionMissing = false;

  @override
  void initState() {
    super.initState();
    _arduino.addListener(_onArduinoChanged);
    _loadSession();
  }

  /// Fetches this batch's saved row so the screen shows what is actually
  /// stored. A batch that no longer exists (or was already finished)
  /// replaces the incubation UI with a clear explanation.
  Future<void> _loadSession() async {
    try {
      final row = await SupabaseService().getSessionById(widget.sessionId);
      if (!mounted) return;
      setState(() {
        _session = row;
        _sessionMissing = row == null;
        _sessionLoading = false;
      });
    } catch (_) {
      // Offline: keep showing the parameter-based view; the finish flow
      // still validates and the service refuses anything that cannot save.
      if (mounted) setState(() => _sessionLoading = false);
    }
  }

  /// True while the stored row still says Active (or could not be fetched,
  /// in which case the finish attempt itself is the authority).
  bool get _isActive =>
      !_sessionMissing &&
      (_session == null ||
          '${_session!['status']}'.toLowerCase() == 'active');

  /// The incubation day calculated from the SAVED start date - day 1 is
  /// the start day itself. Never a default and never a simulation.
  int _dayFromStart(SpeciesData species) {
    final elapsed = DateTime.now().difference(widget.startDate).inDays;
    final day = elapsed + 1;
    if (day < 1) return 1;
    return day > species.incubationDays ? species.incubationDays : day;
  }

  /// Opens the validated Finish Batch dialog. On success the batch is
  /// Completed in the database and the farmer lands on a fresh dashboard
  /// where the result shows under Last Completed Batch and a new
  /// incubation can be started.
  Future<void> _confirmFinish() async {
    final session = _session;
    if (session == null) return;
    final done = await showFinishBatchDialog(context, session: session);
    if (done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.batchId} finished - see History.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _arduino.removeListener(_onArduinoChanged);
    super.dispose();
  }

  void _onArduinoChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Current Incubation')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Current Incubation')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 56, color: AppColors.success),
              const SizedBox(height: 20),
              const Text(
                'This batch is no longer incubating',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.batchId} has already been finished. '
                'Its hatch results are saved in History.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_outlined, size: 20),
                  label: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final species = widget.species;
    final eggCount = widget.eggCount;
    final batchId = widget.batchId;
    final startDate = widget.startDate;
    final currentDay = _dayFromStart(species);
    final totalDays = species.incubationDays;
    final progress = currentDay / totalDays;
    final hatchDate = startDate.add(Duration(days: totalDays));
    final isComplete = currentDay >= totalDays;
    final targetTemp = double.tryParse(
          species.temperature.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        37.5;
    final targetHumidity = species.targetHumidity.toDouble();
    final tempStatus = _metricStatus(
      connected: _arduino.isConnected,
      value: _arduino.incubatorTemperature,
      idealMin: targetTemp - 0.5,
      idealMax: targetTemp + 0.5,
    );
    final humStatus = _metricStatus(
      connected: _arduino.isConnected,
      value: _arduino.incubatorHumidity,
      idealMin: targetHumidity - 5,
      idealMax: targetHumidity + 5,
    );

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

            // ── ARDUINO CONNECTION ──
            _ArduinoConnectionCard(controller: _arduino),
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
                    statusText: tempStatus.$1,
                    statusColor: tempStatus.$2,
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    statusText: humStatus.$1,
                    statusColor: humStatus.$2,
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.air,
                    label: 'Fan',
                    statusText: !_arduino.isConnected
                        ? 'Offline'
                        : (_arduino.actuatorOn('incubatorFan') ? 'On' : 'Off'),
                    statusColor: !_arduino.isConnected
                        ? Colors.grey.shade500
                        : (_arduino.actuatorOn('incubatorFan')
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade500),
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.sync,
                    label: 'Egg Turning',
                    statusText: _eggTurningRow,
                    statusColor: !_arduino.isConnected
                        ? Colors.grey.shade500
                        : (_arduino.turningActive
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade500),
                  ),
                  const SizedBox(height: 10),
                  _StatusIndicatorRow(
                    icon: Icons.wifi,
                    label: 'Connection',
                    statusText: _arduino.isConnected ? 'Connected' : 'Disconnected',
                    statusColor: _arduino.isConnected
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade500,
                  ),
                  if (_arduino.isConnected && _arduino.isStale) ...[
                    const SizedBox(height: 10),
                    _StatusIndicatorRow(
                      icon: Icons.history,
                      label: 'Telemetry',
                      statusText: 'Stale — no recent data',
                      statusColor: const Color(0xFFFF9800),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── BROODER STATUS (live from Arduino) ──
            const _SectionLabel(text: 'BROODER STATUS'),
            const SizedBox(height: 10),
            _buildBrooderStatusCard(),
            const SizedBox(height: 20),

            // ── SPECIES + BATCH ──
            Row(
              children: [
                SpeciesIllustration(
                  species: species.name,
                  emoji: species.emoji,
                  size: 52,
                ),
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

            // ── TEMPERATURE GAUGE (live Arduino data only) ──
            if (_arduino.incubatorTemperature != null)
              TemperatureGauge(
                currentTemp: _arduino.incubatorTemperature!,
                idealMin: targetTemp - 0.5,
                idealMax: targetTemp + 0.5,
              )
            else
              const _ArduinoPlaceholderCard(
                icon: Icons.thermostat,
                title: 'Temperature',
                message: 'Waiting for live data from the Arduino…',
              ),
            const SizedBox(height: 20),

            // ── HUMIDITY GAUGE (live Arduino data only) ──
            if (_arduino.incubatorHumidity != null)
              HumidityGauge(
                currentHumidity: _arduino.incubatorHumidity!,
                idealMin: targetHumidity - 5,
                idealMax: targetHumidity + 5,
              )
            else
              const _ArduinoPlaceholderCard(
                icon: Icons.water_drop,
                title: 'Humidity',
                message: 'Waiting for live data from the Arduino…',
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

            // ── INCUBATION CONTROLS (live Arduino actuators) ──
            const _SectionLabel(text: 'INCUBATION CONTROLS'),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'incubatorBulb',
              icon: Icons.lightbulb_outline,
              label: 'Incubator Bulb',
              onSubtitle: 'Heating ON',
              offSubtitle: 'Heating OFF',
            ),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'incubatorFan',
              icon: Icons.air,
              label: 'Circulation Fan',
              onSubtitle: 'Circulating air',
              offSubtitle: 'Off',
            ),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'exhaustFan',
              icon: Icons.mode_fan_off,
              label: 'Exhaust / Intake Fan',
              onSubtitle: 'Venting',
              offSubtitle: 'Closed',
            ),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'incubatorHumidifier',
              icon: Icons.water_drop_outlined,
              label: 'Incubator Humidifier',
              onSubtitle: 'Humidifying',
              offSubtitle: 'Off',
            ),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'brooderBulb',
              icon: Icons.lightbulb_outline,
              label: 'Brooder Bulb',
              onSubtitle: 'Heating ON',
              offSubtitle: 'Heating OFF',
            ),
            const SizedBox(height: 10),
            _actuatorTile(
              actuator: 'brooderHumidifier',
              icon: Icons.cloud_outlined,
              label: 'Brooder Humidifier',
              onSubtitle: 'Humidifying',
              offSubtitle: 'Off',
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: _arduino.isConnected ? 1.0 : 0.5,
              child: _IncubationControlTile(
                icon: Icons.sync,
                label: 'Egg Turning',
                subtitle: _eggTurningDetail(_arduino),
                isOn: _arduino.turningActive,
                onToggle: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Egg turning runs automatically every 4 hours.'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // ── ALERTS & REMINDERS ──
            const _SectionLabel(text: 'ALERTS & REMINDERS'),
            const SizedBox(height: 10),
            _buildAlertCard(),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IncubatorDashboardPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.developer_board),
                label: const Text(
                  'Open Hardware Console',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3F51B5),
                  side: const BorderSide(color: Color(0xFF3F51B5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            // ── FINISH BATCH (P6.3) ──
            // The only way a batch ends: the farmer enters the real hatched
            // count in a validated dialog and confirms. Nothing ever
            // completes automatically.
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _confirmFinish,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  'Finish Batch',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finishing ends this incubation and records the number of '
              'eggs that actually hatched.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),

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

  Widget _buildBrooderStatusCard() {
    final connected = _arduino.isConnected;
    final tStatus = _metricStatus(
      connected: connected,
      value: _arduino.brooderTemperature,
      idealMin: 30.0,
      idealMax: 32.0,
    );
    final hStatus = _metricStatus(
      connected: connected,
      value: _arduino.brooderHumidity,
      idealMin: 45.0,
      idealMax: 60.0,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F51B5).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3F51B5).withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.nest_cam_wired_stand, color: Color(0xFF3F51B5), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Brooder is monitored live',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3F51B5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _StatusIndicatorRow(
            icon: Icons.thermostat_outlined,
            label: 'Brooder Temperature'
                '${_arduino.brooderTemperature != null ? ' (${_arduino.brooderTemperature!.toStringAsFixed(1)} °C)' : ''}',
            statusText: tStatus.$1,
            statusColor: tStatus.$2,
          ),
          const SizedBox(height: 10),
          _StatusIndicatorRow(
            icon: Icons.water_drop_outlined,
            label: 'Brooder Humidity'
                '${_arduino.brooderHumidity != null ? ' (${_arduino.brooderHumidity!.toStringAsFixed(0)} %)' : ''}',
            statusText: hStatus.$1,
            statusColor: hStatus.$2,
          ),
        ],
      ),
    );
  }

  (String, Color) _metricStatus({
    required bool connected,
    required double? value,
    required double idealMin,
    required double idealMax,
  }) {
    if (!connected) return ('Offline', Colors.grey.shade500);
    if (value == null) return ('Sensor error', const Color(0xFFFF9800));
    if (value >= idealMin && value <= idealMax) {
      return ('Normal', const Color(0xFF4CAF50));
    }
    return ('Out of range', const Color(0xFFFF9800));
  }

  Future<void> _toggleActuator(String actuator) async {
    if (!_arduino.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect the Arduino first.')),
      );
      return;
    }
    final desired = !_arduino.actuatorOn(actuator);
    final ok = await _arduino.setActuator(actuator, desired);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_arduino.lastError ?? 'Command failed.')),
      );
    }
  }

  Widget _actuatorTile({
    required String actuator,
    required IconData icon,
    required String label,
    required String onSubtitle,
    required String offSubtitle,
  }) {
    final connected = _arduino.isConnected;
    final isOn = _arduino.actuatorOn(actuator);
    final fallback = isOn ? onSubtitle : offSubtitle;
    return Opacity(
      opacity: connected ? 1.0 : 0.5,
      child: _IncubationControlTile(
        icon: icon,
        label: label,
        subtitle: _actuatorSubtitle(actuator, fallback),
        isOn: isOn,
        onToggle: () => _toggleActuator(actuator),
      ),
    );
  }

  String get _eggTurningRow {
    if (!_arduino.isConnected) return 'Offline';
    if (!_arduino.isLive) return 'Waiting…';
    if (!_arduino.turningActive) return 'Disabled';
    final done = _arduino.turnsToday ?? 0;
    final planned = _arduino.scheduledTurnsPerDay;
    return 'On ($done of $planned today)';
  }

  String _actuatorSubtitle(String actuator, String fallback) {
    switch (_arduino.commandStatus(actuator)) {
      case ActuatorCommandStatus.pending:
        return 'Sending command…';
      case ActuatorCommandStatus.confirmed:
        return 'Confirmed by Arduino';
      case ActuatorCommandStatus.rejected:
        return 'Rejected by Arduino';
      case ActuatorCommandStatus.failed:
        return 'Command failed';
      case ActuatorCommandStatus.idle:
        return fallback;
    }
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

  // Local-only filters - purely in-memory views over the loaded batches;
  // stored records are never changed, deleted, or overwritten.
  String _statusFilter = 'All'; // All | Active | Completed
  String _speciesFilter = 'All'; // All | Chicken | Duck | Quail
  int _daysFilter = 0; // 0 = any time, otherwise a "last N days" cutoff

  bool get _hasFilters =>
      _statusFilter != 'All' || _speciesFilter != 'All' || _daysFilter != 0;

  bool get _hasActiveQuery =>
      _searchQuery.isNotEmpty || _hasFilters;

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

  /// Applies the search text and the status/species/date filters to an
  /// in-memory list. Used both for the visible list and for the live count
  /// preview inside the filter sheet.
  static List<BatchData> _applyFilters(
    List<BatchData> batches, {
    required String query,
    required String status,
    required String species,
    required int days,
  }) {
    final q = query.trim().toLowerCase();
    final cutoff =
        days == 0 ? null : DateTime.now().subtract(Duration(days: days));
    return batches.where((b) {
      if (q.isNotEmpty &&
          !(b.batchNumber.toLowerCase().contains(q) ||
              b.species.toLowerCase().contains(q))) {
        return false;
      }
      if (status != 'All' && b.status != status) return false;
      if (species != 'All' && b.species != species) return false;
      if (cutoff != null) {
        final start = DateTime.tryParse(b.startDate);
        if (start == null || start.isBefore(cutoff)) return false;
      }
      return true;
    }).toList();
  }

  List<BatchData> get _filteredBatches => _applyFilters(
        _batches,
        query: _searchQuery,
        status: _statusFilter,
        species: _speciesFilter,
        days: _daysFilter,
      );

  void _resetAllFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _statusFilter = 'All';
      _speciesFilter = 'All';
      _daysFilter = 0;
    });
  }

  /// Opens the filter bottom sheet with staged selections; nothing is
  /// applied until the user confirms with the "Show ... batches" button.
  Future<void> _openFilterSheet() async {
    var status = _statusFilter;
    var species = _speciesFilter;
    var days = _daysFilter;

    final applied = await showModalBottomSheet<_FilterSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final int count = _applyFilters(
            _batches,
            query: _searchQuery,
            status: status,
            species: species,
            days: days,
          ).length;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle.
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderWarm,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Filter batches',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close filters',
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel(text: 'STATUS'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final option in const ['All', 'Active', 'Completed'])
                        _FilterChoiceChip(
                          label: option,
                          selected: status == option,
                          onTap: () =>
                              setSheetState(() => status = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel(text: 'SPECIES'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final option
                          in const ['All', 'Chicken', 'Duck', 'Quail'])
                        _FilterChoiceChip(
                          label: option,
                          selected: species == option,
                          onTap: () =>
                              setSheetState(() => species = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _SectionLabel(text: 'DATE'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _FilterChoiceChip(
                        label: 'Any time',
                        selected: days == 0,
                        onTap: () => setSheetState(() => days = 0),
                      ),
                      _FilterChoiceChip(
                        label: 'Last 7 days',
                        selected: days == 7,
                        onTap: () => setSheetState(() => days = 7),
                      ),
                      _FilterChoiceChip(
                        label: 'Last 30 days',
                        selected: days == 30,
                        onTap: () => setSheetState(() => days = 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Filters combine with your search.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => setSheetState(() {
                            status = 'All';
                            species = 'All';
                            days = 0;
                          }),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.borderWarm),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.control),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(
                              _FilterSelection(status, species, days),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  AppColors.primaryDark.withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.control),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Show $count ${count == 1 ? 'batch' : 'batches'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (applied != null && mounted) {
      setState(() {
        _statusFilter = applied.status;
        _speciesFilter = applied.species;
        _daysFilter = applied.days;
      });
    }
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
              style: TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
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
                        borderRadius:
                            BorderRadius.circular(AppRadius.control),
                        borderSide:
                            const BorderSide(color: AppColors.borderWarm),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.control),
                        borderSide:
                            const BorderSide(color: AppColors.borderWarm),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.control),
                        borderSide: const BorderSide(
                            color: AppColors.primaryDark, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 48x48 filter button with an accent dot while filters are
                // active; opens the filter bottom sheet.
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(AppRadius.control),
                  ),
                  // Border painted as foreground so it does not inset the
                  // tappable area: the InkWell keeps the full 48x48 target.
                  foregroundDecoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppRadius.control),
                    border: Border.all(
                      color: _hasFilters
                          ? AppColors.primaryDark
                          : AppColors.borderWarm,
                    ),
                  ),
                  child: Semantics(
                    button: true,
                    label: 'Filters',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openFilterSheet,
                        borderRadius:
                            BorderRadius.circular(AppRadius.control),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.tune,
                              size: 22,
                              color: _hasFilters
                                  ? AppColors.primaryDark
                                  : AppColors.textSecondary,
                            ),
                            if (_hasFilters)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryDark,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                      // A filtered-out result is a search miss, not an
                      // empty incubator.
                      _hasActiveQuery
                          ? Icons.search_off
                          : Icons.egg_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _hasActiveQuery
                          ? 'No batches match your search or filters'
                          : 'No batches yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasActiveQuery
                          ? 'Try changing your search or resetting the filters.'
                          : 'Start your first incubation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (_hasActiveQuery) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _resetAllFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined,
                            size: 18),
                        label: const Text('Reset filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(
                              color: AppColors.borderWarm),
                          minimumSize: const Size(48, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppRadius.control),
                          ),
                        ),
                      ),
                    ],
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
                    // Reloading on return keeps Active/Completed statuses
                    // and hatch results accurate after the details screen -
                    // including a batch finished from its details.
                    onOpenDetails: (b) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BatchDetailsScreen(batch: b),
                        ),
                      );
                      if (mounted) _loadBatches();
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

/// Staged selections coming back from the History filter sheet.
class _FilterSelection {
  const _FilterSelection(this.status, this.species, this.days);

  final String status;
  final String species;
  final int days;
}

/// Warm, touch-friendly (>=48px) choice chip for the filter sheet.
class _FilterChoiceChip extends StatelessWidget {
  const _FilterChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Container(
        // Guarantees the 48px accessibility touch minimum.
        constraints: const BoxConstraints(minHeight: 48),
        decoration: BoxDecoration(
          color: selected ? AppColors.peach : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        // Border painted as foreground so it does not inset the tappable
        // area: the InkWell keeps the full 48px touch target.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.control),
          border: Border.all(
            color: selected ? AppColors.primaryDark : AppColors.borderWarm,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: 13),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check,
                        size: 16, color: AppColors.primaryDark),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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

  /// The stored-session view of this batch: enough for the shared finish
  /// flow and the Active Incubation screen, assembled from what History
  /// already loaded.
  Map<String, dynamic> get _sessionRow => {
        'id': widget.batch.id,
        'egg_type': widget.batch.species,
        'start_date': widget.batch.startDate,
        'egg_quantity': widget.batch.eggsTotal,
        'status': widget.batch.status,
        'end_date': widget.batch.endDate,
        'eggs_hatched': widget.batch.eggsHatched,
      };

  /// The SAME validated completion flow as the Active Incubation screen
  /// (P6.4). On success the dialog performed the database update; popping
  /// back to History reloads it so the batch shows as Completed.
  Future<void> _finishFromDetails() async {
    final done = await showFinishBatchDialog(context, session: _sessionRow);
    if (done && mounted) Navigator.pop(context);
  }

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
              // Quail batch → quail illustration, etc.; species presets
              // without a preset (e.g. 'Goose') resolve to the same
              // fallback species the emoji path used before.
              child: SpeciesIllustration(
                species: speciesData.name,
                emoji: speciesData.emoji,
                size: 80,
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

            // ── ACTIVE BATCH ACTIONS (P6.4) ──
            // An incubating batch is opened or finished right here, through
            // the exact same validated flow as the Current Incubation
            // screen. A completed batch offers neither - results never
            // revert to incubating.
            if (!_isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => activeIncubationScreenFor(_sessionRow),
                      ),
                    );
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  label: const Text(
                    'View Current Incubation',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.borderWarm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _finishFromDetails,
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text(
                    'Finish Batch',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
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
                  // Hatch results only exist once the farmer finishes the
                  // batch - an incubating batch shows no fabricated counts.
                  if (_isCompleted) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                        label: 'Hatched', value: '${batch.eggsHatched}'),
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: 'Success Rate',
                      value: '${(hatchRate * 100).toStringAsFixed(0)}%',
                    ),
                  ],
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
              Row(
                children: [
                  // Brand mark: the SmartHatch logo on a soft peach badge
                  // (matches the onboarding branding; egg icon as fallback).
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Semantics(
                        image: true,
                        label: 'SmartHatch logo',
                        excludeSemantics: true,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: Image.asset(
                                'assets/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.egg_outlined,
                                  size: 20,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'SmartHatch',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Profile shortcut - a 48px target, labelled for screen readers.
        Semantics(
          button: true,
          label: 'Open profile',
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onProfileTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryDark.withValues(alpha: 0.16),
                  ),
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
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
    // IntrinsicHeight + stretch gives the three cards one shared height
    // (tidy aligned bottoms) without assuming a fixed height - stretch alone
    // is invalid inside the scroll view's unbounded height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(width: AppSpacing.md),
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
          const SizedBox(width: AppSpacing.md),
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
      ),
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
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.10),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warm icon badge keeps the accent friendly and on-brand.
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.peach,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(height: 12),
          // Scales long values (e.g. a species name) down instead of clipping
          // them on narrow screens.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.4,
              height: 1.3,
            ),
          ),
          if (supportingText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              supportingText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LastBatchCard extends StatelessWidget {
  final BatchData batch;

  /// Opens the full details of this batch. The whole card is tappable,
  /// including the "View Details" footer.
  final VoidCallback onTap;

  const _LastBatchCard({required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hatchRate = batch.eggsTotal > 0 ? batch.eggsHatched / batch.eggsTotal : 0.0;
    final percentage = '${(hatchRate * 100).round()}%';

    return Container(
      decoration: BoxDecoration(
        // Subtle cream highlight + warm hairline: noticeable, but clearly a
        // summary card - not an "active/incubating" status.
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.14),
        ),
        boxShadow: AppShadows.card,
      ),
      // The whole card is one navigation target: a farmer can tap anywhere -
      // including the "View Details" footer - to open the batch details.
      child: Semantics(
        button: true,
        label: 'View details for ${batch.batchNumber}',
        child: Material(
          // Transparent so the cream card below still shows through; the ink
          // splash then paints above it and gives visible tap feedback.
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Batch's species illustration; unknown species keep a
                      // generic egg mark in the same peach circle.
                      SpeciesIllustration(species: batch.species, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch.batchNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${batch.species.toUpperCase()} \u2022 ${batch.startDate}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
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
                          // Hatch percentage only - green here is a result
                          // figure, not a claim that the batch is running.
                          color: AppColors.success.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.badge),
                        ),
                        child: Text(
                          percentage,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: const Color(0x14000000)),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RESULT',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${batch.eggsHatched}/${batch.eggsTotal} hatched',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0x1F000000),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVG TEMP',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              batch.temperature,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Navigation affordance, styled like the History card's
                  // orange "View details" link with its chevron.
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
    // Illustration badge: ~64px artwork on an 84px peach circle on normal
    // phones, slightly smaller below 360px so the text column keeps room.
    final bool narrow = MediaQuery.of(context).size.width < 360;
    final double badgeSize = narrow ? 72 : 84;
    final double imageSize = narrow ? 52 : 64;
    // One tappable card per species: warm white surface, soft peach
    // illustration badge, ripple feedback and a screen-reader label naming
    // the species.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Semantics(
        button: true,
        label: 'Select $name',
        child: Material(
          // Transparent so the white card below still shows through; the ink
          // splash then paints above it and gives visible tap feedback.
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Local bird illustration on a soft-peach circle; a touch
                  // smaller on the narrowest phones so the text column keeps
                  // room. Falls back to the emoji if an asset cannot load.
                  SpeciesIllustration(
                    species: name,
                    emoji: emoji,
                    size: badgeSize,
                    artwork: imageSize,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Wraps onto a second run instead of overflowing on
                        // narrow screens - every chip stays visible.
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _InfoChip(
                              icon: Icons.calendar_today_rounded,
                              label: '$incubationDays days',
                              warm: true,
                            ),
                            _InfoChip(
                              icon: Icons.thermostat,
                              label: temperature,
                              warm: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  /// Opens the details for this batch. When provided (by History) it also
  /// reloads the list on return, so a batch finished from its details shows
  /// the saved result immediately. Falls back to a plain push otherwise.
  final Future<void> Function(BatchData batch)? onOpenDetails;

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
    this.onOpenDetails,
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
    // Worded status badge: green when the batch finished, amber while it is
    // still running (an in-progress batch is not an error, so no red).
    final bool completed = status.toLowerCase() == 'completed';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadows.card,
      ),
      child: Semantics(
        button: true,
        label: 'View details for $batchNumber',
        child: Material(
          // Transparent so the warm card surface shows through while the
          // ink ripple paints above it.
          color: Colors.transparent,
          child: InkWell(
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
              final open = onOpenDetails;
              if (open != null) {
                open(batch);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BatchDetailsScreen(batch: batch),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SpeciesIllustration(species: species, size: 44),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batchNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              species,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(
                        label: status,
                        color: completed
                            ? AppColors.success
                            : AppColors.warning,
                        icon: completed
                            ? Icons.check_circle_outline
                            : Icons.schedule,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // UI-01: a hatch result only exists once the farmer has
                  // finished the batch. While a batch is incubating the card
                  // says so plainly instead of implying a finished 0% result.
                  if (completed)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$eggsHatched / $eggsTotal eggs hatched',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Hatch rate is a result figure, so it keeps the green
                        // pill treatment from the Home last-batch card.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            percentage,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Incubation in progress \u00B7 $eggsTotal eggs',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatDate(startDate),
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'View details',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Worded status pill for a history card (no bare colour-only status).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

  /// Optional widget shown just before the value (e.g. a small species
  /// illustration); every other row keeps the plain text value.
  final Widget? leading;

  const _DetailRow({required this.label, required this.value, this.leading});

  @override
  Widget build(BuildContext context) {
    final Widget valueText = Text(
      value,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        if (leading == null)
          valueText
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading!,
              const SizedBox(width: 6),
              valueText,
            ],
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
  double _simulatedBroodTemp = 31.0;
  double _simulatedBroodHumidity = 50.0;

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
    return stage == 'ACTIVE INCUBATION' ? 'ACTIVE PHASE' : stage;
  }

  /// Mirrors live Arduino telemetry into the controller. While an Arduino is
  /// connected the hardware owns the relays (manual commands win); otherwise
  /// the local simulator keeps driving the controller exactly as before.
  void _syncFromArduino() {
    final connected = _arduino.isConnected;
    _controller.externalControl = connected;
    if (connected && _arduino.isLive) {
      // Live telemetry: mirror real readings and reported relay states.
      _controller.updateSensors(
        incTemp: _arduino.incubatorTemperature,
        incHumidity: _arduino.incubatorHumidity,
        broodTemp: _arduino.brooderTemperature,
        broodHumidity: _arduino.brooderHumidity,
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
      // Connected but no fresh frame yet: never show simulated readings as live.
      _controller.updateSensors();
    } else if (!connected) {
      // Simulator owns the readings while no Arduino is attached.
      _controller.updateSensors(
        incTemp: _simulatedIncTemp,
        incHumidity: _simulatedIncHumidity,
        broodTemp: _simulatedBroodTemp,
        broodHumidity: _simulatedBroodHumidity,
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
                // Flexible + ellipsis: the title never overflows the bar on
                // narrow phones, whatever actions sit beside it.
                const Flexible(
                  child: Text(
                    'Hardware Console',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            actions: [
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
                _ArduinoConnectionCard(controller: _arduino),
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

                // 1. STAGE & BATCH BANNER
                _buildBatchHeaderCard(currentDay, profile, isLockdown, hours, minutes, seconds),
                const SizedBox(height: 16),

                // 2. INCUBATOR CHAMBER
                _buildIncubatorChamberCard(),
                const SizedBox(height: 16),

                // 3. BROODER CHAMBER
                _buildBrooderChamberCard(),
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
    final start = DateTime.tryParse('${row['start_date']}');
    final elapsed =
        start == null ? 0 : DateTime.now().difference(start).inDays;
    final day = (elapsed + 1).clamp(1, species.incubationDays).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.primaryDark.withValues(alpha: 0.25)),
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
                        'INCUBATING NOW \u00B7 Batch #$id \u00B7 '
                        '${species.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Day $day of ${species.incubationDays} '
                        '\u00B7 real saved batch',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
              'No real batch incubating. The progress shown on this '
              'screen is a SIMULATION.',
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
                  _controller.startNewBatch(p);
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
                      '${p.hatchDay} Days',
                      style: TextStyle(
                        fontSize: 11,
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
          // SIMULATION chips (P6.4): this whole card is the local simulator,
          // so every label here is explicitly simulated - never a real batch.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Profile: ${profile.speciesName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _simStageLabel,
                  style: TextStyle(
                    color: isLockdown
                        ? const Color(0xFFC9302C)
                        : const Color(0xFFE8752A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: currentDay / profile.hatchDay,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Elapsed: ${hours}h ${minutes}m ${seconds}s',
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
                      ? 'Lockdown Active (Turning Halted)'
                      : 'Lockdown starts on Day ${profile.lockdownStartDay}',
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
                name: 'Egg Turner: '
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
          _EggTurningStatus(controller: _arduino),
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
                status: _arduino.commandStatus('brooderBulb'),
                onTap: () => _toggleActuator('brooderBulb'),
              ),
              _buildRelayChip(
                name: 'Brooder Humidifier (D5)',
                isOn: _controller.brooderHumidifierState,
                activeColor: Colors.cyan,
                icon: Icons.cloud_outlined,
                status: _arduino.commandStatus('brooderHumidifier'),
                onTap: () => _toggleActuator('brooderHumidifier'),
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
    ActuatorCommandStatus status = ActuatorCommandStatus.idle,
    VoidCallback? onTap,
  }) {
    final pending = status == ActuatorCommandStatus.pending;
    final failed = status == ActuatorCommandStatus.failed ||
        status == ActuatorCommandStatus.rejected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isOn ? activeColor.withValues(alpha: 0.12) : Colors.grey.shade100,
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
        border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.25)),
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
                  'Live Arduino Telemetry',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _arduino.isLive
                      ? 'Connected to ${_arduino.portName ?? "serial port"}. Readings and relay states come from the hardware; the simulator is paused.'
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulator Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preview a species\' programmed incubation profile '
              '(temperatures, stages, humidity, and lockdown day). This '
              'changes the simulator only - never the real batch or the '
              'hardware:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            ...IncubationProfile.allProfiles.map((p) {
              final isCurrent = _controller.profile.speciesName == p.speciesName;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFE8752A).withValues(alpha: 0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFFE8752A) : Colors.grey.shade300,
                  ),
                ),
                child: Material(
                  // Local material so the ListTile paints its own background
                  // and ink feedback instead of it being hidden by this
                  // decorated container.
                  color: Colors.transparent,
                  child: ListTile(
                    title: Text(
                      '${p.speciesName} Eggs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? const Color(0xFFE8752A) : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Total: ${p.hatchDay} days | Lockdown: Day ${p.lockdownStartDay}\nActive RH: ${p.activeHumidityLow.toInt()}-${p.activeHumidityHigh.toInt()}% | Lockdown RH: ${p.lockdownHumidityLow.toInt()}-${p.lockdownHumidityHigh.toInt()}%',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle, color: Color(0xFFE8752A))
                        : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      _controller.startNewBatch(p);
                      _onSensorChanged();
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Connection panel shared by the incubation screen and hardware console.
class _ArduinoConnectionCard extends StatefulWidget {
  const _ArduinoConnectionCard({required this.controller});

  final ArduinoController controller;

  @override
  State<_ArduinoConnectionCard> createState() => _ArduinoConnectionCardState();
}

class _ArduinoConnectionCardState extends State<_ArduinoConnectionCard> {
  ArduinoController get _arduino => widget.controller;
  String? _selectedPort;

  @override
  void initState() {
    super.initState();
    _arduino.addListener(_onChanged);
    _arduino.refreshPorts();
  }

  @override
  void dispose() {
    _arduino.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    final port = _selectedPort ??
        (_arduino.ports.isNotEmpty ? _arduino.ports.first : null);
    if (port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No serial port selected.')),
      );
      return;
    }
    try {
      await _arduino.connect(port);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not connect: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = _arduino.isConnected;
    final connecting = _arduino.isConnecting;
    final ports = _arduino.ports;
    if (_selectedPort == null && ports.isNotEmpty) {
      _selectedPort = ports.first;
    }
    final statusColor = connected
        ? const Color(0xFF4CAF50)
        : (connecting ? const Color(0xFFFF9800) : Colors.grey.shade500);
    final statusText = connected
        ? 'Connected${_arduino.portName != null ? ' • ${_arduino.portName}' : ''}'
        : (connecting ? 'Connecting…' : 'Disconnected');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.usb, color: statusColor, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Arduino Connection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!connected) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: ports.contains(_selectedPort) ? _selectedPort : null,
                        hint: const Text('Select serial port'),
                        items: ports
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: connecting
                            ? null
                            : (v) => setState(() => _selectedPort = v),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Refresh ports',
                  onPressed: connecting ? null : () => _arduino.refreshPorts(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (ports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'No serial ports found. Plug in the Arduino over USB.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: connecting ? null : _connect,
                icon: connecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link),
                label: Text(connecting ? 'Connecting…' : 'Connect'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752A),
                ),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _arduino.disconnect(),
                icon: const Icon(Icons.link_off),
                label: const Text('Disconnect'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE8752A),
                  side: const BorderSide(color: Color(0xFFE8752A)),
                ),
              ),
            ),
          ],
          if (_arduino.lastError != null) ...[
            const SizedBox(height: 10),
            Text(
              _arduino.lastError!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder shown where a live-reading widget would appear while offline.
class _ArduinoPlaceholderCard extends StatelessWidget {
  const _ArduinoPlaceholderCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ── Egg turning progress helpers ──

/// Formats the time until the next automatic turn (e.g. "1 h 12 m").
String _nextTurnInText(ArduinoController controller) {
  final reading = controller.telemetry;
  if (reading == null) return 'soon';
  final remaining =
      reading.turnIntervalMinutes * 60 - (reading.secondsSinceLastTurn ?? 0);
  if (remaining <= 0) return 'now';
  final h = remaining ~/ 3600;
  final m = (remaining % 3600) ~/ 60;
  if (h > 0) return m > 0 ? '$h h $m m' : '$h h';
  return m > 0 ? '$m m' : 'less than a minute';
}

/// Short progress text for the egg turner, e.g. "3 of 6 turns done today ·
/// next in 1 h 12 m". Display-only: turning is always automatic.
String _eggTurningDetail(ArduinoController controller) {
  if (!controller.isConnected) return 'Offline — connect the Arduino';
  if (!controller.isLive) return 'Waiting for telemetry…';
  if (!controller.turningActive) return 'Turning disabled — no auto turns';
  final done = controller.turnsToday ?? 0;
  final planned = controller.scheduledTurnsPerDay;
  return '$done of $planned turns done today · next in ${_nextTurnInText(controller)}';
}

/// Compact egg-turning status row (used on Home, the console and incubation).
class _EggTurningStatus extends StatelessWidget {
  const _EggTurningStatus({required this.controller});

  final ArduinoController controller;

  @override
  Widget build(BuildContext context) {
    final String detail;
    final Color color;
    if (!controller.isConnected) {
      detail = 'Egg turning: offline';
      color = AppColors.textSecondary;
    } else if (!controller.isLive) {
      detail = 'Egg turning: waiting for telemetry…';
      color = AppColors.warning;
    } else if (!controller.turningActive) {
      detail = 'Egg turning: disabled — no auto turns';
      color = AppColors.textSecondary;
    } else {
      detail = 'Egg turning: ${_eggTurningDetail(controller)}';
      color = AppColors.success;
    }
    return Row(
      children: [
        Icon(Icons.sync, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            detail,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Live incubator status panel for the Home dashboard. Shows real readings
/// only when the Arduino is connected; otherwise a clear offline message and a
/// shortcut to the hardware console.
class _LiveIncubatorStatusCard extends StatelessWidget {
  const _LiveIncubatorStatusCard({required this.controller});

  final ArduinoController controller;

  void _openConsole(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const IncubatorDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final connected = controller.isConnected;
        final live = controller.isLive;

        if (!connected) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Soft peach marks "needs attention" without looking like an
              // error - the hardware simply is not plugged in yet.
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.primaryDark.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.usb_off,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live Incubator Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // The state in words as well as colour, so it is clear
                    // to everyone.
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.badge),
                      ),
                      child: const Text(
                        'NOT CONNECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect the Arduino to see live temperature, humidity and egg-turning status here on the Home tab.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openConsole(context),
                    icon: const Icon(Icons.developer_board, size: 18),
                    label: const Text('Open Hardware Console'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!live) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.usb,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Live Incubator Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.badge),
                      ),
                      child: const Text(
                        'CONNECTING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Connected to ${controller.portName ?? 'Arduino'} — waiting for the first telemetry frame…',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => _openConsole(context),
                    icon: const Icon(Icons.developer_board, size: 18),
                    label: const Text('Open Hardware Console'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      side: const BorderSide(color: AppColors.primaryDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Live data available.
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.monitor_heart_outlined,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Live Incubator Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _LiveMetricTile(
                      icon: Icons.thermostat_rounded,
                      label: 'Incubator Temp',
                      value: controller.incubatorTemperature != null
                          ? '${controller.incubatorTemperature!.toStringAsFixed(1)} °C'
                          : '—',
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LiveMetricTile(
                      icon: Icons.water_drop_rounded,
                      label: 'Incubator Humidity',
                      value: controller.incubatorHumidity != null
                          ? '${controller.incubatorHumidity!.toStringAsFixed(0)} %'
                          : '—',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _LiveMetricTile(
                      icon: Icons.thermostat_outlined,
                      label: 'Brooder Temp',
                      value: controller.brooderTemperature != null
                          ? '${controller.brooderTemperature!.toStringAsFixed(1)} °C'
                          : '—',
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LiveMetricTile(
                      icon: Icons.water_drop_outlined,
                      label: 'Brooder Humidity',
                      value: controller.brooderHumidity != null
                          ? '${controller.brooderHumidity!.toStringAsFixed(0)} %'
                          : '—',
                      color: Colors.cyan,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0x14000000)),
              _EggTurningStatus(controller: controller),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _openConsole(context),
                  icon: const Icon(Icons.developer_board, size: 18),
                  label: const Text('Open Hardware Console'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primaryDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveMetricTile extends StatelessWidget {
  const _LiveMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: const Color(0x0F000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
