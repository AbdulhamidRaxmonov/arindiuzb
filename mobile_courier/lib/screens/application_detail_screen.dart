import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/helpers.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final Application app;
  const ApplicationDetailScreen({super.key, required this.app});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  late Application _app = widget.app;
  bool _busy = false;

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      final res = await CourierService.accept(_app.id);
      if (!mounted) return;
      showSnack(context, res.message);
      Navigator.pop(context, true);
    } catch (e) {
      showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete() async {
    final commentController = TextEditingController(text: _app.comment ?? '');
    final weightController =
        TextEditingController(text: _app.weightKg.toString());

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Zayafkani yakunlash',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Aniq og\'irlik (kg)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Izoh',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Qabul qildim'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      final res = await CourierService.complete(
        _app.id,
        comment: commentController.text.trim(),
        weightKg: double.tryParse(weightController.text.replaceAll(',', '.')),
      );
      if (!mounted) return;
      showSnack(context, res.message);
      Navigator.pop(context, true);
    } catch (e) {
      showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openMap() async {
    if (_app.latitude == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_app.latitude},${_app.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call() async {
    final uri = Uri.parse('tel:${_app.userPhone}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Zayafka #${_app.id}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_app.userName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              StatusChip(status: _app.status),
            ],
          ),
          const SizedBox(height: 16),
          if (_app.photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(_app.photoUrl!,
                  height: 200, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          const SizedBox(height: 16),
          _infoRow(Icons.scale, 'Og\'irlik', '${_app.weightKg} kg'),
          _infoRow(Icons.payments_outlined, 'Taxminiy summa',
              '${formatMoney(_app.estimatedAmount)} so\'m'),
          _infoRow(Icons.home_outlined, 'Manzil', _app.address),
          if (_app.comment != null && _app.comment!.isNotEmpty)
            _infoRow(Icons.notes, 'Izoh', _app.comment!),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.call),
                  label: const Text('Qo\'ng\'iroq'),
                ),
              ),
              if (_app.latitude != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMap,
                    icon: const Icon(Icons.map),
                    label: const Text('Xarita'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          if (_app.status == 'pending')
            FilledButton.icon(
              onPressed: _busy ? null : _accept,
              icon: const Icon(Icons.handshake_outlined),
              label: const Text('Zayafkani qabul qilish'),
            )
          else if (_app.status == 'accepted')
            FilledButton.icon(
              onPressed: _busy ? null : _complete,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryDark),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Qabul qildim (yakunlash)'),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_app.status == 'collected'
                        ? 'Yakunlangan. Admin tekshiruvi kutilmoqda.'
                        : 'Tekshirildi.'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
