import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_version.dart';

class VersionRepository {
  final String apiUrl =
      'https://kiu5fjtqjn7lthcxviiwdxwysu0tpvrt.lambda-url.us-west-2.on.aws/';

  // Fetch the latest version from the API
  Future<AppVersion?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody is Map<String, dynamic> && jsonBody.isNotEmpty) {
          return AppVersion.fromJson(jsonBody);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get the installed version of the app
  Future<String> getInstalledVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
