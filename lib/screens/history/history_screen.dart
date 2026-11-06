import 'package:flutter/material.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';
import 'package:egg_incubator_app/models/batch_data.dart';
import 'package:egg_incubator_app/navigation/main_navigation.dart';
import 'package:egg_incubator_app/screens/history/batch_details_screen.dart';
import 'package:egg_incubator_app/utils/hatchability.dart';
import 'package:egg_incubator_app/widgets/common/section_label.dart';
import 'package:egg_incubator_app/widgets/species_illustration.dart';
import '../../models/farmer_notice.dart';
import '../../widgets/common/farmer_notice_card.dart';

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
  final _scrollController = ScrollController();
  String _searchQuery = '';
  List<BatchData> _batches = [];
  bool _loading = true;
  bool _tabActive = true;
  bool _loadFailed = false;
  FarmerNotice? _savedNotice;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TabShell.isActive(context);
    if (active && !_tabActive) _loadBatches();
    _tabActive = active;
  }

  // Local-only filters - purely in-memory views over the loaded batches;
  // stored records are never changed, deleted, or overwritten.
  String _statusFilter = 'All'; // All | Active | Completed
  String _speciesFilter = 'All'; // All | Chicken | Duck | Quail
  int _daysFilter = 0; // 0 = any time, otherwise a "last N days" cutoff

  bool get _hasFilters =>
      _statusFilter != 'All' || _speciesFilter != 'All' || _daysFilter != 0;

  bool get _hasActiveQuery => _searchQuery.isNotEmpty || _hasFilters;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBatches() async {
    try {
      final sessions = await SupabaseService().getSessions();
      if (mounted) {
        setState(() {
          _batches = sessions.map((s) => BatchData.fromSession(s)).toList();
          _loading = false;
          _loadFailed = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadFailed = true;
        });
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
    final cutoff = days == 0
        ? null
        : DateTime.now().subtract(Duration(days: days));
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
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
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
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel(text: 'STATUS'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final option in const ['All', 'Active', 'Completed'])
                        _FilterChoiceChip(
                          label: option,
                          selected: status == option,
                          onTap: () => setSheetState(() => status = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel(text: 'SPECIES'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final option in const [
                        'All',
                        'Chicken',
                        'Duck',
                        'Quail',
                      ])
                        _FilterChoiceChip(
                          label: option,
                          selected: species == option,
                          onTap: () => setSheetState(() => species = option),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionLabel(text: 'DATE'),
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
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
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
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
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
                            onPressed: () => Navigator.of(
                              sheetContext,
                            ).pop(_FilterSelection(status, species, days)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.primaryDark
                                  .withValues(alpha: 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.control,
                                ),
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
        automaticallyImplyLeading: !TabShell.isTab(context),
      ),
      // Opened as a route the shell's bottom bar is not around, so render it
      // here too: Home, Species and History stay one tap away (issue #14).
      // As a tab the shell already provides it.
      bottomNavigationBar: TabShell.isTab(context)
          ? null
          : MainBottomBar(
              selectedIndex: 2,
              onSelected: (index) {
                if (index == 2) return; // already showing History
                MainNavigation.openTab(context, index);
              },
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_savedNotice != null) ...[
                    FarmerNoticeCard(notice: _savedNotice!),
                    const SizedBox(height: 16),
                  ],
                  if (_loadFailed) ...[
                    const FarmerNoticeCard(
                      notice: FarmerNotice(
                        title: 'History could not be loaded',
                        message:
                            'Saved batches could not be retrieved. Check your internet connection and reopen History. Existing records have not been changed.',
                        tone: FarmerNoticeTone.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    'View and search your previous batches.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
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
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.borderWarm,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.borderWarm,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primaryDark,
                                width: 1.5,
                              ),
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
                          borderRadius: BorderRadius.circular(
                            AppRadius.control,
                          ),
                        ),
                        // Border painted as foreground so it does not inset the
                        // tappable area: the InkWell keeps the full 48x48 target.
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppRadius.control,
                          ),
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
                              borderRadius: BorderRadius.circular(
                                AppRadius.control,
                              ),
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
                  else if (batches.isEmpty && !_loadFailed) ...[
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
                              icon: const Icon(
                                Icons.filter_alt_off_outlined,
                                size: 18,
                              ),
                              label: const Text('Reset filters'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryDark,
                                side: const BorderSide(
                                  color: AppColors.borderWarm,
                                ),
                                minimumSize: const Size(48, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.control,
                                  ),
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
                          hasRecordedHatchCount: batch.hasRecordedHatchCount,
                          temperature: batch.temperature,
                          status: batch.status,
                          isSuccess: batch.isSuccess,
                          initiallyExpanded: batch.id == batches.first.id,
                          // Reloading on return keeps Active/Completed statuses
                          // and hatch results accurate after the details screen -
                          // including a batch finished from its details.
                          onOpenDetails: (b) async {
                            final saved = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BatchDetailsScreen(batch: b),
                              ),
                            );
                            if (mounted) {
                              if (saved == true) {
                                setState(
                                  () => _savedNotice = FarmerNotice(
                                    title: 'Hatch results saved',
                                    message:
                                        '${b.batchNumber} completed. Hatch results saved in History.',
                                    tone: FarmerNoticeTone.success,
                                  ),
                                );
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (mounted && _scrollController.hasClients) {
                                    _scrollController.jumpTo(0);
                                  }
                                });
                              }
                              _loadBatches();
                            }
                          },
                        ),
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
                horizontal: AppSpacing.lg,
                vertical: 13,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

class _HistoryBatchCard extends StatelessWidget {
  final bool initiallyExpanded;
  final int id;
  final String batchNumber;
  final String species;
  final String startDate;
  final String endDate;
  final int eggsTotal;
  final int eggsHatched;
  final bool hasRecordedHatchCount;
  final String temperature;
  final String status;
  final bool isSuccess;

  /// Opens the details for this batch. When provided (by History) it also
  /// reloads the list on return, so a batch finished from its details shows
  /// the saved result immediately. Falls back to a plain push otherwise.
  final Future<void> Function(BatchData batch)? onOpenDetails;

  const _HistoryBatchCard({
    this.initiallyExpanded = false,
    required this.id,
    required this.batchNumber,
    required this.species,
    required this.startDate,
    required this.endDate,
    required this.eggsTotal,
    required this.eggsHatched,
    required this.hasRecordedHatchCount,
    required this.temperature,
    required this.status,
    required this.isSuccess,
    this.onOpenDetails,
  });

  void _openDetails(BuildContext context) {
    final batch = BatchData(
      id: id,
      batchNumber: batchNumber,
      species: species,
      startDate: startDate,
      endDate: endDate,
      eggsTotal: eggsTotal,
      eggsHatched: eggsHatched,
      hasRecordedHatchCount: hasRecordedHatchCount,
      temperature: temperature,
      status: status,
      isSuccess: isSuccess,
    );
    final open = onOpenDetails;
    if (open != null) {
      open(batch);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BatchDetailsScreen(batch: batch)),
      );
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Unavailable';
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;
    const months = [
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
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (month == null ||
        day == null ||
        month < 1 ||
        month > 12 ||
        day < 1 ||
        day > 31) {
      return dateStr;
    }
    return '${months[month]} $day, ${parts[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = historicalHatchability(
      eggsTotal,
      eggsHatched,
      hasRecordedHatchCount,
    );
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
      child: Material(
        // Transparent so the warm card surface shows through while the
        // ink ripple paints above it.
        color: Colors.transparent,
        child: ExpansionTile(
          key: PageStorageKey('history-batch-$id'),
          initiallyExpanded: initiallyExpanded,
          shape: const Border(),
          collapsedShape: const Border(),
          iconColor: AppColors.primaryDark,
          title: Row(
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
                      '$species · ${_formatDate(startDate)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.borderWarm),
                  const SizedBox(height: AppSpacing.md),
                  // UI-01: a hatch result only exists once the farmer has
                  // finished the batch. While a batch is incubating the card
                  // says so plainly instead of implying a finished 0% result.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final result = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hatch result',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (completed)
                            Text(
                              hasRecordedHatchCount
                                  ? '$eggsHatched / $eggsTotal eggs hatched'
                                  : 'Hatched count unavailable',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          else
                            Text(
                              'Batch open · $eggsTotal eggs set',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (completed)
                            Text(
                              'Hatchability: $percentage',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    percentage != 'Unavailable' &&
                                        eggsHatched > 0
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      );
                      final record = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Batch record',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            completed ? 'Completed' : 'Open',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: completed
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          Text(
                            completed
                                ? _formatDate(endDate)
                                : 'Hatch results not recorded',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                      return constraints.maxWidth < 300 ||
                              MediaQuery.textScalerOf(context).scale(14) > 21
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                result,
                                const SizedBox(height: 16),
                                record,
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: result),
                                const SizedBox(width: 20),
                                Expanded(child: record),
                              ],
                            );
                    },
                  ),
                  const Divider(height: 32, color: AppColors.borderWarm),
                  Text(
                    'Eggs set: ${eggsTotal > 0 ? eggsTotal : 'Unavailable'}',
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
                          'Saved start: ${_formatDate(startDate)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (completed) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Completed: ${_formatDate(endDate)}'),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => _openDetails(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(48, 48),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Flexible(
                          child: Text(
                            'View details',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
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
