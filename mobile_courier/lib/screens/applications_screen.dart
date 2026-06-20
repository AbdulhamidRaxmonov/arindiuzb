import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/helpers.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  final _tabs = const [
    (label: 'Yangi', status: 'pending'),
    (label: 'Mening', status: 'accepted'),
    (label: 'Yakunlangan', status: 'collected'),
  ];

  @override
  Widget build(BuildContext context) {
    final courier = context.watch<AppState>().courier;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zayafkalar'),
        bottom: TabBar(
          controller: _tab,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'logout') context.read<AppState>().logout();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: false,
                child: Text(courier?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(value: 'logout', child: Text('Chiqish')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: _tabs.map((t) => _ApplicationList(status: t.status)).toList(),
      ),
    );
  }
}

class _ApplicationList extends StatefulWidget {
  final String status;
  const _ApplicationList({required this.status});

  @override
  State<_ApplicationList> createState() => _ApplicationListState();
}

class _ApplicationListState extends State<_ApplicationList>
    with AutomaticKeepAliveClientMixin {
  List<Application> _items = const [];
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await CourierService.applications(status: widget.status);
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) showSnack(context, describeError(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 140),
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Center(child: Text('Zayafkalar yo\'q')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _Tile(
                    app: _items[i],
                    onChanged: _load,
                  ),
                ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Application app;
  final VoidCallback onChanged;
  const _Tile({required this.app, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd.MM HH:mm');
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => ApplicationDetailScreen(app: app)),
        );
        if (changed == true) onChanged();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${app.userName} · ${app.userPhone}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                StatusChip(status: app.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.scale, size: 16, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text('${app.weightKg} kg'),
                const SizedBox(width: 16),
                const Icon(Icons.payments_outlined, size: 16, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text('${formatMoney(app.estimatedAmount)} so\'m'),
                const Spacer(),
                Text(df.format(app.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(app.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
