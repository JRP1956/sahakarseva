import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../widgets.dart';
import '../customer/home.dart' show BookingTile;

class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});
  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  late Future<List> bookings = _load();
  Future<List> _load() => Api.I.get('/bookings').then((v) => v as List);

  Future<void> act(int id, String action) async {
    try {
      await Api.I.post('/bookings/$id/$action');
      setState(() { bookings = _load(); });
    } catch (e) {
      if (mounted) toast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Async<List>(
      future: bookings,
      builder: (bs) => ListView(padding: const EdgeInsets.all(12), children: [
        for (final b in bs)
          BookingTile(
            b,
            onTap: () {},
            trailing: switch (b['status']) {
              'accepted' => FilledButton(onPressed: () => act(b['id'], 'start'), child: Text(t.start)),
              'in_progress' => FilledButton(onPressed: () => act(b['id'], 'complete'), child: Text(t.complete)),
              _ => Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [StatusChip(b['status']), Text(inr(b['worker_wage']))]),
            },
          ),
      ]),
    );
  }
}
