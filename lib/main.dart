import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/services/check_version.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/bloc/version_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CheckVersion>(
          create: (context) => CheckVersion(),
        ),
      ],
      child: BlocProvider(
        create: (context) => VersionBloc(context.read<CheckVersion>())..add(CheckVersionEvent()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'App Version Checker',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const SplashPage(),
        ),
      ),
    );
  }
}