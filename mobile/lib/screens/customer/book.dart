import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../api.dart';
import '../../widgets.dart';
import 'booking_detail.dart';
import 'match.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key, required this.service, this.emergency = false});
  final Map service;
  final bool emergency;
  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final address = TextEditingController(text: 'Andheri West, Mumbai');
  LatLng pin = const LatLng(19.1136, 72.8697);
  late DateTime when = widget.emergency ? DateTime.now().add(const Duration(hours: 1)) : DateTime.now().add(const Duration(days: 1)).copyWith(hour: 10, minute: 0);
  late bool emergency = widget.emergency;
  bool busy = false;

  double get base => double.parse(widget.service['base_price']);
  double get total => emergency ? base * 1.5 : base;
  double get wage => total * widget.service['worker_share_pct'] / 100;

  Future<void> pickWhen() async {
    final d = await showDatePicker(context: context, initialDate: when, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (d == null || !mounted) return;
    final tm = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
    if (tm == null) return;
    setState(() => when = DateTime(d.year, d.month, d.day, tm.hour, tm.minute));
  }

  Future<void> submit() async {
    setState(() => busy = true);
    try {
      final b = await Api.I.post('/bookings', {
        'service_id': widget.service['id'], 'lat': pin.latitude, 'lng': pin.longitude, 'address': address.text,
        'scheduled_at': when.toUtc().toIso8601String(), 'is_emergency': emergency,
      });
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => b['status'] == 'assigned' ? BookingDetail(id: b['id']) : MatchScreen(booking: b)));
    } catch (e) {
      if (mounted) toast(context, e);
      setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.bookService(widget.service['name']))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: address, decoration: InputDecoration(labelText: t.address, prefixIcon: const Icon(Icons.home))),
        const SizedBox(height: 8),
        Text(t.pinLocation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        SizedBox(
          height: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(initialCenter: pin, initialZoom: 12, onTap: (_, p) => setState(() => pin = p)),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'in.coop.sahakarseva'),
                MarkerLayer(markers: [Marker(point: pin, width: 40, height: 40, child: const Icon(Icons.location_pin, color: Colors.red, size: 40))]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.schedule),
          title: Text(t.when),
          subtitle: Text(DateFormat('EEE d MMM yyyy, h:mm a').format(when)),
          trailing: const Icon(Icons.edit),
          onTap: pickWhen,
        ),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: emergency, onChanged: (v) => setState(() => emergency = v), title: Text(t.isEmergency), secondary: const Icon(Icons.bolt, color: Colors.red)),
        const SizedBox(height: 8),
        PriceSplit(customer: total, worker: wage, coop: total - wage),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: busy ? null : submit, icon: const Icon(Icons.search), label: Text(t.findWorkers)),
      ]),
    );
  }
}
