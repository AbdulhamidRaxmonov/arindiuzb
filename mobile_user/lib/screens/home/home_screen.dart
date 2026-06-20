import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/category.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import '../application/pochoq_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<WasteCategory> _categories = const [];
  bool _loading = true;

  static const _meta = {
    'pochoq': (Icons.egg_outlined, Color(0xFFF59E0B)),
    'botilka': (Icons.local_drink_outlined, Color(0xFF3B82F6)),
    'plasmassa': (Icons.recycling_outlined, Color(0xFF8B5CF6)),
    'maklatura': (Icons.menu_book_outlined, Color(0xFF10B981)),
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final cats = await CategoryService.list();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // Fallback to a static list so the grid still renders offline.
      setState(() => _categories = [
            WasteCategory(key: 'pochoq', label: "Po'choq", active: true),
            WasteCategory(key: 'botilka', label: "Bo'tilka", active: false),
            WasteCategory(key: 'plasmassa', label: 'Plasmassa', active: false),
            WasteCategory(key: 'maklatura', label: 'Maklatura', active: false),
          ]);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onTap(WasteCategory c) {
    final t = AppLocalizations.of(context);
    if (!c.active) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.construction, color: AppTheme.primary, size: 40),
          title: Text(t.t(c.key)),
          content: Text(t.t('coming_soon')),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PochoqFormScreen(category: c)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AppState>().user;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assalomu alaykum,',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        Text(
                          user?.name ?? user?.phone ?? '',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.recycling, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _BalanceBanner(balance: user?.balance ?? 0),
              const SizedBox(height: 24),
              Text(
                t.t('choose_category'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                  children: _categories.map((c) {
                    final meta = _meta[c.key] ?? (Icons.recycling, AppTheme.primary);
                    return _CategoryCard(
                      label: t.t(c.key),
                      icon: meta.$1,
                      color: meta.$2,
                      active: c.active,
                      onTap: () => _onTap(c),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  final double balance;
  const _BalanceBanner({required this.balance});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.t('balance'),
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Text(
                '${formatMoney(balance)} ${t.t('sum')}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.account_balance_wallet,
              color: Colors.white, size: 40),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: RoundedCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(active ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: active ? color : Colors.grey, size: 30),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: active ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(active ? Icons.check_circle : Icons.lock_clock,
                    size: 14, color: active ? AppTheme.primary : Colors.grey),
                const SizedBox(width: 4),
                Text(
                  active ? 'Faol' : 'Tez orada',
                  style: TextStyle(
                      fontSize: 12,
                      color: active ? AppTheme.primary : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
