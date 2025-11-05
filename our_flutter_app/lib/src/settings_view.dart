import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './services/theme_notifier.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();
    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Mörkt läge'),
          value: theme.mode == ThemeMode.dark,
          onChanged: (_) => theme.toggle(),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Om appen'),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'PulsoSphere',
            applicationVersion: '1.0.0',
            applicationIcon:
                const Icon(Icons.show_chart, size: 48, color: Colors.redAccent),
            children: const [
              Text(
                  'PulsoSphere är en mobilapplikation som visar både EKG- och EMG-signal i realtid. Appen ansluter enkelt till kompatibla sensorer via Bluetooth, ritar tydliga, uppdaterade grafer och låter dig spela in mätdata för senare analys. \nMålet är att erbjuda en intuitiv och tillförlitlig plattform för övervakning, forskning och utbildning inom medicinsk teknik.'
                  '\n\nUtvecklad av:'
                  '\nMuse Dubet, Dennis Vidmant, Farhad Jelve, Peter Karlström och Karib Kaykobad'
                  '\n\nLicens: MIT (se “View licenses” för detaljer)'
                  '\n\nVersion 1.0.0')
            ],
          ),
        ),
      ],
    );
  }
}
