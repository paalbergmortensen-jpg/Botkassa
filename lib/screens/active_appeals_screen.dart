import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appeal.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class ActiveAppealsScreen extends ConsumerWidget {
  const ActiveAppealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appealsAsync = ref.watch(teamAppealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktive Anker'),
        centerTitle: true,
      ),
      body: appealsAsync.when(
        data: (appeals) => appeals.isEmpty
            ? const Center(child: Text('Ingen aktive anker akkurat nå.'))
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: appeals.length,
                itemBuilder: (context, index) => _buildAppealCard(context, ref, appeals[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Feil: $e')),
      ),
    );
  }

  Widget _buildAppealCard(BuildContext context, WidgetRef ref, Appeal appeal) {
    final profile = ref.watch(userProfileProvider).value;
    final hasVoted = appeal.votesFor.contains(profile?.id) || appeal.votesAgainst.contains(profile?.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${appeal.userId}')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appeal.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Anker på bot', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                _buildTimer(appeal.expiryDate),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              appeal.reason,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            if (appeal.evidenceUrl != null) ...[
              const SizedBox(height: 16),
              _buildEvidencePreview(appeal),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            if (hasVoted)
              const Center(child: Text('Du har stemt!', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _vote(ref, appeal.id, profile?.id, false),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('BEHOLD BOT'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _vote(ref, appeal.id, profile?.id, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentLime),
                      child: const Text('SLETT BOT', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          Text('$hours t $minutes m igjen', style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEvidencePreview(Appeal appeal) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            appeal.evidenceUrl!,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
          ),
          if (appeal.evidenceType == EvidenceType.video)
            const CircleAvatar(
              backgroundColor: Colors.black54,
              child: Icon(Icons.play_arrow, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Future<void> _vote(WidgetRef ref, String appealId, String? userId, bool isFor) async {
    if (userId == null) return;
    await ref.read(firestoreServiceProvider).voteOnAppeal(appealId, userId, isFor);
  }
}
