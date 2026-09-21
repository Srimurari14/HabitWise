import 'package:flutter/material.dart';

import '../../../core/widgets/habit_widgets.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy and safety')),
      body: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Private by design',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'HabitWise is offline-first. It does not require an account and does not send your craving or health profile to a server.',
            ),
            const SizedBox(height: 22),
            const _PrivacyItem(
              icon: Icons.enhanced_encryption_outlined,
              title: 'Encrypted local storage',
              body:
                  'Check-ins, profile details, and learned patterns are stored in a SQLCipher-encrypted SQLite database. The encryption key is held in the operating system’s secure key storage.',
            ),
            const SizedBox(height: 12),
            const _PrivacyItem(
              icon: Icons.cloud_off_outlined,
              title: 'No analytics SDK',
              body:
                  'The production source includes no advertising, behavioral analytics, or remote telemetry SDK. Network access is not needed for a craving check-in.',
            ),
            const SizedBox(height: 12),
            const _PrivacyItem(
              icon: Icons.ios_share_rounded,
              title: 'You control export',
              body:
                  'Export creates a readable JSON file only when you ask. The operating-system share sheet controls where that file goes next.',
            ),
            const SizedBox(height: 12),
            const _PrivacyItem(
              icon: Icons.delete_forever_outlined,
              title: 'You control deletion',
              body:
                  'Delete all removes the profile, history, learned weights, plan statistics, and reflections, then returns the app to onboarding.',
            ),
            const SizedBox(height: 28),
            Text(
              'Medical and psychiatric guardrails',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const HabitCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('HabitWise can:'),
                  SizedBox(height: 6),
                  Text(
                    '• Account for patterns you report, such as appetite returning when an ADHD medication wears off.\n• Filter out unsuitable behavior tools.\n• Route warning signs to an existing care plan or urgent help.\n• Show descriptive associations in your own entries.',
                  ),
                  SizedBox(height: 16),
                  Text('HabitWise cannot:'),
                  SizedBox(height: 6),
                  Text(
                    '• Diagnose a psychiatric, metabolic, hormonal, sleep, or eating disorder.\n• Recommend changing medication, dose, or timing.\n• Calculate glucose treatment.\n• Replace a clinician, dietitian, emergency service, or crisis resource.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'If you may be in immediate danger, cannot keep yourself safe, have severe confusion or loss of consciousness, or face another emergency, contact local emergency services now.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return HabitCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
