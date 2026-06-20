import 'package:flutter/material.dart';

import '../core/l10n.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  static const _colors = {
    'pending': Color(0xFFF59E0B),
    'accepted': Color(0xFF3B82F6),
    'collected': Color(0xFFF97316),
    'verified': Color(0xFF16A34A),
    'cancelled': Color(0xFF94A3B8),
    'paid': Color(0xFF16A34A),
    'rejected': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = _colors[status] ?? Colors.grey;
    final label = switch (status) {
      'paid' => 'To\'langan',
      'rejected' => 'Rad etilgan',
      _ => t.t('status_$status'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
