import 'package:flutter/material.dart';
import 'package:egg_incubator_app/theme/app_theme.dart';

/// Fictional, memory-only administration UI. Not an authorization boundary.
/// Never connect these fixtures or callbacks to production data.
class AdminPreviewScreen extends StatefulWidget {
  const AdminPreviewScreen({super.key});

  @override
  State<AdminPreviewScreen> createState() => _AdminPreviewScreenState();
}

class _AdminPreviewScreenState extends State<AdminPreviewScreen> {
  int _tab = 0;
  String? _assignedUser;
  String _query = '';
  String? _feedback;
  final List<String> _events = [];
  static const _users = ['Demo Farmer A', 'Demo Farmer B'];

  Future<void> _changeAccess(String? user) async {
    final removing = user == null;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(removing ? 'Remove demo access?' : 'Assign demo records?'),
        content: Text(
          removing
              ? 'Remove $_assignedUser’s access to Demo Batch A? The fictional '
                    'records will not be deleted. No real permissions change.'
              : 'Link Demo Batch A to $user in this preview only? '
                    'This does not register a batch or start the incubator.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(removing ? 'Remove demo access' : 'Assign in preview'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    setState(() {
      final event = removing
          ? 'Demo admin removed $_assignedUser’s access to Demo Batch A.'
          : 'Demo admin assigned Demo Batch A to $user.';
      _assignedUser = user;
      _events.insert(0, event);
      _feedback = '$event Preview only — nothing was saved to Supabase.';
    });
  }

  Widget _card(Widget child) => Card(
    color: AppColors.card,
    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.borderWarm),
    ),
    child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: child),
  );

  Widget _notice(String text, {IconData icon = Icons.info_outline}) => _card(
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SmartHatch · Admin preview')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _notice(
                'Demo only • Fictional users and records. Changes stay in memory '
                'and reset when this preview restarts. No login, database or '
                'hardware connection.',
              ),
              if (_feedback != null) _notice(_feedback!),
              Text(
                ['Registered users', 'Record access', 'Demo activity'][_tab],
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_tab == 0) ...[
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search demo users',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!_users.any(
                  (user) => user.toLowerCase().contains(_query.toLowerCase()),
                ))
                  const Text('No demo users match your search.'),
                for (final user in _users)
                  if (user.toLowerCase().contains(_query.toLowerCase()))
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text('Email verified — fictional demo status'),
                          Text(
                            _assignedUser == user
                                ? 'Assigned: Demo Batch A'
                                : 'No records assigned',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton.icon(
                            onPressed: () => setState(() => _tab = 1),
                            icon: const Icon(Icons.folder_shared_outlined),
                            label: const Text('Review record access'),
                          ),
                        ],
                      ),
                    ),
              ],
              if (_tab == 1)
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Demo Batch A',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text(
                        'Fictional record • Not the running incubation',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Assigned account: ${_assignedUser ?? 'None'}'),
                      const SizedBox(height: AppSpacing.lg),
                      if (_assignedUser == null) ...[
                        const Text(
                          'Choose a demo farmer to preview assignment.',
                        ),
                        for (final user in _users)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: OutlinedButton(
                              onPressed: () => _changeAccess(user),
                              child: Text('Assign to $user'),
                            ),
                          ),
                      ] else ...[
                        const Text(
                          'Existing access must be reviewed before a different '
                          'account is assigned. Removing access does not delete records.',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                          ),
                          onPressed: () => _changeAccess(null),
                          icon: const Icon(Icons.person_remove_outlined),
                          label: const Text('Remove demo access'),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_tab == 2) ...[
                const Text(
                  'Session-only demo activity, not a durable backend audit log.',
                ),
                const SizedBox(height: AppSpacing.md),
                if (_events.isEmpty) _notice('No demo changes yet.'),
                for (final event in _events)
                  _notice(event, icon: Icons.history),
              ],
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (value) => setState(() {
        _tab = value;
        _feedback = null;
      }),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.people_outline), label: 'Users'),
        NavigationDestination(
          icon: Icon(Icons.folder_shared_outlined),
          label: 'Access',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
      ],
    ),
  );
}
