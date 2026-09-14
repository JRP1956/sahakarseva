import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../theme.dart';
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
    final small = FilledButton.styleFrom(minimumSize: const Size(0, Ds.controlMd));
    return Async<List>(
      future: bookings,
      builder: (bs) => bs.isEmpty
          ? Empty(icon: Icons.list_alt_outlined, title: t.noBookings)
          : ListView.separated(
              padding: const EdgeInsets.all(Ds.space4),
              itemCount: bs.length,
              separatorBuilder: (_, _) => const SizedBox(height: Ds.space2),
              itemBuilder: (_, i) {
                final b = bs[i] as Map;
                return BookingTile(
                  b,
                  onTap: () {},
                  trailing: switch (b['status']) {
                    'accepted' => FilledButton(onPressed: () => act(b['id'], 'start'), style: small, child: Text(t.start)),
                    'in_progress' => FilledButton(onPressed: () => act(b['id'], 'complete'), style: small, child: Text(t.complete)),
                    _ => null,
                  },
                );
              },
            ),
    );
  }
}
