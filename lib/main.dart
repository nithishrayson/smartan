import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartan/screens/main_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ImageSyncApp());
}

class ImageSyncApp extends StatelessWidget {
  const ImageSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Sync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: MainScreen(),
    );
  }
}