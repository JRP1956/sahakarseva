import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api.dart';
import '../../theme.dart';
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
    final c = Ds.of(context).c;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => StatefulBuilder(
        builder: (dc, set) => AlertDialog(
          title: Text(t.rate),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 1; i <= 5; i++)
                IconButton(onPressed: () => set(() => stars = i), tooltip: '$i', icon: Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, color: c.feedbackWarningIcon, size: 36)),
            ]),
            const SizedBox(height: Ds.space3),
            TextField(controller: comment, decoration: const InputDecoration(hintText: 'Comment')),
          ]),
          actions: [FilledButton(onPressed: () => Navigator.pop(dc, true), style: FilledButton.styleFrom(minimumSize: const Size(0, Ds.controlMd)), child: Text(t.submit))],
        ),
      ),
    );
    if (ok == true) act(() => Api.I.post('/ratings', {'booking_id': widget.id, 'stars': stars, 'comment': comment.text}));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.booking(widget.id))),
      body: Async<Map>(
        future: booking,
        builder: (b) {
          final s = b['status'] as String;
          final w = b['worker'] as Map?;
          final idx = kStatuses.indexOf(s);
          return ListView(padding: const EdgeInsets.all(Ds.space4), children: [
            if (b['is_emergency'] == true) Align(alignment: Alignment.centerLeft, child: Pill(label: t.emergency, bg: c.feedbackErrorBg, fg: c.feedbackErrorText, icon: Icons.bolt_rounded)),
            const SizedBox(height: Ds.space2),
            Text(b['service_name'], style: text.displayMedium),
            const SizedBox(height: Ds.space2),
            Text(DateFormat('EEE d MMM yyyy, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal()), style: text.bodyLarge),
            Text(b['address'], style: text.bodySmall),
            const SizedBox(height: Ds.space6),
            if (s == 'cancelled')
              const Align(alignment: Alignment.centerLeft, child: StatusChip('cancelled'))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Ds.space4, vertical: Ds.space3),
                  child: Column(children: [
                    for (var i = 0; i < kStatuses.length; i++)
                      _Step(label: statusLabel(t, kStatuses[i]), done: i < idx, current: i == idx, last: i == kStatuses.length - 1),
                  ]),
                ),
              ),
            const SizedBox(height: Ds.space4),
            if (w != null)
              Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: c.interactiveSelectedBg, foregroundColor: c.actionPrimary, child: const Icon(Icons.person_outline)),
                  title: Text(w['name']),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(w['coop_name']),
                    const SizedBox(height: Ds.space1),
                    Rating(w['rating_avg'], w['rating_count']),
                    const SizedBox(height: Ds.space1),
                    WelfareBadges(w),
                  ]),
                ),
              ),
            const SizedBox(height: Ds.space4),
            PriceSplit(customer: b['customer_price'], worker: b['worker_wage'], coop: b['coop_contribution']),
            const SizedBox(height: Ds.space6),
            if (s == 'completed') ...[
              FilledButton.icon(onPressed: () => act(() => Api.I.post('/payments/demo-mark-paid', {'booking_id': widget.id})), icon: const Icon(Icons.payment_outlined), label: Text(t.pay(inr(b['customer_price'])))),
              Padding(padding: const EdgeInsets.all(Ds.space2), child: Text(t.paymentDemo, textAlign: TextAlign.center, style: text.bodySmall)),
            ],
            if (s == 'paid') FilledButton.icon(onPressed: rate, icon: const Icon(Icons.star_outline_rounded), label: Text(t.rate)),
            if (s == 'paid' || s == 'rated') ...[
              const SizedBox(height: Ds.space2),
              OutlinedButton.icon(onPressed: () => launchUrl(Uri.parse('$apiUrl/invoices/${widget.id}?token=${Api.I.token}')), icon: const Icon(Icons.receipt_long_outlined), label: Text(t.viewInvoice)),
            ],
            if (['requested', 'assigned', 'accepted'].contains(s))
              TextButton(onPressed: () => act(() => Api.I.post('/bookings/${widget.id}/cancel')), style: TextButton.styleFrom(foregroundColor: c.actionDestructive), child: Text(t.cancelBooking)),
          ]);
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done, required this.current, required this.last});
  final String label;
  final bool done, current, last;
  @override
  Widget build(BuildContext context) {
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    final on = done || current;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: on ? c.actionPrimary : c.surfaceCard, border: Border.all(color: on ? c.actionPrimary : c.borderStrong, width: 1.5)),
          child: done ? Icon(Icons.check_rounded, size: 16, color: c.textOnAction) : current ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: c.textOnAction))) : null,
        ),
        if (!last) Container(width: 2, height: 24, color: done ? c.actionPrimary : c.borderDefault),
      ]),
      const SizedBox(width: Ds.space3),
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(label, style: current ? text.titleMedium : text.bodyLarge!.copyWith(color: done ? c.textPrimary : c.textTertiary)),
      ),
    ]);
  }
}
