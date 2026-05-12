import 'package:flutter/material.dart';
import '../theme.dart';

class AppealsScreen extends StatelessWidget {
  const AppealsScreen({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AKTIV ANKE',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Anke-Alarm: Jonas H.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.timer_outlined, size: 16, color: AppTheme.errorText),
                      SizedBox(width: 4),
                      Text(
                        '08:42\nigjen',
                        style: TextStyle(color: AppTheme.errorText, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildVideoPlayerCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildVotingResults(),
            const SizedBox(height: 32),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayerCard() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500&q=80'), // Example player photo
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.circle, color: Colors.red, size: 8),
                    SizedBox(width: 8),
                    Text('30-sekunders forsvarstale', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0:14', style: TextStyle(color: Colors.white, fontSize: 12)),
                    Text('0:30', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.46,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentLime),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildLargeActionButton(
          'Godta',
          'Slett boten helt',
          Icons.check_circle_rounded,
          AppTheme.accentLime,
          Colors.black,
        ),
        const SizedBox(height: 16),
        _buildLargeActionButton(
          'Betal!',
          'Avvis anken',
          Icons.cancel_rounded,
          AppTheme.errorRed,
          AppTheme.errorText,
        ),
      ],
    );
  }

  Widget _buildLargeActionButton(String title, String subtitle, IconData icon, Color color, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 40),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVotingResults() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Foreløpig resultat', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('64% Godtar', style: TextStyle(color: Color(0xFF4B6E00), fontSize: 20, fontWeight: FontWeight.bold)),
              Text('36% Betal', style: TextStyle(color: AppTheme.errorText, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(flex: 64, child: Container(height: 12, color: AppTheme.accentLime)),
                Expanded(flex: 36, child: Container(height: 12, color: AppTheme.errorRed)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('14 av 22 stemmer', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Denne anken krever simpelt flertall (over 50%) for å bli godkjent. Dersom anken avvises, øker boten med 25% i "anke-gebyr".',
              style: TextStyle(color: AppTheme.primaryBlue, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
