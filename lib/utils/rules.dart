import '../models/candidate.dart';
import '../models/election.dart';

// All rules live outside build()

// Add candidate: must not be empty, not duplicate after cleaning
bool addCandidate(Election election, String inputName) {
  String cleaned = cleanName(inputName);
  if (cleaned.isEmpty) return false;
  // check duplicate
  for (var c in election.candidates) {
    if (cleanName(c.name) == cleaned) return false;
  }
  election.candidates.add(Candidate(name: cleaned, votes: 0));
  return true;
}

// Remove candidate: only if has no votes
bool removeCandidate(Election election, Candidate candidate) {
  if (candidate.votes != 0) return false;
  // remove if exists
  int idx = election.candidates.indexOf(candidate);
  if (idx == -1) {
    // try by name
    for (int i = 0; i < election.candidates.length; i++) {
      if (cleanName(election.candidates[i].name) == cleanName(candidate.name)) {
        if (election.candidates[i].votes == 0) {
          election.candidates.removeAt(i);
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }
  if (election.candidates[idx].votes == 0) {
    election.candidates.removeAt(idx);
    return true;
  }
  return false;
}

// Cast vote: needs non-empty voter name, each voter once (after cleaning)
// Returns true if vote cast, false otherwise
bool castVote(Election election, String voterName, Candidate candidate) {
  String cleanedVoter = cleanName(voterName);
  if (cleanedVoter.isEmpty) return false;
  // check if already voted
  for (var v in election.voters) {
    if (cleanName(v) == cleanedVoter) return false;
  }
  // cast vote
  candidate.votes += 1;
  election.voters.add(cleanedVoter);
  return true;
}

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

// Reset
void resetElection(Election election) {
  for (var c in election.candidates) {
    c.votes = 0;
  }
  election.voters.clear();
}

String cleanName(String input) {
  if (input.isEmpty) return '';
  String trimmed = input.trim();
  if (trimmed.isEmpty) return '';
  String collapsed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
  List<String> parts = collapsed.split(' ');
  List<String> titled = [];
  for (var p in parts) {
    if (p.isEmpty) continue;
    String lower = p.toLowerCase();
    String title = lower[0].toUpperCase() + lower.substring(1);
    titled.add(title);
  }
  return titled.join(' ');
}

bool hasVoted(List<String> votersList, String voterName) {
  String cleaned = cleanName(voterName);
  if (cleaned.isEmpty) return false;
  for (var v in votersList) {
    if (cleanName(v) == cleaned) return true;
  }
  return false;
}
