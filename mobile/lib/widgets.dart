import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'api.dart';
import 'theme.dart';

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

/// Status -> feedback tone (bg, fg). The word is always shown; colour never stands alone.
(Color, Color) statusTone(BuildContext context, String s) {
  final c = Ds.of(context).c;
  return switch (s) {
    'cancelled' => (c.feedbackErrorBg, c.feedbackErrorText),
    'in_progress' => (c.feedbackWarningBg, c.feedbackWarningText),
    'completed' || 'paid' || 'rated' => (c.feedbackSuccessBg, c.feedbackSuccessText),
    'assigned' || 'accepted' => (c.feedbackInfoBg, c.feedbackInfoText),
    _ => (c.surfaceSunken, c.textSecondary),
  };
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final String status;
  @override
  Widget build(BuildContext context) {
    final (bg, fg) = statusTone(context, status);
    return Pill(label: statusLabel(AppLocalizations.of(context)!, status), bg: bg, fg: fg);
  }
}

class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.bg, required this.fg, this.icon});
  final String label;
  final Color bg, fg;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: Ds.space2 + 2, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Ds.radiusBadge)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: fg)),
        ]),
      );
}

class Rating extends StatelessWidget {
  const Rating(this.avg, this.count, {super.key});
  final dynamic avg, count;
  @override
  Widget build(BuildContext context) {
    final c = Ds.of(context).c;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.star_rounded, size: 18, color: c.feedbackWarningIcon),
      const SizedBox(width: 2),
      Text('$avg', style: const TextStyle(fontWeight: FontWeight.w600)),
      Text(' ($count)', style: TextStyle(color: c.textSecondary)),
    ]);
  }
}

class WelfareBadges extends StatelessWidget {
  const WelfareBadges(this.w, {super.key});
  final Map w;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    return Wrap(spacing: Ds.space2, runSpacing: Ds.space1, children: [
      for (final (on, label) in [(w['has_insurance'], t.insured), (w['has_accident_cover'], t.accidentCover), (w['is_coop_member'], t.coopMember)])
        if (on == true) Pill(label: label, bg: c.feedbackSuccessBg, fg: c.feedbackSuccessText, icon: Icons.check_rounded),
    ]);
  }
}

/// Ledger: the customer figure leads, the split reads as a receipt underneath.
class PriceSplit extends StatelessWidget {
  const PriceSplit({super.key, required this.customer, required this.worker, required this.coop});
  final dynamic customer, worker, coop;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    Widget row(String l, dynamic v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: Ds.space1),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: text.bodySmall), Text(inr(v), style: text.bodyLarge)]),
        );
    return Container(
      padding: const EdgeInsets.all(Ds.space4),
      decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: BorderRadius.circular(Ds.radiusCard)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t.youPay, style: text.bodySmall),
        Text(inr(customer), style: text.headlineMedium),
        const SizedBox(height: Ds.space3),
        const Divider(),
        const SizedBox(height: Ds.space2),
        row(t.workerGets, worker),
        row(t.cooperativeGets, coop),
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Ds.space6, bottom: Ds.space3),
        child: Row(children: [Expanded(child: Text(text, style: Theme.of(context).textTheme.titleLarge)), ?trailing]),
      );
}

class Empty extends StatelessWidget {
  const Empty({super.key, required this.icon, required this.title, this.body});
  final IconData icon;
  final String title;
  final String? body;
  @override
  Widget build(BuildContext context) {
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Ds.space8, vertical: Ds.space12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 40, color: c.textTertiary),
          const SizedBox(height: Ds.space4),
          Text(title, textAlign: TextAlign.center, style: text.titleMedium),
          if (body != null) ...[const SizedBox(height: Ds.space2), Text(body!, textAlign: TextAlign.center, style: text.bodySmall)],
        ]),
      ),
    );
  }
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
          if (s.hasError) return Empty(icon: Icons.cloud_off_rounded, title: AppLocalizations.of(context)!.error, body: '${s.error}');
          if (!s.hasData) return const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5)));
          return builder(s.data as T);
        },
      );
}

void toast(BuildContext context, Object msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$msg')));

/// Primary action that stays at full strength while busy (loading is not disabled).
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.busy, required this.onPressed, required this.label, this.icon});
  final bool busy;
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? () {} : onPressed,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (busy) SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Ds.of(context).c.textOnAction))
          else if (icon != null) Icon(icon, size: 20),
          if (busy || icon != null) const SizedBox(width: Ds.space2),
          Text(label),
        ]),
      );
}

class LangMenu extends StatelessWidget {
  const LangMenu({super.key, required this.onChanged});
  final void Function(String) onChanged;
  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        tooltip: AppLocalizations.of(context)!.language,
        onSelected: onChanged,
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'en', child: Text('English')),
          PopupMenuItem(value: 'hi', child: Text('हिन्दी')),
          PopupMenuItem(value: 'mr', child: Text('मराठी')),
        ],
      );
}
