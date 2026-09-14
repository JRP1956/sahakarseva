import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../widgets.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Async<Map>(
      future: Api.I.get('/workers/me/earnings').then((v) => v as Map),
      builder: (e) => ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          color: Colors.green.shade700,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.thisMonth, style: const TextStyle(color: Colors.white70)),
              Text(inr(e['month_total']), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              Text(t.jobsDone(e['month_jobs']), style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        for (final j in e['jobs'] as List)
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(j['service']),
            subtitle: Text(DateFormat('d MMM yyyy').format(DateTime.parse(j['date']).toLocal())),
            trailing: Text(inr(j['wage']), style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}
