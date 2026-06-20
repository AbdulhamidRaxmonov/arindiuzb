import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api_client.dart';

final _money = NumberFormat.decimalPattern('uz');
String formatMoney(num v) => _money.format(v);

void showSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? Colors.red.shade600 : null,
    ));
}

String describeError(Object e) =>
    e is ApiException ? e.message : 'Internet aloqasini tekshiring';

const statusLabels = {
  'pending': 'Yangi',
  'accepted': 'Qabul qilingan',
  'collected': 'Yakunlangan',
  'verified': 'Tekshirildi',
  'cancelled': 'Bekor qilingan',
};

const statusColors = {
  'pending': Color(0xFFF59E0B),
  'accepted': Color(0xFF3B82F6),
  'collected': Color(0xFFF97316),
  'verified': Color(0xFF16A34A),
  'cancelled': Color(0xFF94A3B8),
};

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(statusLabels[status] ?? status,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
