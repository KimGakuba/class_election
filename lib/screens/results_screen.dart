import 'package:flutter/material.dart';
import '../models/election.dart';
import '../utils/rules.dart';
import '../utils/helpers.dart' show saveElection;
import '../theme.dart';

class ResultsScreen extends StatefulWidget {
  final Election election;
  const ResultsScreen({super.key, required this.election});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('This will clear all votes and the voters list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  resetElection(widget.election);
                });
                saveElection(widget.election);
                Navigator.pop(context);
                _showSnack('Votes reset');
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = totalVotes(widget.election);
    String banner = getWinnerBanner(widget.election);
    List<dynamic> ranked = getRankedCandidates(widget.election);
    bool isTie = banner.startsWith('Tie');
    bool hasWinner = total > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: Padding(
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
                          Icon(Icons.ballot_outlined, size: 56, color: Colors.black26),
                          SizedBox(height: 8),
                          Text('No votes yet', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: ranked.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var c = ranked[index];
                        double pctValue = getPercentageValue(c.votes, total);
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
                                  backgroundColor: const Color(0xFFE5ECE9),
                                  color: barColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${c.votes} votes',
                                style: const TextStyle(color: Colors.black54),
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