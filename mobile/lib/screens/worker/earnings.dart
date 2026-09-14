import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../theme.dart';
import '../../widgets.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Async<Map>(
      future: Api.I.get('/workers/me/earnings').then((v) => v as Map),
      builder: (e) {
        final jobs = e['jobs'] as List;
        return ListView(padding: const EdgeInsets.all(Ds.space4), children: [
          Container(
            padding: const EdgeInsets.all(Ds.space6),
            decoration: BoxDecoration(color: c.actionPrimary, borderRadius: BorderRadius.circular(Ds.radiusCard)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.thisMonth, style: text.bodySmall!.copyWith(color: c.textOnAction.withValues(alpha: 0.8))),
              const SizedBox(height: Ds.space2),
              Text(inr(e['month_total']), style: text.displayLarge!.copyWith(color: c.textOnAction)),
              const SizedBox(height: Ds.space2),
              Text(t.jobsDone(e['month_jobs']), style: text.bodyLarge!.copyWith(color: c.textOnAction.withValues(alpha: 0.8))),
            ]),
          ),
          if (jobs.isEmpty)
            Empty(icon: Icons.currency_rupee, title: t.jobsDone(0))
          else ...[
            const SizedBox(height: Ds.space4),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                for (final (i, j) in jobs.indexed) ...[
                  if (i > 0) const Divider(),
                  ListTile(
                    leading: Icon(Icons.check_circle_outline, color: c.feedbackSuccessIcon),
                    title: Text(j['service']),
                    subtitle: Text(DateFormat('d MMM yyyy').format(DateTime.parse(j['date']).toLocal())),
                    trailing: Text(inr(j['wage']), style: text.titleMedium),
                  ),
                ],
              ]),
            ),
          ],
        ]);
      },
    );
  }
}
