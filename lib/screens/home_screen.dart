import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../models/election.dart';
import '../utils/helpers.dart';
import '../utils/rules.dart';
import '../widgets/weather_card.dart';
import '../theme.dart';
import 'candidates_screen.dart';
import 'results_screen.dart';
import 'vote_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log out. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Election'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: myCandidates().orderBy('createdAt').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? const [];
            final candidates = docs.map(Candidate.fromDoc).toList();
            final total = totalVotes(Election(candidates: candidates));

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Hero: the one bold element on this screen
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kInk,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kAmber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.how_to_vote,
                          size: 32,
                          color: kInk,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Class Election',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'One student, one vote.',
                        style: TextStyle(
                          color: Color(0xFFB7D3CE),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _Stat(value: '$total', label: 'votes cast'),
                          const SizedBox(width: 12),
                          _Stat(
                            value: '${candidates.length}',
                            label: 'candidates',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (snapshot.hasError) ...[
                  const SizedBox(height: 16),
                  Text(
                    friendlyFirestoreError(snapshot.error!),
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ],
                const SizedBox(height: 24),
                const WeatherCard(),
                const SizedBox(height: 24),
                _ActionCard(
                  icon: Icons.how_to_vote,
                  color: kTeal,
                  title: 'Vote',
                  subtitle: 'Enter your name and pick a candidate',
                  onTap: () => _open(context, const VoteScreen()),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.bar_chart,
                  color: const Color(0xFF6D28D9),
                  title: 'Results',
                  subtitle: 'See the ranking and the winner',
                  onTap: () => _open(context, const ResultsScreen()),
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  icon: Icons.people,
                  color: const Color(0xFFEA580C),
                  title: 'Candidates',
                  subtitle: 'Add, edit or remove people on the ballot',
                  onTap: () => _open(context, const CandidatesScreen()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4A44),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Color(0xFFB7D3CE))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardBox(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
