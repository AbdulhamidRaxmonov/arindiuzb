import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/application.dart';
import '../../services/services.dart';
import '../../widgets/helpers.dart';
import '../../widgets/status_chip.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  List<Application> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await ApplicationService.list();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('history'))),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Center(child: Text(t.t('no_data'))),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ApplicationTile(app: _items[i]),
                  ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  final Application app;
  const _ApplicationTile({required this.app});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final df = DateFormat('dd.MM.yyyy HH:mm');
    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0x1A16A34A),
                child: Icon(Icons.recycling, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.t(app.type)} · ${app.weightKg} kg',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(df.format(app.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              StatusChip(status: app.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(app.address,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(app.status == 'verified' ? 'Hisobga qo\'shildi' : t.t('estimated'),
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                '${formatMoney(app.status == 'verified' ? app.creditedAmount : app.estimatedAmount)} ${t.t('sum')}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ],
          ),
          if (app.courierComment != null && app.courierComment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.support_agent, size: 16, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(child: Text(app.courierComment!, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
