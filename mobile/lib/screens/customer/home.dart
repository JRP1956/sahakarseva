import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../main.dart';
import '../../theme.dart';
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
      builder: (_) => ListView(padding: const EdgeInsets.symmetric(vertical: Ds.space3), children: [
        for (final s in svcs)
          ListTile(leading: Icon(serviceIcon(s['name'])), title: Text(s['name']), trailing: Text(inr(double.parse(s['base_price']) * 1.5), style: Theme.of(context).textTheme.titleMedium), onTap: () => Navigator.pop(context, s)),
      ]),
    );
    if (s != null) open(BookScreen(service: s, emergency: true));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.appName), actions: [
        LangMenu(onChanged: App.of(context).setLang),
        IconButton(icon: const Icon(Icons.logout), tooltip: t.signOut, onPressed: () async { await Api.I.logout(); if (context.mounted) App.of(context).refresh(); }),
      ]),
      body: RefreshIndicator(
        onRefresh: () async => setState(() { bookings = _loadBookings(); }),
        child: ListView(padding: const EdgeInsets.fromLTRB(Ds.space4, Ds.space2, Ds.space4, Ds.space8), children: [
          Text(t.services, style: text.displayMedium),
          const SizedBox(height: Ds.space4),
          Async<List>(
            future: services,
            builder: (svcs) => Card(
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (final (i, s) in svcs.indexed) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    onTap: () => open(BookScreen(service: s)),
                    minTileHeight: 60,
                    leading: Icon(serviceIcon(s['name']), color: c.actionPrimary),
                    title: Text(s['name']),
                    subtitle: Text('${inr(s['base_price'])}+', style: text.bodySmall),
                    trailing: Icon(Icons.chevron_right, color: c.textTertiary),
                  ),
                ],
              ]),
            ),
          ),
          const SizedBox(height: Ds.space4),
          Material(
            color: c.feedbackErrorBg,
            borderRadius: BorderRadius.circular(Ds.radiusCard),
            child: InkWell(
              onTap: emergency,
              borderRadius: BorderRadius.circular(Ds.radiusCard),
              child: Padding(
                padding: const EdgeInsets.all(Ds.space4),
                child: Row(children: [
                  Icon(Icons.bolt_rounded, color: c.feedbackErrorIcon, size: 28),
                  const SizedBox(width: Ds.space3),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.emergency, style: text.titleMedium!.copyWith(color: c.feedbackErrorText)),
                    Text(t.emergencyHint, style: text.bodySmall!.copyWith(color: c.feedbackErrorText)),
                  ])),
                  Icon(Icons.chevron_right, color: c.feedbackErrorText),
                ]),
              ),
            ),
          ),
          SectionTitle(t.myBookings),
          Async<List>(
            future: bookings,
            builder: (bs) => bs.isEmpty
                ? Empty(icon: Icons.event_note_outlined, title: t.noBookings)
                : Column(children: [for (final b in bs) Padding(padding: const EdgeInsets.only(bottom: Ds.space2), child: BookingTile(b, onTap: () => open(BookingDetail(id: b['id']))))]),
          ),
        ]),
      ),
    );
  }
}

IconData serviceIcon(String n) => switch (n) {
      'Plumbing' => Icons.plumbing_outlined,
      'Electrical' => Icons.electrical_services_outlined,
      'Cleaning' => Icons.cleaning_services_outlined,
      'Carpentry' => Icons.carpenter_outlined,
      'Painting' => Icons.format_paint_outlined,
      'Gardening' => Icons.yard_outlined,
      'Caregiving' => Icons.volunteer_activism_outlined,
      _ => Icons.build_outlined,
    };

class BookingTile extends StatelessWidget {
  const BookingTile(this.b, {super.key, required this.onTap, this.trailing});
  final Map b;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    final when = DateFormat('EEE d MMM, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal());
    final who = Api.I.role == 'worker' ? b['customer']['name'] : b['worker']?['name'];
    final amount = Api.I.role == 'worker' ? b['worker_wage'] : b['customer_price'];
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Ds.space4),
          child: Row(children: [
            Icon(serviceIcon(b['service_name']), color: c.textSecondary),
            const SizedBox(width: Ds.space3),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(b['service_name'], style: text.titleMedium, overflow: TextOverflow.ellipsis)),
                  if (b['is_emergency'] == true) ...[const SizedBox(width: Ds.space2), Icon(Icons.bolt_rounded, color: c.feedbackErrorIcon, size: 18)],
                ]),
                Text(when, style: text.bodySmall),
                if (who != null) Text(who, style: text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: Ds.space3),
            trailing ?? Column(crossAxisAlignment: CrossAxisAlignment.end, children: [StatusChip(b['status']), const SizedBox(height: Ds.space1), Text(inr(amount), style: text.titleMedium)]),
          ]),
        ),
      ),
    );
  }
}
