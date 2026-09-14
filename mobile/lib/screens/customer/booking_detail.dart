import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api.dart';
import '../../widgets.dart';

class BookingDetail extends StatefulWidget {
  const BookingDetail({super.key, required this.id});
  final int id;
  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  late Future<Map> booking = _load();
  Future<Map> _load() => Api.I.get('/bookings/${widget.id}').then((v) => v as Map);

  Future<void> act(Future<dynamic> Function() f) async {
    try {
      await f();
      setState(() { booking = _load(); });
    } catch (e) {
      if (mounted) toast(context, e);
    }
  }

  Future<void> rate() async {
    int stars = 5;
    final comment = TextEditingController();
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(t.rate),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++) IconButton(onPressed: () => set(() => stars = i), icon: Icon(i <= stars ? Icons.star : Icons.star_border, color: Colors.amber, size: 32)),
            ]),
            TextField(controller: comment, decoration: const InputDecoration(hintText: 'Comment')),
          ]),
          actions: [FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.submit))],
        ),
      ),
    );
    if (ok == true) act(() => Api.I.post('/ratings', {'booking_id': widget.id, 'stars': stars, 'comment': comment.text}));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.booking(widget.id))),
      body: Async<Map>(
        future: booking,
        builder: (b) {
          final s = b['status'] as String;
          final w = b['worker'] as Map?;
          final idx = kStatuses.indexOf(s);
          return ListView(padding: const EdgeInsets.all(16), children: [
            Row(children: [
              Expanded(child: Text(b['service_name'], style: Theme.of(context).textTheme.headlineSmall)),
              if (b['is_emergency'] == true) const Chip(label: Text('Emergency'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white)),
            ]),
            Text('${DateFormat('EEE d MMM yyyy, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal())}\n${b['address']}'),
            const SizedBox(height: 16),
            if (s == 'cancelled') const StatusChip('cancelled') else
            for (var i = 0; i < kStatuses.length; i++)
              Row(children: [
                Icon(i <= idx ? Icons.check_circle : Icons.radio_button_unchecked, color: i <= idx ? Colors.green.shade700 : Colors.grey.shade400, size: 20),
                const SizedBox(width: 8),
                Text(statusLabel(t, kStatuses[i]), style: TextStyle(fontWeight: i == idx ? FontWeight.bold : null, color: i <= idx ? null : Colors.grey)),
              ]),
            const SizedBox(height: 16),
            if (w != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(w['name']),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${w['coop_name']} · ⭐ ${w['rating_avg']}'), WelfareBadges(w)]),
                ),
              ),
            PriceSplit(customer: b['customer_price'], worker: b['worker_wage'], coop: b['coop_contribution']),
            const SizedBox(height: 16),
            if (s == 'completed') ...[
              FilledButton.icon(onPressed: () => act(() => Api.I.post('/payments/demo-mark-paid', {'booking_id': widget.id})), icon: const Icon(Icons.payment), label: Text(t.pay(inr(b['customer_price'])))),
              Padding(padding: const EdgeInsets.all(4), child: Text(t.paymentDemo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey))),
            ],
            if (s == 'paid') FilledButton.icon(onPressed: rate, icon: const Icon(Icons.star), label: Text(t.rate)),
            if (s == 'paid' || s == 'rated')
              OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('$apiUrl/invoices/${widget.id}?token=${Api.I.token}')), icon: const Icon(Icons.receipt_long), label: Text(t.viewInvoice)),
            if (['requested', 'assigned', 'accepted'].contains(s))
              TextButton(onPressed: () => act(() => Api.I.post('/bookings/${widget.id}/cancel')), child: Text(t.cancelBooking, style: const TextStyle(color: Colors.red))),
          ]);
        },
      ),
    );
  }
}
