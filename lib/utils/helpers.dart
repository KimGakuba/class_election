import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

// myCandidates: the signed-in user's candidates collection
CollectionReference<Map<String, dynamic>> myCandidates() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('candidates');
}

// myVoters: the signed-in user's voters collection
CollectionReference<Map<String, dynamic>> myVoters() {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('voters');
}

// friendlyFirestoreError: readable message for common Firestore failures
String friendlyFirestoreError(Object error) {
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'You do not have permission to do that.';
    }
    if (error.code == 'unavailable') {
      return 'Cannot reach the database. Check your internet connection.';
    }
    if (error.code == 'not-found') {
      return 'That item no longer exists.';
    }
  }
  return 'Something went wrong. Please try again.';
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
