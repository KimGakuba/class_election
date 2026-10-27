class Candidate {
  String name;      // cleaned name
  int votes;        // changes over time - NOT final

  Candidate({
    required this.name,
    this.votes = 0,
  });

  // toJson: convert Candidate to map for saving
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'votes': votes,
    };
  }

  // fromJson: build Candidate from saved map
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'] as String? ?? '',
      votes: ((json['votes'] as num?) ?? 0).toInt(),
    );
  }
}
