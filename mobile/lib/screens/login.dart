import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';

import '../api.dart';
import '../main.dart';
import '../theme.dart';
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
    final c = Ds.of(context).c;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(actions: [LangMenu(onChanged: App.of(context).setLang)]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Ds.space6, Ds.space8, Ds.space6, Ds.space6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: c.actionPrimary, borderRadius: BorderRadius.circular(Ds.radiusCard)),
                  child: Icon(Icons.handshake_outlined, color: c.textOnAction, size: 28),
                ),
              ),
              const SizedBox(height: Ds.space6),
              Text(t.appName, style: text.displayMedium),
              const SizedBox(height: Ds.space2),
              Text(t.tagline, style: text.bodyLarge!.copyWith(color: c.textSecondary)),
              const SizedBox(height: Ds.space8),
              if (registering) ...[
                TextField(controller: name, autofillHints: const [AutofillHints.name], decoration: InputDecoration(labelText: t.name)),
                const SizedBox(height: Ds.space3),
              ],
              TextField(controller: phone, keyboardType: TextInputType.phone, autofillHints: const [AutofillHints.telephoneNumber], decoration: InputDecoration(labelText: t.phone)),
              const SizedBox(height: Ds.space3),
              TextField(controller: password, obscureText: true, autofillHints: const [AutofillHints.password], decoration: InputDecoration(labelText: t.password), onSubmitted: (_) => submit()),
              if (registering) ...[
                const SizedBox(height: Ds.space3),
                SegmentedButton<String>(
                  segments: [ButtonSegment(value: 'customer', label: Text(t.iAmCustomer)), ButtonSegment(value: 'worker', label: Text(t.iAmWorker))],
                  selected: {role},
                  onSelectionChanged: (s) => setState(() => role = s.first),
                ),
                if (role == 'worker') ...[
                  const SizedBox(height: Ds.space3),
                  DropdownButtonFormField<int>(
                    initialValue: coopId,
                    decoration: InputDecoration(labelText: t.society),
                    items: [for (final c in coops) DropdownMenuItem(value: c['id'] as int, child: Text(c['name']))],
                    onChanged: (v) => setState(() => coopId = v),
                  ),
                ],
              ],
              const SizedBox(height: Ds.space6),
              BusyButton(busy: busy, onPressed: submit, label: registering ? t.createAccount : t.signIn),
              const SizedBox(height: Ds.space2),
              TextButton(onPressed: toggleRegister, child: Text(registering ? t.signIn : t.createAccount)),
            ]),
          ),
        ),
      ),
    );
  }
}
