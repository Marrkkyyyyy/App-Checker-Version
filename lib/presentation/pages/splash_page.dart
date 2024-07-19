import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_checker/data/entities/version_status.dart';
import 'package:version_checker/presentation/bloc/version_bloc.dart';
import 'package:version_checker/presentation/bloc/version_state.dart';
import 'package:version_checker/presentation/pages/home_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VersionBloc, VersionState>(
        listener: (context, state) {
          if (state is VersionChecked) {
            _handleVersionState(context, state);
          }
        },
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.update, size: 100, color: Colors.blue),
                const SizedBox(height: 20),
                Text(_getStatusText(state)),
                if (state is VersionLoading) const CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(VersionState state) {
    if (state is VersionLoading) return 'Checking for updates...';
    if (state is VersionError) return 'Error: ${state.message}';
    return 'Welcome!';
  }

  void _handleVersionState(BuildContext context, VersionChecked state) {
    switch (state.status) {
      case VersionStatus.upToDate:
      case VersionStatus.proceedToApp:
        _navigateToHome(context);
        break;
      case VersionStatus.updateAvailable:
        _showUpdateDialog(context, false, state.currentVersion);
        break;
      case VersionStatus.updateRequired:
        _showUpdateDialog(context, true, state.currentVersion);
        break;
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

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
            if (!isRequired)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey,
                ),
                onPressed: () async {
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
              onPressed: () => _launchAppStore(context),
              child: Text(isRequired ? 'Update' : 'Okay'),
            ),
          ],
        );
      },
    );
  }

  void _launchAppStore(BuildContext context) async {
    final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.FarmFinds.ecommerce&hl=en_US');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch store page')),
      );
    }
  }
}
