import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/l10n.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import '../home/main_shell.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String? debugCode;
  const OtpScreen({super.key, required this.phone, this.debugCode});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.debugCode != null) _codeController.text = widget.debugCode!;
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    if (_codeController.text.trim().length != 6) {
      showSnack(context, t.t('enter_code'), error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await AuthService.verifyOtp(
        widget.phone,
        _codeController.text.trim(),
        _nameController.text.trim(),
      );
      await context.read<AppState>().onLoggedIn(result.token, result.user);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
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
      appBar: AppBar(title: Text(t.t('verify'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                '${t.t('otp_sent')}\n${widget.phone}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (widget.debugCode != null) ...[
                const SizedBox(height: 8),
                Text(
                  'DEV kod: ${widget.debugCode}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
              const SizedBox(height: 28),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: const TextStyle(fontSize: 26, letterSpacing: 8),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  labelText: t.t('enter_code'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: t.t('name'),
                  prefixIcon: const Icon(Icons.person_outline),
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
                    : Text(t.t('verify')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
