import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../../api.dart';
import '../../main.dart';
import '../../theme.dart';
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
    final c = Ds.of(context).c;
    final pages = [JobsTab(key: ValueKey('j$refreshKey'), onChanged: () => setState(() => refreshKey++)), MyBookingsTab(key: ValueKey('b$refreshKey')), EarningsTab(key: ValueKey('e$refreshKey')), const ProfileTab()];
    final titles = [t.jobs, t.bookings, t.earnings, t.profile];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab]),
        actions: [
          if (available != null)
            Semantics(
              toggled: available,
              label: t.available,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Ds.space2),
                child: Row(children: [
                  Text(t.available, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: available! ? c.feedbackSuccessText : c.textSecondary)),
                  Switch(value: available!, onChanged: toggle),
                ]),
              ),
            ),
          LangMenu(onChanged: App.of(context).setLang),
          IconButton(icon: const Icon(Icons.logout), tooltip: t.signOut, onPressed: () async { await Api.I.logout(); if (context.mounted) App.of(context).refresh(); }),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() { tab = i; refreshKey++; }),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.work_outline), selectedIcon: const Icon(Icons.work), label: t.jobs),
          NavigationDestination(icon: const Icon(Icons.list_alt_outlined), selectedIcon: const Icon(Icons.list_alt), label: t.bookings),
          NavigationDestination(icon: const Icon(Icons.currency_rupee), label: t.earnings),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: t.profile),
        ],
      ),
    );
  }
}
