import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/screens/history/history_screen.dart';
import 'package:egg_incubator_app/screens/home/home_screen.dart';
import 'package:egg_incubator_app/screens/species/species_screen.dart';
import '../models/farmer_notice.dart';

// ══════════════════════════════════════════════
// BOTTOM NAVIGATION HOST
// ══════════════════════════════════════════════

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key, this.notice});
  final FarmerNotice? notice;

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
  final Set<int> _visited = {0};

  late final List<Widget> _screens = [
    HomeScreen(notice: widget.notice),
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
      _visited.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_screens.length, (index) {
          return _visited.contains(index)
              ? TabShell(active: index == _currentIndex, child: _screens[index])
              : const SizedBox.shrink();
        }),
      ),
      bottomNavigationBar: MainBottomBar(
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
class MainBottomBar extends StatelessWidget {
  const MainBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

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
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
              states,
            ) {
              final bool selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.primaryDark
                    : AppColors.navigationInactive,
              );
            }),
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
                selectedIcon: Icon(Icons.history, color: AppColors.primaryDark),
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
class TabShell extends InheritedWidget {
  const TabShell({super.key, this.active = true, required super.child});

  final bool active;

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabShell>()?.active ?? true;

  /// True when [context] belongs to a screen rendered inside the shell.
  static bool isTab(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabShell>() != null;

  @override
  bool updateShouldNotify(TabShell oldWidget) => active != oldWidget.active;
}
