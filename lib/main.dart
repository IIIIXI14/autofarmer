import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AutoFarmerApp());
}

class AutoFarmerApp extends StatelessWidget {
  const AutoFarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoFarmer',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Scaffold(
        body: Center(child: Text('Welcome to AutoFarmer 🚜')),
      ),
    );
  }
}
