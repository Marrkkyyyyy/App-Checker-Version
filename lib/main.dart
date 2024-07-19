import 'package:flutter/material.dart';
import 'package:version_checker/presentation/splash_page.dart';
import 'data/services/check_version.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Version Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(checkVersion: CheckVersion()),
    );
  }
}
