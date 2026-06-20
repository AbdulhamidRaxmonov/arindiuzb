import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController(text: '+998 ');
  bool _loading = false;

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final phone = _controller.text.replaceAll(RegExp(r'\s'), '');
    if (phone.replaceAll(RegExp(r'\D'), '').length < 12) {
      showSnack(context, t.t('enter_phone'), error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final debugCode = await AuthService.requestOtp(phone);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(phone: phone, debugCode: debugCode),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.recycling, size: 72, color: AppTheme.primary),
              const SizedBox(height: 12),
              Text(
                'Arindi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                t.t('enter_phone'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, letterSpacing: 1),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                ],
                decoration: InputDecoration(
                  labelText: t.t('phone'),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.4),
                      )
                    : Text(t.t('send_code')),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
