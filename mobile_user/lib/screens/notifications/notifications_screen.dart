import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/app_notification.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final (items, _) = await NotificationService.list();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAll() async {
    try {
      await NotificationService.markAllRead();
      _load();
    } catch (_) {}
  }

  IconData _iconFor(String type) => switch (type) {
        'withdrawal' => Icons.payments_outlined,
        'application' => Icons.recycling,
        _ => Icons.notifications_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final df = DateFormat('dd.MM.yyyy HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(t.t('notifications')),
        actions: [
          if (_items.any((n) => !n.isRead))
            TextButton(onPressed: _markAll, child: Text(t.t('mark_all_read'))),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(child: Text(t.t('no_data'))),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final n = _items[i];
                      return RoundedCard(
                        color: n.isRead
                            ? null
                            : AppTheme.primary.withOpacity(0.06),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primary.withOpacity(0.12),
                              child: Icon(_iconFor(n.type), color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(n.body),
                                  const SizedBox(height: 6),
                                  Text(df.format(n.createdAt),
                                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
