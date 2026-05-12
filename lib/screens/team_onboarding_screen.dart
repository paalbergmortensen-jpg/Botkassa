import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../services/payment_service.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class TeamOnboardingScreen extends ConsumerWidget {
  const TeamOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentService = ref.watch(paymentServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Velkommen til Botkassa!', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 16),
              Text(
                'For å komme i gang må du enten opprette et nytt lag eller bli med i et eksisterende.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 64),
              _buildOptionCard(
                context,
                title: 'Opprett nytt lag',
                description: 'Start et nytt lag for din klubb eller vennegjeng. Pris: 69,- NOK',
                icon: Icons.group_add_rounded,
                color: AppTheme.primaryBlue,
                onTap: () async {
                  _showCreateDialog(context, ref);
                },
              ),
              const SizedBox(height: 24),
              _buildOptionCard(
                context,
                title: 'Bli med på et lag',
                description: 'Har du fått en 6-sifret kode fra laglederen din? Tast den inn her.',
                icon: Icons.vpn_key_rounded,
                color: AppTheme.accentLime,
                onTap: () {
                  _showJoinDialog(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: color == AppTheme.accentLime ? Colors.black : Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opprett nytt lag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Lagnavn (f.eks. FK Botkassa)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt')),
          ElevatedButton(
            onPressed: () async {
              final paymentService = ref.read(paymentServiceProvider);
              final firestoreService = ref.read(firestoreServiceProvider);
              final auth = ref.read(authStateProvider).value;
              
              if (auth == null) return;

              // Step 1: Paywall
              await paymentService.presentPaywall();
              
              // Step 2: Create team (assuming payment success for this demo)
              final code = await firestoreService.createTeamWithCode(nameController.text, auth.uid);
              
              if (context.mounted) {
                Navigator.pop(context);
                _showCodeDialog(context, code);
              }
            },
            child: const Text('Betal og opprett'),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bli med på et lag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Skriv inn den 6-sifrede koden:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt')),
          ElevatedButton(
            onPressed: () async {
              final firestoreService = ref.read(firestoreServiceProvider);
              final auth = ref.read(authStateProvider).value;
              if (auth == null) return;

              final success = await firestoreService.joinTeam(codeController.text, auth.uid);
              if (success && context.mounted) {
                Navigator.pop(context);
              } else {
                // Show error
              }
            },
            child: const Text('Bli med'),
          ),
        ],
      ),
    );
  }

  void _showCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lag opprettet!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Del denne koden med spillerne dine:'),
            const SizedBox(height: 16),
            Text(code, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Ferdig')),
        ],
      ),
    );
  }
}
