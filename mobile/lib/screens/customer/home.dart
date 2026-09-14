import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../main.dart';
import '../../widgets.dart';
import 'book.dart';
import 'booking_detail.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  late Future<List> services = Api.I.get('/services').then((v) => v as List);
  late Future<List> bookings = _loadBookings();
  Future<List> _loadBookings() => Api.I.get('/bookings').then((v) => v as List);

  Future<void> open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    setState(() { bookings = _loadBookings(); });
  }

  Future<void> emergency() async {
    final svcs = await services;
    if (!mounted) return;
    final s = await showModalBottomSheet<Map>(
      context: context,
      builder: (_) => ListView(children: [for (final s in svcs) ListTile(title: Text(s['name']), trailing: Text(inr(double.parse(s['base_price']) * 1.5)), onTap: () => Navigator.pop(context, s))]),
    );
    if (s != null) open(BookScreen(service: s, emergency: true));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.appName), actions: [
        LangMenu(onChanged: App.of(context).setLang),
        IconButton(icon: const Icon(Icons.logout), tooltip: t.signOut, onPressed: () async { await Api.I.logout(); if (context.mounted) App.of(context).refresh(); }),
      ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: emergency, backgroundColor: Colors.red, foregroundColor: Colors.white, icon: const Icon(Icons.bolt), label: Text(t.emergency)),
      body: RefreshIndicator(
        onRefresh: () async => setState(() { bookings = _loadBookings(); }),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(t.services, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Async<List>(
            future: services,
            builder: (svcs) => GridView.count(
              crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0,
              children: [
                for (final s in svcs)
                  InkWell(
                    onTap: () => open(BookScreen(service: s)),
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(_icon(s['name']), color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(height: 6),
                          Text(s['name'], textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.1)),
                          Text('${inr(s['base_price'])}+', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(t.emergencyHint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Text(t.myBookings, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Async<List>(
            future: bookings,
            builder: (bs) => bs.isEmpty
                ? Padding(padding: const EdgeInsets.all(24), child: Text(t.noBookings, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)))
                : Column(children: [for (final b in bs) BookingTile(b, onTap: () => open(BookingDetail(id: b['id'])))]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  IconData _icon(String n) => switch (n) {
        'Plumbing' => Icons.plumbing,
        'Electrical' => Icons.electrical_services,
        'Cleaning' => Icons.cleaning_services,
        'Carpentry' => Icons.carpenter,
        'Painting' => Icons.format_paint,
        'Gardening' => Icons.yard,
        'Caregiving' => Icons.volunteer_activism,
        _ => Icons.build,
      };
}

class BookingTile extends StatelessWidget {
  const BookingTile(this.b, {super.key, required this.onTap, this.trailing});
  final Map b;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final when = DateFormat('EEE d MMM, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal());
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Row(children: [
          Expanded(child: Text(b['service_name'], style: const TextStyle(fontWeight: FontWeight.w600))),
          if (b['is_emergency'] == true) const Icon(Icons.bolt, color: Colors.red, size: 18),
        ]),
        subtitle: Text('$when\n${Api.I.role == 'worker' ? b['customer']['name'] : (b['worker']?['name'] ?? '—')} · ${b['address']}', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: trailing ?? Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [StatusChip(b['status']), Text(inr(b['customer_price']))]),
        isThreeLine: true,
      ),
    );
  }
}
