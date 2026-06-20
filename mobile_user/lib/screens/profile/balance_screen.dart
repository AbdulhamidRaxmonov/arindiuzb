import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/withdrawal.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import '../../widgets/status_chip.dart';
import 'withdrawal_screen.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  List<Withdrawal> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await context.read<AppState>().refreshUser();
      final items = await WithdrawalService.list();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openWithdraw() async {
    final balance = context.read<AppState>().user?.balance ?? 0;
    final t = AppLocalizations.of(context);
    if (balance < AppConfig.minWithdrawal) {
      showSnack(context, t.t('min_withdraw_note'), error: true);
      return;
    }
    final done = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => WithdrawalScreen(balance: balance)),
    );
    if (done == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AppState>().user;
    final df = DateFormat('dd.MM.yyyy HH:mm');
    final canWithdraw = (user?.balance ?? 0) >= AppConfig.minWithdrawal;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('balance'))),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(t.t('balance'),
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('${formatMoney(user?.balance ?? 0)} ${t.t('sum')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openWithdraw,
              icon: const Icon(Icons.payments_outlined),
              label: Text(t.t('withdraw')),
            ),
            if (!canWithdraw)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(t.t('min_withdraw_note'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            const SizedBox(height: 24),
            Text(t.t('withdraw'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                    child: Text(t.t('no_data'),
                        style: const TextStyle(color: Colors.grey))),
              )
            else
              ..._items.map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RoundedCard(
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0x1A16A34A),
                            child: Icon(Icons.payments_outlined,
                                color: AppTheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${formatMoney(w.amount)} ${t.t('sum')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(w.maskedCard,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                Text(df.format(w.createdAt),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          StatusChip(status: w.status),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
