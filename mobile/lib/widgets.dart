import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'api.dart';

const kStatuses = ['requested', 'assigned', 'accepted', 'in_progress', 'completed', 'paid', 'rated'];

String statusLabel(AppLocalizations t, String s) => switch (s) {
      'requested' => t.status_requested,
      'assigned' => t.status_assigned,
      'accepted' => t.status_accepted,
      'in_progress' => t.status_in_progress,
      'completed' => t.status_completed,
      'paid' => t.status_paid,
      'rated' => t.status_rated,
      _ => t.status_cancelled,
    };

Color statusColor(String s) => switch (s) {
      'cancelled' => Colors.red,
      'in_progress' => Colors.amber.shade800,
      'completed' || 'paid' || 'rated' => Colors.green.shade700,
      _ => Colors.blueGrey,
    };

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) => Chip(
        label: Text(statusLabel(AppLocalizations.of(context)!, status), style: const TextStyle(color: Colors.white, fontSize: 12)),
        backgroundColor: statusColor(status),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      );
}

class WelfareBadges extends StatelessWidget {
  const WelfareBadges(this.w, {super.key});
  final Map w;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    Widget b(bool on, String label) => on
        ? Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Text('✓ $label', style: TextStyle(color: Colors.green.shade800, fontSize: 12)))
        : const SizedBox.shrink();
    return Wrap(children: [b(w['has_insurance'] == true, t.insured), b(w['has_accident_cover'] == true, t.accidentCover), b(w['is_coop_member'] == true, t.coopMember)]);
  }
}

class PriceSplit extends StatelessWidget {
  const PriceSplit({super.key, required this.customer, required this.worker, required this.coop});
  final dynamic customer, worker, coop;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    Widget row(String l, dynamic v, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(l),
            Text(inr(v), style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          ]),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [row(t.youPay, customer, bold: true), const Divider(), row(t.workerGets, worker), row(t.cooperativeGets, coop)]),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator());
}

/// FutureBuilder that shows a spinner / error and rebuilds on [refresh].
class Async<T> extends StatelessWidget {
  const Async({super.key, required this.future, required this.builder});
  final Future<T> future;
  final Widget Function(T data) builder;
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
        future: future,
        builder: (c, s) {
          if (s.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('${s.error}', textAlign: TextAlign.center)));
          if (!s.hasData) return const Loading();
          return builder(s.data as T);
        },
      );
}

void toast(BuildContext context, Object msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg')));

class LangMenu extends StatelessWidget {
  const LangMenu({super.key, required this.onChanged});
  final void Function(String) onChanged;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        onSelected: onChanged,
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'en', child: Text('English')),
          PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
          PopupMenuItem(value: 'mr', child: Text('मराठी')),
        ],
      );
}
