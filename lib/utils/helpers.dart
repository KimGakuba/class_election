import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/election.dart';

// Name cleaning helpers for Class Election
// Rules:
// - trim both ends
// - collapse extra spaces between words into one
// - convert to Title Case (e.g. "  keza   uwase " -> "Keza Uwase")

String cleanName(String input) {
  if (input.isEmpty) return '';
  // trim
  String trimmed = input.trim();
  if (trimmed.isEmpty) return '';
  // collapse multiple spaces
  String collapsed = trimmed.replaceAll(RegExp(r'\s+'), ' ');
  // Title Case
  List<String> parts = collapsed.split(' ');
  List<String> titled = [];
  for (var p in parts) {
    if (p.isEmpty) continue;
    // lowercase rest, uppercase first
    String lower = p.toLowerCase();
    String title = lower[0].toUpperCase() + lower.substring(1);
    titled.add(title);
  }
  return titled.join(' ');
}

// saveElection: save election data as json string with key 'election'
Future<void> saveElection(Election e) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = jsonEncode(e.toJson());
  await prefs.setString('election', jsonStr);
}

// loadElection: load election data; return null if nothing saved
Future<Election?> loadElection() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString('election');
  if (jsonStr == null) return null;
  final decoded = jsonDecode(jsonStr);
  if (decoded is Map<String, dynamic>) {
    return Election.fromJson(decoded);
  }
  if (decoded is Map) {
    return Election.fromJson(Map<String, dynamic>.from(decoded));
  }
  return null;
}

// Check if voter already exists (case/space insensitive after cleaning logic)
// We compare using cleaned forms
bool hasVoted(List<String> votersList, String voterName) {
  String cleaned = cleanName(voterName);
  if (cleaned.isEmpty) return false;
  // check if any existing cleaned voter equals cleaned
  for (var v in votersList) {
    if (cleanName(v) == cleaned) return true;
  }
  return false;
}

// Get cleaned voter name
String getCleanedVoter(String voterName) {
  return cleanName(voterName);
}
