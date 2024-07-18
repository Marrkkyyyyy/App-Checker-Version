import '../entities/version_status.dart';
import '../../data/repositories/version_repository.dart';

class CheckVersion {
  final VersionRepository repository;

  CheckVersion(this.repository);

  Future<(VersionStatus, String)> execute() async {
    // Get the latest version from the API and the installed version
    final latestVersion = await repository.getLatestVersion();
    final installedVersion = await repository.getInstalledVersion();

    // If we couldn't get the latest version, proceed with the app
    if (latestVersion == null || !latestVersion.isValid) {
      return (VersionStatus.proceedToApp, installedVersion);
    }

    print('Current version: ${latestVersion.currentVersion}');
    print('Minimum version: ${latestVersion.minimumVersion}');
    print('Installed version: $installedVersion');

    // Compare versions and return the appropriate status
    if (isVersionLower(installedVersion, latestVersion.minimumVersion!)) {
      return (VersionStatus.updateRequired, latestVersion.currentVersion!);
    } else if (isVersionLower(
        installedVersion, latestVersion.currentVersion!)) {
      return (VersionStatus.updateAvailable, latestVersion.currentVersion!);
    } else {
      return (VersionStatus.upToDate, latestVersion.currentVersion!);
    }
  }

  // Helper method to compare version strings
  bool isVersionLower(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return true;
      if (v1Parts[i] > v2Parts[i]) return false;
    }

    return false;
  }
}
