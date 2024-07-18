import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/version_repository.dart';
import 'domain/usecases/check_version.dart';
import 'presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Provide the VersionRepository
        RepositoryProvider<VersionRepository>(
          create: (context) => VersionRepository(),
        ),
        // Provide the CheckVersion use case
        RepositoryProvider<CheckVersion>(
          create: (context) => CheckVersion(context.read<VersionRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'App Version Checker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashPage(), // Start with the SplashPage
      ),
    );
  }
}
