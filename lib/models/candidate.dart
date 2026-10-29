import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  final String id;  // Firestore document id
  String name;      // cleaned name
  int votes;        // changes over time - NOT final

  Candidate({
    this.id = '',
    required this.name,
    this.votes = 0,
  });

  // toMap: the fields stored in Firestore for a candidate
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'votes': votes,
    };
  }

  // fromDoc: build Candidate from a Firestore document and keep its id
  factory Candidate.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Candidate(
      id: doc.id,
      name: data['name'] as String? ?? '',
      votes: ((data['votes'] as num?) ?? 0).toInt(),
    );
  }

  // toJson: convert Candidate to map for saving
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // fromJson: build Candidate from saved map
  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      votes: ((json['votes'] as num?) ?? 0).toInt(),
    );
  }
}
