import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/fine.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

import 'fine_types_screen.dart';

import 'create_appeal_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finesAsync = ref.watch(teamFinesProvider);
    final profile = ref.watch(userProfileProvider).value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, profile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(ref),
                  const SizedBox(height: 32),
                  Text('Siste hendelser', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          finesAsync.when(
            data: (fines) => fines.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Ingen bøter ennå. Bra jobba!'))),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildFineItem(context, ref, fines[index]),
                      childCount: fines.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Feil: $e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppUser? profile) {
    return SliverAppBar(
      title: const Text('Botkassa'),
      floating: true,
      actions: [
        if (profile?.role == UserRole.admin)
          IconButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const FineTypesScreen())
            ),
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
          ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryBlue),
        ),
      ],
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${profile?.id ?? "admin"}'),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Din saldo', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            '${profile?.balance.toInt() ?? 0},- kr',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceDetail('Ubetalt', '${profile?.balance.toInt() ?? 0},-'),
              _buildBalanceDetail('Lagkasse', '12.450,-'), // Mock for now
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _buildFineItem(BuildContext context, WidgetRef ref, Fine fine) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${fine.userId}')),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fine.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(fine.typeName, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: fine.isPaid ? Colors.green[50] : AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${fine.amount.toInt()},-',
                    style: TextStyle(
                      color: fine.isPaid ? Colors.green : AppTheme.errorText, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            if (fine.evidenceUrl != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  fine.evidenceUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _formatDate(fine.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!fine.isPaid && fine.userId == ref.watch(userProfileProvider).value?.id) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateAppealScreen(fine: fine)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                  ),
                  child: const Text('ANKE PÅ BOT (9,- kr)'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'For ${diff.inMinutes} min siden';
    if (diff.inHours < 24) return 'For ${diff.inHours} timer siden';
    return '${date.day}.${date.month}.${date.year}';
  }
}
