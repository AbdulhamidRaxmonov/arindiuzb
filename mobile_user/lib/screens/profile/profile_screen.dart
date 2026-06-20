import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../widgets/helpers.dart';
import 'balance_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('profile'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppTheme.primary,
                child: Icon(Icons.person, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '—',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold)),
                    Text(user?.phone ?? '',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Balance card -> tap to open balance/withdraw screen
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BalanceScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
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
                      Text('${formatMoney(user?.balance ?? 0)} ${t.t('sum')}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings list
          RoundedCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: t.t('balance'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BalanceScreen()),
                  ),
                ),
                const Divider(height: 1),
                _LanguageTile(),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(t.t('dark_mode')),
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (v) => state.toggleDarkMode(v),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.info_outline,
                  title: t.t('about'),
                  onTap: () => showAboutDialogSheet(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, state),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: Text(t.t('logout'), style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void showAboutDialogSheet(BuildContext context) {
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.recycling, size: 56, color: AppTheme.primary),
            const SizedBox(height: 12),
            const Text('Arindi v1.0.0',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(t.t('about_text'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState state) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.t('logout')),
        content: const Text('Hisobdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.t('cancel'))),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              state.logout();
            },
            child: Text(t.t('logout')),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _SettingTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}

class _LanguageTile extends StatelessWidget {
  static const _langs = {'uz': 'O\'zbekcha', 'ru': 'Русский', 'en': 'English'};

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(t.t('language')),
      trailing: DropdownButton<String>(
        value: state.locale.languageCode,
        underline: const SizedBox(),
        items: _langs.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) {
          if (v != null) state.setLocale(v);
        },
      ),
    );
  }
}
