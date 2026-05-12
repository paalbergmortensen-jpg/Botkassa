import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(teamLeaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wall of Shame'),
        centerTitle: true,
      ),
      body: leaderboardAsync.when(
        data: (players) {
          if (players.isEmpty) {
            return const Center(child: Text('Ingen syndere ennå!'));
          }

          final top3 = players.take(3).toList();
          final theRest = players.skip(3).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildPodium(context, top3),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPlayerTile(context, theRest[index], index + 4),
                    childCount: theRest.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Feil: $e')),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<AppUser> top3) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (top3.length > 1) _buildPodiumUser(context, top3[1], 2, 80),
          // 1st Place
          _buildPodiumUser(context, top3[0], 1, 110),
          // 3rd Place
          if (top3.length > 2) _buildPodiumUser(context, top3[2], 3, 70),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(BuildContext context, AppUser user, int rank, double size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: size,
              height: size,
              margin: const EdgeInsets.only(top: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentLime, width: 4),
                image: DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?u=${user.id}'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: AppTheme.accentLime, shape: BoxShape.circle),
              child: Text(
                rank.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          '${user.balance.toInt()},-',
          style: const TextStyle(color: AppTheme.accentLime, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPlayerTile(BuildContext context, AppUser user, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[400], fontSize: 18),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${user.id}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Text(
            '${user.balance.toInt()},-',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }
}
