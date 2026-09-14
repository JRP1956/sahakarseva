import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../widgets.dart';

class JobsTab extends StatefulWidget {
  const JobsTab({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  late Future<List> jobs = Api.I.get('/workers/me/jobs').then((v) => v as List);

  Future<void> accept(Map b) async {
    try {
      await Api.I.post('/bookings/${b['id']}/accept');
      widget.onChanged();
    } catch (e) {
      if (mounted) toast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Async<List>(
      future: jobs,
      builder: (js) => js.isEmpty
          ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(t.noRequests, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))))
          : ListView(padding: const EdgeInsets.all(12), children: [
              Text(t.newRequests, style: Theme.of(context).textTheme.titleLarge),
              for (final b in js)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(b['service_name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                        if (b['is_emergency'] == true) const Chip(label: Text('Emergency'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white, fontSize: 11), visualDensity: VisualDensity.compact),
                      ]),
                      Text('${DateFormat('EEE d MMM, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal())}\n${b['address']}\n${b['customer']['name']}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(t.estimatedEarnings),
                          Text(inr(b['worker_wage']), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green.shade800)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: () => accept(b), child: Text(t.accept))),
                    ]),
                  ),
                ),
            ]),
    );
  }
}
