import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
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

  Future<void> choose(Map w) async {
    try {
      await Api.I.post('/bookings/${widget.booking['id']}/assign', {'worker_id': w['id']});
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDetail(id: widget.booking['id'])));
    } catch (e) {
      if (mounted) toast(context, e);
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
            ? Center(child: Text(t.noWorkers))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: cs.length,
                itemBuilder: (_, i) => WorkerCard(cs[i], rank: i + 1, onChoose: () => choose(cs[i]['worker'])),
              ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  const WorkerCard(this.c, {super.key, required this.rank, required this.onChoose});
  final Map c;
  final int rank;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final w = c['worker'] as Map;
    final br = c['breakdown'] as Map;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: rank == 1 ? Colors.green.shade700 : Colors.blueGrey, foregroundColor: Colors.white, child: Text('$rank')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text(w['coop_name'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${c['score']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green.shade800)),
              Text(t.matchScore, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 12, runSpacing: 4, children: [
            Text('⭐ ${w['rating_avg']} (${w['rating_count']})'),
            Text(t.kmAway(c['distance_km'].toString())),
            Text(t.experience(w['experience_years'])),
            Text(t.jobsThisWeek(w['jobs_this_week'])),
          ]),
          const SizedBox(height: 6),
          Text((w['skills'] as List).join(' · '), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          WelfareBadges(w),
          const SizedBox(height: 8),
          Row(children: [
            for (final k in ['skill', 'distance', 'availability', 'rating', 'experience', 'fair_workload'])
              Expanded(
                flex: ((br[k] as num) * 10).round().clamp(1, 1000),
                child: Tooltip(message: '$k: ${br[k]}', child: Container(height: 6, margin: const EdgeInsets.only(right: 1), color: _c(k))),
              ),
            const Spacer(flex: 200),
          ]),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: onChoose, child: Text(t.choose))),
        ]),
      ),
    );
  }

  Color _c(String k) => switch (k) {
        'skill' => Colors.green.shade800,
        'distance' => Colors.green.shade500,
        'availability' => Colors.teal,
        'rating' => Colors.amber,
        'experience' => Colors.blue,
        _ => Colors.purple,
      };
}
