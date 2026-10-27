import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:class_election/models/candidate.dart';
import 'package:class_election/models/election.dart';
import 'package:class_election/utils/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadElection returns null on first launch', () async {
    SharedPreferences.setMockInitialValues({});
    Election? loaded = await loadElection();
    expect(loaded, isNull);
  });

  test('election candidates, votes and voters survive save/load', () async {
    SharedPreferences.setMockInitialValues({});
    Election election = Election(
      candidates: [
        Candidate(name: 'Keza', votes: 2),
        Candidate(name: 'Mutoni', votes: 1),
      ],
      voters: ['Keza', 'Mutoni'],
    );

    await saveElection(election);
    Election? loaded = await loadElection();

    expect(loaded, isNotNull);
    expect(loaded!.candidates.length, 2);
    expect(loaded.candidates[0].name, 'Keza');
    expect(loaded.candidates[0].votes, 2);
    expect(loaded.candidates[1].name, 'Mutoni');
    expect(loaded.candidates[1].votes, 1);
    expect(loaded.voters, ['Keza', 'Mutoni']);
  });

  test('voter saved as already voted is still blocked after loading', () async {
    SharedPreferences.setMockInitialValues({});
    Election election = Election(
      candidates: [Candidate(name: 'Keza', votes: 0)],
      voters: ['Aline'],
    );

    await saveElection(election);
    Election? loaded = await loadElection();

    expect(loaded, isNotNull);
    expect(hasVoted(loaded!.voters, 'aline'), isTrue);
  });
}
