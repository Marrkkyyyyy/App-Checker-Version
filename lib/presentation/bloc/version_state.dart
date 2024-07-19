import 'package:version_checker/data/entities/version_status.dart';

abstract class VersionState {}

class VersionInitial extends VersionState {}

class VersionLoading extends VersionState {}

class VersionChecked extends VersionState {
  final VersionStatus status;
  final String currentVersion;

  VersionChecked(this.status, this.currentVersion);
}

class VersionError extends VersionState {
  final String message;

  VersionError(this.message);
}

