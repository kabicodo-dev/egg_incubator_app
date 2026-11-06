import 'package:flutter/material.dart';
import '../models/farmer_notice.dart';
import '../widgets/common/farmer_notice_card.dart';
import 'package:egg_incubator_app/services/supabase_service.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

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
/// previews hatchability live and shows a confirmation summary. Completion is
/// a saved-record action, not physical Stop. One UPDATE is followed by readback;
/// success is reported only when the stored result matches the manual entry.
class _FinishBatchDialog extends StatefulWidget {
  const _FinishBatchDialog({required this.session});

  /// The raw Supabase row of the batch being finished.
  final Map<String, dynamic> session;

  @override
  State<_FinishBatchDialog> createState() => _FinishBatchDialogState();
}

class _FinishBatchDialogState extends State<_FinishBatchDialog> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _saving = false;
  String? _error;

  // Existing schema's egg_quantity is the original eggs-set denominator.
  int get _quantity {
    final value = widget.session['egg_quantity'];
    return value is int ? value : 0;
  }

  String get _batchNumber => 'Batch #${widget.session['id']}';
  String get _species => (widget.session['egg_type'] as String?) ?? 'Eggs';

  int? get _entered {
    final input = _controller.text.trim();
    return RegExp(r'^[0-9]+$').hasMatch(input) ? int.tryParse(input) : null;
  }

  /// A count is valid only as a whole number from 0 through the original
  /// egg quantity, inclusive.
  bool get _valid {
    final v = _entered;
    return _quantity > 0 && v != null && v >= 0 && v <= _quantity;
  }

  /// Live hatch-success preview for the entered count (null while invalid).
  double? get _hatchRate {
    if (!_valid) return null;
    return _entered! / _quantity;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
      final id = widget.session['id'] as int;
      final original = await SupabaseService().getSessionById(id);
      if (original == null ||
          original['egg_quantity'] != _quantity ||
          original['status'] != 'Active') {
        throw StateError('Original batch no longer matches the form');
      }
      await SupabaseService().completeSession(
        sessionId: id,
        endDate: DateTime.now(),
        eggsHatched: count,
      );
      // A successful HTTP response alone may have updated zero visible rows.
      final saved = await SupabaseService().getSessionById(id);
      if (saved == null ||
          saved['id'] != id ||
          saved['status'] != 'Completed' ||
          saved['eggs_hatched'] != count ||
          saved['egg_quantity'] != _quantity ||
          DateTime.tryParse('${saved['end_date']}') == null) {
        throw StateError('Completion save has not been confirmed');
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // A failed response/readback does not establish the saved or physical state.
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'Check $_batchNumber in History before trying again. The results may already have been saved.';
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
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
      constraints: const BoxConstraints(maxWidth: 520),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: const Text('Finish batch record?'),
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              FarmerNoticeCard(
                notice: FarmerNotice(
                  title: 'Save not confirmed',
                  message: _error!,
                  tone: FarmerNoticeTone.error,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '$_batchNumber · $_species · $_quantity eggs$startLabel',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text('Eggs set: $_quantity'),
            if (_quantity <= 0)
              const Text(
                'Original eggs set is missing or invalid. '
                'Completion is blocked; verify the saved batch.',
                style: TextStyle(color: AppColors.danger),
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
              enabled: !_saving && _quantity > 0,
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
                    ? 'Enter the hatched count to preview hatchability.'
                    : 'Hatchability: ${(rate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: rate == null
                      ? AppColors.textSecondary
                      : AppColors.primaryDark,
                ),
              ),
            ),
            if (_valid) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  border: Border.all(color: AppColors.borderWarm),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Confirmation summary',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text('$_batchNumber · $_species'),
                    Text('Eggs set: $_quantity; manually hatched: $_entered'),
                    Text(
                      'Hatchability: ($_entered / $_quantity) × 100 = '
                      '${(rate! * 100).toStringAsFixed(1)}%',
                    ),
                    const Text(
                      'Review this summary, then select Finish Batch to save.',
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Enter how many eggs hatched. Saving closes the batch record; '
              'it does not switch off the incubator.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
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
