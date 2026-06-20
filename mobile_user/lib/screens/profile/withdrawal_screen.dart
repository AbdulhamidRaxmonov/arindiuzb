import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/constants.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';

class WithdrawalScreen extends StatefulWidget {
  final double balance;
  const WithdrawalScreen({super.key, required this.balance});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _cardController = TextEditingController();
  final _holderController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await WithdrawalService.create(
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'\s'), '')),
        cardNumber: _cardController.text.trim(),
        cardHolder: _holderController.text.trim(),
      );
      if (!mounted) return;
      await context.read<AppState>().refreshUser();

      // Success alert with a single "close" button that returns to the home tab.
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppTheme.primary, size: 48),
          title: Text(t.t('withdraw')),
          content: Text(result.message),
          actions: [
            FilledButton(
              onPressed: () {
                // Pop dialog, withdrawal screen, and balance screen -> back to home.
                Navigator.of(context)
                  ..pop()
                  ..pop(true)
                  ..pop();
              },
              child: Text(t.t('close')),
            ),
          ],
        ),
      );
    } catch (e) {
      showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('withdraw'))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            RoundedCard(
              color: AppTheme.primary.withOpacity(0.08),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.t('balance'),
                            style: const TextStyle(color: Colors.grey)),
                        Text('${formatMoney(widget.balance)} ${t.t('sum')}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: t.t('amount'),
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: t.t('sum'),
              ),
              validator: (v) {
                final d = double.tryParse((v ?? '').trim());
                if (d == null) return t.t('required');
                if (d < AppConfig.minWithdrawal) return t.t('min_withdraw_note');
                if (d > widget.balance) return 'Balansda yetarli mablag\' yo\'q';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cardController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: InputDecoration(
                labelText: t.t('card_number'),
                prefixIcon: const Icon(Icons.credit_card),
                hintText: '8600 1234 5678 9012',
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 12) ? t.t('required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _holderController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: t.t('card_holder'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? t.t('required') : null,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    )
                  : Text(t.t('withdraw_btn')),
            ),
          ],
        ),
      ),
    );
  }
}
