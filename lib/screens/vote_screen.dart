import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../models/election.dart';
import '../utils/rules.dart';
import '../utils/helpers.dart' show saveElection;
import '../theme.dart';
import 'results_screen.dart';
import 'candidates_screen.dart';

class VoteScreen extends StatefulWidget {
  final Election election;
  const VoteScreen({super.key, required this.election});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final TextEditingController _voterController = TextEditingController();

  @override
  void dispose() {
    _voterController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _vote(Candidate candidate) {
    String cleanedVoter = cleanName(_voterController.text);
    if (cleanedVoter.isEmpty) {
      _showSnack('Please enter your name');
      return;
    }
    // check if already voted (case/space insensitive)
    for (var v in widget.election.voters) {
      if (cleanName(v) == cleanedVoter) {
        _showSnack('$cleanedVoter has already voted');
        return;
      }
    }
    // cast vote
    setState(() {
      candidate.votes += 1;
      widget.election.voters.add(cleanedVoter);
    });
    saveElection(widget.election);
    _voterController.clear();
    _showSnack('Vote cast for ${candidate.name}');
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    int total = totalVotes(widget.election);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Candidates',
            onPressed: () => _open(CandidatesScreen(election: widget.election)),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Results',
            onPressed: () => _open(ResultsScreen(election: widget.election)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your name',
              style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _voterController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person_outline),
                hintText: 'Enter your full name',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Choose a candidate',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: kInk,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kInk,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$total votes so far',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.election.candidates.isEmpty
                  ? const Center(
                      child: Text('No candidates yet. Add one from the people icon.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: widget.election.candidates.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        Candidate c = widget.election.candidates[index];
                        return Container(
                          decoration: cardBox(),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: avatarColor(index),
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: kInk,
                                      ),
                                    ),
                                    Text(
                                      '${c.votes} vote(s)',
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              FilledButton(
                                onPressed: () => _vote(c),
                                child: const Text('Vote'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}