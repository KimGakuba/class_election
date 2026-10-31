import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb ? DefaultFirebaseOptions.web : null,
  );
  runApp(const ClassElectionApp());
}

class ClassElectionApp extends StatelessWidget {
  const ClassElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Class Election',
      theme: appTheme(),
      home: const AuthGate(),
    );
  }
}
