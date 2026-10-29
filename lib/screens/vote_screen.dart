import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../models/election.dart';
import '../utils/helpers.dart';
import '../utils/rules.dart';
import '../theme.dart';
import 'results_screen.dart';
import 'candidates_screen.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final TextEditingController _voterController = TextEditingController();
  String? _votingId;

  bool get _voting => _votingId != null;

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

  Future<void> _vote(Candidate candidate) async {
    String cleanedVoter = cleanName(_voterController.text);
    if (cleanedVoter.isEmpty) {
      _showSnack('Please enter your name');
      return;
    }
    if (candidate.id.isEmpty) return;

    setState(() {
      _votingId = candidate.id;
    });

    try {
      // Voter document id: lowercased, cleaned (trimmed) name.
      final voterRef = myVoters().doc(cleanedVoter.toLowerCase());
      final existing = await voterRef.get();
      if (existing.exists) {
        if (mounted) _showSnack('$cleanedVoter has already voted');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      batch.update(myCandidates().doc(candidate.id), {
        'votes': FieldValue.increment(1),
      });
      batch.set(voterRef, {
        'name': cleanedVoter,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      if (!mounted) return;
      _voterController.clear();
      _showSnack('Vote cast for ${candidate.name}');
    } on FirebaseException catch (e) {
      if (mounted) _showSnack(friendlyFirestoreError(e));
    } catch (e) {
      if (mounted) _showSnack('Could not cast the vote. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _votingId = null;
        });
      }
    }
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: 'Candidates',
            onPressed: () => _open(const CandidatesScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Results',
            onPressed: () => _open(const ResultsScreen()),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myCandidates().orderBy('createdAt').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  friendlyFirestoreError(snapshot.error!),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? const [];
          final candidates = docs.map(Candidate.fromDoc).toList();
          final total = totalVotes(Election(candidates: candidates));

          return Padding(
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
                  enabled: !_voting,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kInk,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$total votes so far',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: candidates.isEmpty
                      ? const Center(
                          child: Text(
                            'No candidates yet. Add one from the people icon.',
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: candidates.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            Candidate c = candidates[index];
                            return Container(
                              decoration: cardBox(),
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: avatarColor(index),
                                    child: Text(
                                      c.name.isNotEmpty
                                          ? c.name[0].toUpperCase()
                                          : '?',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: const TextStyle(
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton(
                                    onPressed:
                                        _voting ? null : () => _vote(c),
                                    child: _votingId == c.id
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Vote'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
