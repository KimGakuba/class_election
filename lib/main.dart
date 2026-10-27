import 'package:flutter/material.dart';
import 'models/election.dart';
import 'models/candidate.dart';
import 'screens/vote_screen.dart';
import 'screens/results_screen.dart';
import 'screens/candidates_screen.dart';
import 'utils/rules.dart';
import 'utils/helpers.dart';
import 'widgets/weather_card.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClassElectionApp());
}

class ClassElectionApp extends StatelessWidget {
  const ClassElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Class Election',
      theme: appTheme(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Election? _election;
  bool _loaded = false;

  // loadElectionOnStart: load saved election or use default sample data
  Future<void> _loadElectionOnStart() async {
    final saved = await loadElection();
    if (saved == null) {
      setState(() {
        _election = Election(
          candidates: [
            Candidate(name: 'Keza', votes: 0),
            Candidate(name: 'Mutoni', votes: 0),
            Candidate(name: 'Aline', votes: 0),
          ],
          voters: [],
        );
        _loaded = true;
      });
    } else {
      setState(() {
        _election = saved;
        _loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadElectionOnStart();
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _election == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final election = _election!;
    return Scaffold(
      body: SafeArea(
        child: ListView(
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
                    child: const Icon(Icons.how_to_vote, size: 32, color: kInk),
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
                    style: TextStyle(color: Color(0xFFB7D3CE), fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Stat(value: '${totalVotes(election)}', label: 'votes cast'),
                      const SizedBox(width: 12),
                      _Stat(
                        value: '${election.candidates.length}',
                        label: 'candidates',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const WeatherCard(),
            const SizedBox(height: 24),
            _ActionCard(
              icon: Icons.how_to_vote,
              color: kTeal,
              title: 'Vote',
              subtitle: 'Enter your name and pick a candidate',
              onTap: () => _open(VoteScreen(election: election)),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.bar_chart,
              color: const Color(0xFF6D28D9),
              title: 'Results',
              subtitle: 'See the ranking and the winner',
              onTap: () => _open(ResultsScreen(election: election)),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              icon: Icons.people,
              color: const Color(0xFFEA580C),
              title: 'Candidates',
              subtitle: 'Add or remove people on the ballot',
              onTap: () => _open(CandidatesScreen(election: election)),
            ),
          ],
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
                      Text(subtitle, style: const TextStyle(color: Colors.black54)),
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