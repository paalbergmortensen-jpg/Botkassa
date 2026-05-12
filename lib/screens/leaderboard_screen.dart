import 'package:flutter/material.dart';
import '../theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botkassa'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.primaryBlue),
          ),
        ],
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('Wall of Shame', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text('Hvem graver dypest i lommeboka?', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            _buildToggle(),
            const SizedBox(height: 40),
            _buildPodium(context),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RESTEN AV LAGET',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey[600],
                    ),
              ),
            ),
            const SizedBox(height: 16),
            _buildListPlayer(context, 4, 'Lars Holte', '12 bøter', '450,-', true),
            _buildListPlayer(context, 5, 'Sander Berg', '9 bøter', '320,-', false),
            _buildListPlayer(context, 6, 'Even Moe', '8 bøter', '250,-', false),
            _buildListPlayer(context, 7, 'Simen Foss', '5 bøter', '150,-', true),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.accentLime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Verstinger', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text('Gode Betalere', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumSpot(context, 2, 'Felix', '850,-', 'https://i.pravatar.cc/150?u=felix', 140),
        const SizedBox(width: 12),
        _buildPodiumSpot(context, 1, 'Marcus', '1250,-', 'https://i.pravatar.cc/150?u=marcus', 180, isWinner: true),
        const SizedBox(width: 12),
        _buildPodiumSpot(context, 3, 'Tobias', '600,-', 'https://i.pravatar.cc/150?u=tobias', 120),
      ],
    );
  }

  Widget _buildPodiumSpot(
    BuildContext context,
    int rank,
    String name,
    String amount,
    String avatarUrl,
    double height, {
    bool isWinner = false,
  }) {
    final color = isWinner ? AppTheme.primaryBlue : Colors.white;
    final textColor = isWinner ? Colors.white : AppTheme.primaryBlue;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: isWinner ? 45 : 35,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            if (isWinner)
              Positioned(
                top: -10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 20),
                ),
              ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: isWinner ? Colors.amber : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 100,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isWinner ? Colors.white70 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListPlayer(
    BuildContext context,
    int rank,
    String name,
    String finesCount,
    String amount,
    bool isUnpaid,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                rank.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(finesCount, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnpaid ? AppTheme.errorRed : AppTheme.accentLime,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isUnpaid ? 'UBETALT' : 'OPPGJORT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnpaid ? AppTheme.errorText : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
