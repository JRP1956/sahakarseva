import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../api.dart';
import '../main.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phone = TextEditingController(text: '9100000000');
  final password = TextEditingController(text: 'pass123');
  final name = TextEditingController();
  bool registering = false, busy = false;
  String role = 'customer';
  int? coopId;
  List coops = [];

  Future<void> submit() async {
    setState(() => busy = true);
    try {
      if (registering) {
        await Api.I.register(phone: phone.text, password: password.text, name: name.text, role: role, coopId: coopId);
      } else {
        await Api.I.login(phone.text, password.text);
      }
      if (mounted) App.of(context).refresh();
    } catch (e) {
      if (mounted) toast(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> toggleRegister() async {
    if (!registering && coops.isEmpty) coops = await Api.I.get('/services/cooperatives');
    setState(() => registering = !registering);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(actions: [LangMenu(onChanged: App.of(context).setLang)], backgroundColor: Colors.transparent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Icon(Icons.handshake, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(t.appName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
              Text(t.tagline, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              if (registering) ...[
                TextField(controller: name, decoration: InputDecoration(labelText: t.name)),
                const SizedBox(height: 12),
              ],
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: t.phone)),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: t.password)),
              if (registering) ...[
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: [ButtonSegment(value: 'customer', label: Text(t.iAmCustomer)), ButtonSegment(value: 'worker', label: Text(t.iAmWorker))],
                  selected: {role},
                  onSelectionChanged: (s) => setState(() => role = s.first),
                ),
                if (role == 'worker') ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: coopId,
                    decoration: InputDecoration(labelText: t.society),
                    items: [for (final c in coops) DropdownMenuItem(value: c['id'] as int, child: Text(c['name']))],
                    onChanged: (v) => setState(() => coopId = v),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              FilledButton(onPressed: busy ? null : submit, child: Text(registering ? t.createAccount : t.signIn)),
              TextButton(onPressed: toggleRegister, child: Text(registering ? t.signIn : t.createAccount)),
            ]),
          ),
        ),
      ),
    );
  }
}
