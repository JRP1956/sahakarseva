import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../customer/home.dart' show serviceIcon;

class JobsTab extends StatefulWidget {
  const JobsTab({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<JobsTab> {
  late Future<List> jobs = Api.I.get('/workers/me/jobs').then((v) => v as List);
  int? accepting;

  Future<void> accept(Map b) async {
    setState(() => accepting = b['id']);
    try {
      await Api.I.post('/bookings/${b['id']}/accept');
      widget.onChanged();
    } catch (e) {
      if (mounted) { toast(context, e); setState(() => accepting = null); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Async<List>(
      future: jobs,
      builder: (js) => js.isEmpty
          ? Empty(icon: Icons.work_outline, title: t.noRequests)
          : ListView.separated(
              padding: const EdgeInsets.all(Ds.space4),
              itemCount: js.length,
              separatorBuilder: (_, _) => const SizedBox(height: Ds.space3),
              itemBuilder: (_, i) {
                final b = js[i] as Map;
                final lead = i == 0;
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(lead ? Ds.space6 : Ds.space4),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(serviceIcon(b['service_name']), color: c.actionPrimary),
                        const SizedBox(width: Ds.space2),
                        Expanded(child: Text(b['service_name'], style: lead ? text.headlineMedium : text.titleLarge)),
                        if (b['is_emergency'] == true) Pill(label: t.emergency, bg: c.feedbackErrorBg, fg: c.feedbackErrorText, icon: Icons.bolt_rounded),
                      ]),
                      const SizedBox(height: Ds.space2),
                      Text(DateFormat('EEE d MMM, h:mm a').format(DateTime.parse(b['scheduled_at']).toLocal()), style: text.bodyLarge),
                      Text('${b['address']}\n${b['customer']['name']}', style: text.bodySmall),
                      const SizedBox(height: Ds.space4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(t.estimatedEarnings, style: text.bodySmall),
                        Text(inr(b['worker_wage']), style: (lead ? text.displayMedium : text.headlineMedium)!.copyWith(color: c.textLink)),
                      ]),
                      const SizedBox(height: Ds.space4),
                      if (lead)
                        BusyButton(busy: accepting == b['id'], onPressed: () => accept(b), label: t.accept)
                      else
                        Align(alignment: Alignment.centerRight, child: OutlinedButton(onPressed: () => accept(b), style: OutlinedButton.styleFrom(minimumSize: const Size(0, Ds.controlMd)), child: Text(t.accept))),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}
