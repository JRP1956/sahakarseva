import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../theme.dart';
import '../../widgets.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map> me = _load();
  Future<Map> _load() => Api.I.get('/workers/me').then((v) => v as Map);

  Future<void> editSkills(Map m) async {
    final services = await Api.I.get('/services') as List;
    final selected = {for (final s in m['skills']) s['id'] as int};
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(t.skills),
          content: SizedBox(
            width: 360,
            child: ListView(shrinkWrap: true, children: [
              for (final s in services) ...[
                Padding(padding: const EdgeInsets.only(top: 8), child: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w600))),
                for (final k in s['skills'])
                  CheckboxListTile(dense: true, value: selected.contains(k['id']), title: Text(k['name']), onChanged: (v) => set(() => v! ? selected.add(k['id']) : selected.remove(k['id']))),
              ],
            ]),
          ),
          actions: [FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.save))],
        ),
      ),
    );
    if (ok == true) {
      await Api.I.put('/workers/me/skills', selected.toList());
      setState(() { me = _load(); });
    }
  }

  Future<void> addCert() async {
    final t = AppLocalizations.of(context)!;
    final name = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.addCertification),
        content: TextField(controller: name, decoration: const InputDecoration(hintText: 'ITI Electrical, Safety Training…')),
        actions: [FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(t.save))],
      ),
    );
    if (ok == true && name.text.isNotEmpty) {
      // ponytail: name only; add file_picker + multipart when certificate scans are needed
      await Api.I.form('/workers/me/certifications', {'name': name.text});
      setState(() { me = _load(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Async<Map>(
      future: me,
      builder: (m) => ListView(padding: const EdgeInsets.all(Ds.space4), children: [
        Text(m['name'], style: text.displayMedium),
        const SizedBox(height: Ds.space1),
        Text(m['coop_name'], style: text.bodyLarge!.copyWith(color: c.textSecondary)),
        const SizedBox(height: Ds.space3),
        Wrap(spacing: Ds.space4, runSpacing: Ds.space1, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Rating(m['rating_avg'], m['rating_count']),
          Text(t.experience(m['experience_years'])),
          Text(t.jobsThisWeek(m['jobs_this_week'])),
        ]),
        SectionTitle(t.welfare),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            for (final (i, (on, label)) in [(m['has_insurance'], t.insured), (m['has_accident_cover'], t.accidentCover), (m['is_coop_member'], t.coopMember)].indexed) ...[
              if (i > 0) const Divider(),
              ListTile(
                leading: Icon(on == true ? Icons.verified_outlined : Icons.remove_circle_outline, color: on == true ? c.feedbackSuccessIcon : c.textTertiary),
                title: Text(label),
              ),
            ],
          ]),
        ),
        SectionTitle(t.skills, trailing: IconButton(onPressed: () => editSkills(m), tooltip: t.skills, icon: const Icon(Icons.edit_outlined))),
        Wrap(spacing: Ds.space2, runSpacing: Ds.space2, children: [for (final s in m['skills']) Chip(label: Text('${s['name']}'))]),
        SectionTitle(t.certifications, trailing: TextButton.icon(onPressed: addCert, icon: const Icon(Icons.add, size: 18), label: Text(t.addCertification))),
        Card(
          clipBehavior: Clip.antiAlias,
          child: (m['certifications'] as List).isEmpty
              ? Padding(padding: const EdgeInsets.all(Ds.space4), child: Text(t.addCertification, style: text.bodySmall))
              : Column(children: [
                  for (final (i, cert) in (m['certifications'] as List).indexed) ...[
                    if (i > 0) const Divider(),
                    ListTile(
                      leading: Icon(cert['verified'] == true ? Icons.verified_outlined : Icons.hourglass_top_outlined, color: cert['verified'] == true ? c.feedbackSuccessIcon : c.feedbackWarningIcon),
                      title: Text(cert['name']),
                      subtitle: Text(cert['verified'] == true ? t.verified : t.pendingVerification),
                    ),
                  ],
                ]),
        ),
        const SizedBox(height: Ds.space8),
      ]),
    );
  }
}
