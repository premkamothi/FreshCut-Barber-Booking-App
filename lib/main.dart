import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_sem7/uiscreen/StartingPage.dart';
import 'firebase_options.dart'; // Import this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use this
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Startingpage(),
    );
  }
}
