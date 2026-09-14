import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../main.dart';
import '../../widgets.dart';
import 'earnings.dart';
import 'jobs.dart';
import 'my_bookings.dart';
import 'profile.dart';

class WorkerHome extends StatefulWidget {
  const WorkerHome({super.key});
  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int tab = 0;
  bool? available;
  int refreshKey = 0;

  @override
  void initState() {
    super.initState();
    Api.I.get('/workers/me').then((m) => setState(() => available = m['is_available']));
  }

  Future<void> toggle(bool v) async {
    setState(() => available = v);
    await Api.I.post('/workers/me/availability', {'is_available': v});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final pages = [JobsTab(key: ValueKey('j$refreshKey'), onChanged: () => setState(() => refreshKey++)), MyBookingsTab(key: ValueKey('b$refreshKey')), EarningsTab(key: ValueKey('e$refreshKey')), const ProfileTab()];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        actions: [
          if (available != null) Row(children: [Text(t.available, style: const TextStyle(fontSize: 12)), Switch(value: available!, onChanged: toggle)]),
          LangMenu(onChanged: App.of(context).setLang),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async { await Api.I.logout(); if (context.mounted) App.of(context).refresh(); }),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() { tab = i; refreshKey++; }),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.work_outline), label: t.jobs),
          NavigationDestination(icon: const Icon(Icons.list_alt), label: t.bookings),
          NavigationDestination(icon: const Icon(Icons.currency_rupee), label: t.earnings),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: t.profile),
        ],
      ),
    );
  }
}
