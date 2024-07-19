import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import '../entities/version_status.dart';
import 'package:http/http.dart' as http;

class CheckVersion {
  final String apiUrl =
      'https://kiu5fjtqjn7lthcxviiwdxwysu0tpvrt.lambda-url.us-west-2.on.aws/';

  Future<(VersionStatus, String)> execute() async {
    try {
      final latestVersion = await _getLatestVersion();
      final installedVersion = await _getInstalledVersion();

      if (latestVersion == null) {
        return (VersionStatus.proceedToApp, installedVersion);
      }

      print('Current version: ${latestVersion['currentVersion']}');
      print('Minimum version: ${latestVersion['minimumVersion']}');
      print('Installed version: $installedVersion');

      if (_isVersionLower(installedVersion, latestVersion['minimumVersion']!)) {
        return (VersionStatus.updateRequired, latestVersion['currentVersion']!);
      } else if (_isVersionLower(
          installedVersion, latestVersion['currentVersion']!)) {
        return (
          VersionStatus.updateAvailable,
          latestVersion['currentVersion']!
        );
      } else {
        return (VersionStatus.upToDate, latestVersion['currentVersion']!);
      }
    } catch (e) {
      print('Error checking version: $e');
      return (VersionStatus.proceedToApp, 'Unknown');
    }
  }

  Future<Map<String, String>?> _getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        return {
          'currentVersion': jsonBody['currentVersion'],
          'minimumVersion': jsonBody['minimumVersion'],
        };
      }
    } catch (e) {
      print('Error fetching latest version: $e');
    }
    return null;
  }

  Future<String> _getInstalledVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  bool _isVersionLower(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return true;
      if (v1Parts[i] > v2Parts[i]) return false;
    }

    return false;
  }
}
