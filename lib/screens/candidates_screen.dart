import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/candidate.dart';
import '../utils/helpers.dart';
import '../theme.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

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

  void _showSnack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  Future<void> _addCandidate(List<Candidate> candidates) async {
    String cleaned = cleanName(_candidateController.text);
    if (cleaned.isEmpty) {
      _showSnack('Candidate name cannot be empty');
      return;
    }
    // check duplicate
    for (var c in candidates) {
      if (cleanName(c.name).toLowerCase() == cleaned.toLowerCase()) {
        _showSnack('Candidate already exists');
        return;
      }
    }
    try {
      await myCandidates().add({
        ...Candidate(name: cleaned, votes: 0).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _candidateController.clear();
      _showSnack('Candidate added');
    } on FirebaseException catch (e) {
      if (mounted) _showSnack(friendlyFirestoreError(e));
    } catch (e) {
      if (mounted) _showSnack('Could not add the candidate. Please try again.');
    }
  }

  Future<void> _editCandidate(
    Candidate candidate,
    List<Candidate> candidates,
  ) async {
    if (candidate.id.isEmpty) return;
    final controller = TextEditingController(text: candidate.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit candidate'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Candidate name'),
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (newName == null || !mounted) return;

    final cleaned = cleanName(newName);
    if (cleaned.isEmpty) {
      _showSnack('Candidate name cannot be empty');
      return;
    }
    if (cleaned == candidate.name) return;
    for (var c in candidates) {
      if (c.id != candidate.id &&
          cleanName(c.name).toLowerCase() == cleaned.toLowerCase()) {
        _showSnack('Candidate already exists');
        return;
      }
    }

    try {
      // Update only the changed field so votes are not reset.
      await myCandidates().doc(candidate.id).update({'name': cleaned});
      if (mounted) _showSnack('Candidate updated');
    } on FirebaseException catch (e) {
      if (mounted) _showSnack(friendlyFirestoreError(e));
    } catch (e) {
      if (mounted) _showSnack('Could not update the candidate. Please try again.');
    }
  }

  Future<void> _confirmDelete(Candidate candidate) async {
    if (candidate.id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete this candidate?'),
          content: Text('This will remove ${candidate.name} from the ballot.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    final ref = myCandidates().doc(candidate.id);
    try {
      final snapshot = await ref.get();
      final data = snapshot.data() ??
          {
            ...candidate.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
          };
      await ref.delete();
      if (!mounted) return;
      _showSnack(
        '${candidate.name} deleted',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              // Put the exact same document data back.
              await ref.set(data);
            } on FirebaseException catch (e) {
              if (mounted) _showSnack(friendlyFirestoreError(e));
            } catch (e) {
              if (mounted) _showSnack('Could not undo the delete.');
            }
          },
        ),
      );
    } on FirebaseException catch (e) {
      if (mounted) _showSnack(friendlyFirestoreError(e));
    } catch (e) {
      if (mounted) _showSnack('Could not delete the candidate. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidates')),
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

          return Padding(
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
                    FilledButton(
                      onPressed: () => _addCandidate(candidates),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'On the ballot',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: kInk,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap to edit. Long press to delete.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: candidates.isEmpty
                      ? const Center(
                          child: Text(
                            'No candidates yet. Add the first one above.',
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: () => _editCandidate(c, candidates),
                                  onLongPress: () => _confirmDelete(c),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: avatarColor(index),
                                          child: Text(
                                            c.name.isNotEmpty
                                                ? c.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: kInk,
                                                ),
                                              ),
                                              Text(
                                                c.votes == 0
                                                    ? 'No votes yet'
                                                    : '${c.votes} vote(s)',
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.black38,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
