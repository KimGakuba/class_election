import 'package:flutter/material.dart';
import '../models/election.dart';
import '../models/candidate.dart';
import '../utils/rules.dart';
import '../utils/helpers.dart' show saveElection;
import '../theme.dart';

class CandidatesScreen extends StatefulWidget {
  final Election election;
  const CandidatesScreen({super.key, required this.election});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final TextEditingController _candidateController = TextEditingController();

  @override
  void dispose() {
    _candidateController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addCandidate() {
    String cleaned = cleanName(_candidateController.text);
    if (cleaned.isEmpty) {
      _showSnack('Candidate name cannot be empty');
      return;
    }
    // check duplicate
    for (var c in widget.election.candidates) {
      if (cleanName(c.name) == cleaned) {
        _showSnack('Candidate already exists');
        return;
      }
    }
    setState(() {
      widget.election.candidates.add(Candidate(name: cleaned, votes: 0));
    });
    saveElection(widget.election);
    _candidateController.clear();
    _showSnack('Candidate added');
  }

  void _removeCandidate(Candidate candidate) {
    if (candidate.votes != 0) {
      _showSnack('Cannot remove a candidate with votes');
      return;
    }
    setState(() {
      widget.election.candidates.remove(candidate);
    });
    saveElection(widget.election);
    _showSnack('Candidate removed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a candidate',
              style: TextStyle(fontWeight: FontWeight.w700, color: kInk),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _candidateController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_add_alt),
                      hintText: 'Candidate name',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(onPressed: _addCandidate, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'On the ballot',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: kInk),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.election.candidates.isEmpty
                  ? const Center(child: Text('No candidates yet. Add the first one above.'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: widget.election.candidates.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        Candidate c = widget.election.candidates[index];
                        return Container(
                          decoration: cardBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: avatarColor(index),
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kInk,
                                      ),
                                    ),
                                    Text(
                                      c.votes == 0 ? 'No votes yet' : '${c.votes} vote(s)',
                                      style: const TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red.shade400,
                                onPressed: c.votes == 0 ? () => _removeCandidate(c) : null,
                                tooltip: c.votes == 0 ? 'Remove' : 'Cannot remove (has votes)',
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