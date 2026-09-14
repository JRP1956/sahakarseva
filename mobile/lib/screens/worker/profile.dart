import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
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
    return Async<Map>(
      future: me,
      builder: (m) => ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m['name'], style: Theme.of(context).textTheme.titleLarge),
              Text(m['coop_name'], style: const TextStyle(color: Colors.grey)),
              Text('⭐ ${m['rating_avg']} (${m['rating_count']}) · ${t.experience(m['experience_years'])} · ${t.jobsThisWeek(m['jobs_this_week'])}', style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.welfare, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              for (final (on, label) in [(m['has_insurance'], t.insured), (m['has_accident_cover'], t.accidentCover), (m['is_coop_member'], t.coopMember)])
                Row(children: [Icon(on == true ? Icons.verified : Icons.cancel_outlined, size: 18, color: on == true ? Colors.green.shade700 : Colors.grey), const SizedBox(width: 6), Text(label)]),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: Text(t.skills, style: const TextStyle(fontWeight: FontWeight.w600))), TextButton(onPressed: () => editSkills(m), child: const Icon(Icons.edit, size: 18))]),
        Wrap(spacing: 6, children: [for (final s in m['skills']) Chip(label: Text('${s['name']}'), visualDensity: VisualDensity.compact)]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: Text(t.certifications, style: const TextStyle(fontWeight: FontWeight.w600))), TextButton(onPressed: addCert, child: const Icon(Icons.add, size: 18))]),
        for (final c in m['certifications'])
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(c['verified'] == true ? Icons.verified : Icons.hourglass_top, color: c['verified'] == true ? Colors.green : Colors.orange),
            title: Text(c['name']),
            subtitle: Text(c['verified'] == true ? t.verified : t.pendingVerification),
          ),
      ]),
    );
  }
}
