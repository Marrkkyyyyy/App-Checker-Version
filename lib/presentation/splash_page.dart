import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version_checker/data/entities/version_status.dart';
import 'package:version_checker/data/services/check_version.dart';
import 'package:version_checker/presentation/home_page.dart';

class SplashPage extends StatefulWidget {
  final CheckVersion checkVersion;

  const SplashPage({super.key, required this.checkVersion});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool isLoading = true;
  String statusText = 'Checking for updates...';
  VersionStatus? versionStatus;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final (status, version) = await widget.checkVersion.execute();
      setState(() {
        isLoading = false;
        versionStatus = status;
        currentVersion = version;
        statusText = 'Welcome!';
      });
      _handleVersionState(status);
    } catch (e) {
      setState(() {
        isLoading = false;
        statusText = 'Error: ${e.toString()}';
      });
    }
  }

  void _handleVersionState(VersionStatus status) {
    switch (status) {
      case VersionStatus.upToDate:
      case VersionStatus.proceedToApp:
        _navigateToHome();
        break;
      case VersionStatus.updateAvailable:
        _showUpdateDialog(false);
        break;
      case VersionStatus.updateRequired:
        _showUpdateDialog(true);
        break;
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _showUpdateDialog(bool isRequired) {
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
                  _navigateToHome();
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
              onPressed: () => _launchAppStore(),
              child: Text(isRequired ? 'Update' : 'Okay'),
            ),
          ],
        );
      },
    );
  }

  void _launchAppStore() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.update, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(statusText),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
