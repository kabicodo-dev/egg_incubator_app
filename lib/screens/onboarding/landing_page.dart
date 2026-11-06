import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';

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
              minHeight:
                  MediaQuery.of(context).size.height -
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
                                    color: const Color(
                                      0xFFE8752A,
                                    ).withValues(alpha: 0.1),
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
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          slide.icon,
                                                          size: 56,
                                                          color: const Color(
                                                            0xFFE8752A,
                                                          ),
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
                                    final double fontSize =
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(style.fontSize!);
                                    final painter = TextPainter(
                                      text: TextSpan(
                                        text: slide.title,
                                        style: style.copyWith(
                                          fontSize: fontSize,
                                        ),
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
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentPage < _slides.length - 1
                                ? 'Next'
                                : 'Get Started',
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
