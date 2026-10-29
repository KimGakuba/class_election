import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../models/election.dart';
import '../utils/helpers.dart';
import '../utils/rules.dart';
import '../theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _resetting = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will clear all votes and the voters list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _resetting = true;
    });

    try {
      final candidates = await myCandidates().get();
      final voters = await myVoters().get();

      if (candidates.docs.isEmpty && voters.docs.isEmpty) {
        if (mounted) _showSnack('Nothing to reset');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in candidates.docs) {
        batch.update(doc.reference, {'votes': 0});
      }
      for (final doc in voters.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) _showSnack('Votes reset');
    } on FirebaseException catch (e) {
      if (mounted) _showSnack(friendlyFirestoreError(e));
    } catch (e) {
      if (mounted) _showSnack('Could not reset the votes. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _resetting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          if (_resetting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
              onPressed: _confirmReset,
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

          if (candidates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No candidates yet. Add candidates before voting.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final election = Election(candidates: candidates);
          int total = totalVotes(election);
          String banner = getWinnerBanner(election);
          List<Candidate> ranked = getRankedCandidates(election);
          bool isTie = banner.startsWith('Tie');
          bool hasWinner = total > 0;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner: dark with an amber trophy when there is a result
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: hasWinner ? kInk : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isTie ? Icons.balance : Icons.emoji_events,
                        size: 34,
                        color: hasWinner ? kAmber : Colors.black38,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          banner,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: hasWinner ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                total == 0
                    ? const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.ballot_outlined,
                                size: 56,
                                color: Colors.black26,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No votes yet',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: ranked.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            Candidate c = ranked[index];
                            double pctValue =
                                getPercentageValue(c.votes, total);
                            String pctStr = getPercentage(c.votes, total);
                            Color barColor = index == 0 ? kAmber : kTeal;
                            return Container(
                              decoration: cardBox(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: barColor,
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: kInk,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: kInk,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        pctStr,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: kInk,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: pctValue / 100.0,
                                      minHeight: 12,
                                      backgroundColor:
                                          const Color(0xFFE5ECE9),
                                      color: barColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${c.votes} votes',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
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
