import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_checker/domain/entities/version_status.dart';
import 'package:version_checker/domain/usecases/check_version.dart';
import 'package:version_checker/presentation/bloc/version_bloc.dart';
import 'package:version_checker/presentation/bloc/version_state.dart';
import 'package:version_checker/presentation/pages/home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Initialize the VersionBloc and trigger the version check
      create: (context) =>
          VersionBloc(context.read<CheckVersion>())..add(CheckVersionEvent()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade300, Colors.blue.shade700],
            ),
          ),
          child: BlocConsumer<VersionBloc, VersionState>(
            // Listen for state changes and handle version check results
            listener: (context, state) {
              if (state is VersionChecked) {
                _handleVersionState(context, state);
              }
            },
            // Build the UI based on the current state
            builder: (context, state) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.update,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state is VersionLoading
                          ? 'Checking for updates...'
                          : state is VersionError
                              ? 'Error: ${state.message}'
                              : 'Welcome!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (state is VersionLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Handle different version states
  Future<void> _handleVersionState(
      BuildContext context, VersionChecked state) async {
    switch (state.status) {
      case VersionStatus.upToDate:
      case VersionStatus.proceedToApp:
        // If the app is up to date or we should proceed, navigate to home
        _navigateToHome(context);
        break;
      case VersionStatus.updateAvailable:
        // If an update is available, check if we should show the dialog
        final shouldShowDialog =
            await _shouldShowUpdateDialog(state.currentVersion);
        if (shouldShowDialog) {
          _showUpdateDialog(context, false, state.currentVersion);
        } else {
          _navigateToHome(context);
        }
        break;
      case VersionStatus.updateRequired:
        // If an update is required, show the update dialog
        _showUpdateDialog(context, true, state.currentVersion);
        break;
    }
  }

  // Check if we should show the update dialog based on previously skipped versions
  Future<bool> _shouldShowUpdateDialog(String currentVersion) async {
    final prefs = await SharedPreferences.getInstance();
    final skippedVersion = prefs.getString('skippedVersion');
    return skippedVersion != currentVersion;
  }

  // Navigate to the home page
  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // Show the update dialog
  void _showUpdateDialog(
      BuildContext context, bool isRequired, String currentVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isRequired ? 'Update Required' : 'Update Available',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.system_update,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                isRequired
                    ? 'A new version is required to continue using the app.'
                    : 'A new version of the app is available.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            // Show skip button only for non-required updates
            if (!isRequired)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () async {
                  // Save the skipped version and proceed to home
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('skippedVersion', currentVersion);
                  Navigator.of(context).pop();
                  _navigateToHome(context);
                },
                child: const Text('Skip'),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () async {
                // Open the app store page
                final url = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.FarmFinds.ecommerce&hl=en_US');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not launch store page')),
                  );
                }
              },
              child: Text(isRequired ? 'Update' : 'Okay'),
            ),
          ],
        );
      },
    );
  }
}
