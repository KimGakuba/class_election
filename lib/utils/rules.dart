import '../models/candidate.dart';
import '../models/election.dart';

// All rules live outside build()

// Get total votes
int totalVotes(Election election) {
  int total = 0;
  for (var c in election.candidates) {
    total += c.votes;
  }
  return total;
}

// Ranking: sort candidates highest votes first (use comparator - explainable)
List<Candidate> getRankedCandidates(Election election) {
  List<Candidate> list = List<Candidate>.from(election.candidates);
  list.sort((a, b) {
    if (b.votes != a.votes) {
      return b.votes.compareTo(a.votes); // higher first
    }
    // if tie in votes, keep original order by name? not specified, but stable-ish by comparator
    return a.name.compareTo(b.name);
  });
  return list;
}

// Get percentage string to 1 decimal, guard against division by zero
String getPercentage(int votes, int total) {
  if (total == 0) return '0.0%';
  double pct = (votes * 100.0) / total;
  // format to 1 decimal
  return '${pct.toStringAsFixed(1)}%';
}

// Get percentage value for progress bar
double getPercentageValue(int votes, int total) {
  if (total == 0) return 0.0;
  return (votes * 100.0) / total;
}

// Get banner text
String getWinnerBanner(Election election) {
  int total = totalVotes(election);
  if (total == 0) return 'No votes yet';
  List<Candidate> ranked = getRankedCandidates(election);
  if (ranked.isEmpty) return 'No votes yet';
  int topVotes = ranked[0].votes;
  // find how many share topVotes
  List<Candidate> top = [];
  for (var c in ranked) {
    if (c.votes == topVotes) {
      top.add(c);
    } else {
      break; // since ranked
    }
  }
  if (top.length == 1) {
    return 'Winner: ${top[0].name}';
  } else {
    // tie
    String names = '';
    for (int i = 0; i < top.length; i++) {
      names += top[i].name;
      if (i < top.length - 2) {
        names += ', ';
      } else if (i == top.length - 2) {
        names += ' and ';
      }
    }
    return 'Tie between $names ($topVotes votes each)';
  }
}
