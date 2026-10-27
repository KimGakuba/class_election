import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:class_election/models/candidate.dart';
import 'package:class_election/models/election.dart';

void main() {
  test('Candidate survives json round trip', () {
    Candidate original = Candidate(name: 'Keza', votes: 3);
    String saved = jsonEncode(original.toJson());
    Candidate loaded = Candidate.fromJson(jsonDecode(saved) as Map<String, dynamic>);

    expect(loaded.name, original.name);
    expect(loaded.votes, original.votes);
  });

  test('Election survives json round trip with voters', () {
    Election original = Election(
      candidates: [
        Candidate(name: 'Keza', votes: 2),
        Candidate(name: 'Mutoni', votes: 1),
      ],
      voters: ['Keza', 'Mutoni', 'Aline'],
    );

    String saved = jsonEncode(original.toJson());
    Election loaded = Election.fromJson(jsonDecode(saved) as Map<String, dynamic>);

    expect(loaded.candidates.length, original.candidates.length);
    expect(loaded.candidates[0].name, 'Keza');
    expect(loaded.candidates[0].votes, 2);
    expect(loaded.candidates[1].name, 'Mutoni');
    expect(loaded.candidates[1].votes, 1);
    expect(loaded.voters, original.voters);
  });
}
