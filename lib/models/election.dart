import 'candidate.dart';

class Election {
  List<Candidate> candidates; // changes (add/remove)
  List<String> voters;        // cleaned voter names who voted - changes

  Election({
    List<Candidate>? candidates,
    List<String>? voters,
  })  : candidates = candidates ?? [],
        voters = voters ?? [];

  // toJson: convert Election to map for saving (candidates as list of maps, voters as list)
  Map<String, dynamic> toJson() {
    return {
      'candidates': candidates.map((c) => c.toJson()).toList(),
      'voters': voters,
    };
  }

  // fromJson: build Election from saved map
  factory Election.fromJson(Map<String, dynamic> json) {
    List<Candidate> candidatesList = [];
    if (json['candidates'] != null) {
      final list = json['candidates'] as List;
      for (var item in list) {
        if (item is Map<String, dynamic>) {
          candidatesList.add(Candidate.fromJson(item));
        } else if (item is Map) {
          candidatesList.add(Candidate.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    List<String> votersList = [];
    if (json['voters'] != null) {
      final list = json['voters'] as List;
      for (var item in list) {
        if (item != null) {
          votersList.add(item.toString());
        }
      }
    }
    return Election(candidates: candidatesList, voters: votersList);
  }
}
