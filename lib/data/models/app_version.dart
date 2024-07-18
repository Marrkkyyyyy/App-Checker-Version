class AppVersion {
  final String? currentVersion;
  final String? minimumVersion;

  AppVersion({this.currentVersion, this.minimumVersion});

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      currentVersion: json['currentVersion'] as String?,
      minimumVersion: json['minimumVersion'] as String?,
    );
  }

  bool get isValid => currentVersion != null && minimumVersion != null;

  @override
  String toString() =>
      'AppVersion(currentVersion: $currentVersion, minimumVersion: $minimumVersion)';
}
