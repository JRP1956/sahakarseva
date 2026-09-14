import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'booking_detail.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, required this.booking});
  final Map booking;
  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<List> cands = Api.I.post('/bookings/${widget.booking['id']}/match').then((v) => v as List);
  int? choosing;

  Future<void> choose(Map w) async {
    setState(() => choosing = w['id']);
    try {
      await Api.I.post('/bookings/${widget.booking['id']}/assign', {'worker_id': w['id']});
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDetail(id: widget.booking['id'])));
    } catch (e) {
      if (mounted) { toast(context, e); setState(() => choosing = null); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.matchedWorkers)),
      body: Async<List>(
        future: cands,
        builder: (cs) => cs.isEmpty
            ? Empty(icon: Icons.person_search_outlined, title: t.noWorkers)
            : ListView.separated(
                padding: const EdgeInsets.all(Ds.space4),
                itemCount: cs.length,
                separatorBuilder: (_, _) => const SizedBox(height: Ds.space3),
                itemBuilder: (_, i) => WorkerCard(cs[i], rank: i + 1, busy: choosing == cs[i]['worker']['id'], onChoose: () => choose(cs[i]['worker'])),
              ),
      ),
    );
  }
}

/// Rank 1 is the hero: tinted surface, bigger score, full-width action. The rest stay quiet.
class WorkerCard extends StatelessWidget {
  const WorkerCard(this.c, {super.key, required this.rank, required this.onChoose, this.busy = false});
  final Map c;
  final int rank;
  final bool busy;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final ds = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    final w = c['worker'] as Map;
    final br = c['breakdown'] as Map;
    final lead = rank == 1;
    return Card(
      color: lead ? ds.interactiveSelectedBg : null,
      shape: lead ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(Ds.radiusCard), side: BorderSide(color: ds.actionPrimary, width: 1.5)) : null,
      child: Padding(
        padding: EdgeInsets.all(lead ? Ds.space6 : Ds.space4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$rank', style: text.labelSmall),
                Text(w['name'], style: lead ? text.headlineMedium : text.titleLarge),
                Text(w['coop_name'], style: text.bodySmall),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${c['score']}', style: (lead ? text.displayMedium : text.headlineMedium)!.copyWith(color: ds.textLink)),
              Text(t.matchScore, style: text.labelSmall),
            ]),
          ]),
          const SizedBox(height: Ds.space3),
          Wrap(spacing: Ds.space4, runSpacing: Ds.space1, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Rating(w['rating_avg'], w['rating_count']),
            Text(t.kmAway(c['distance_km'].toString())),
            Text(t.experience(w['experience_years'])),
            Text(t.jobsThisWeek(w['jobs_this_week'])),
          ]),
          const SizedBox(height: Ds.space2),
          Text((w['skills'] as List).join(', '), style: text.bodySmall),
          const SizedBox(height: Ds.space2),
          WelfareBadges(w),
          const SizedBox(height: Ds.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(Ds.radiusBadge),
            child: Row(children: [
              for (final (i, k) in ['skill', 'distance', 'availability', 'rating', 'experience', 'fair_workload'].indexed)
                Expanded(
                  flex: ((br[k] as num) * 10).round().clamp(1, 1000),
                  child: Tooltip(message: '$k: ${br[k]}', child: Container(height: 6, color: ds.actionPrimary.withValues(alpha: 1 - i * 0.14))),
                ),
              Expanded(flex: 200, child: Container(height: 6, color: ds.surfaceSunken)),
            ]),
          ),
          const SizedBox(height: Ds.space4),
          if (lead)
            BusyButton(busy: busy, onPressed: onChoose, label: t.choose)
          else
            Align(alignment: Alignment.centerRight, child: OutlinedButton(onPressed: busy ? () {} : onChoose, style: OutlinedButton.styleFrom(minimumSize: const Size(0, Ds.controlMd)), child: Text(t.choose))),
        ]),
      ),
    );
  }
}
