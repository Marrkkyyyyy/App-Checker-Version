import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:version_checker/domain/usecases/check_version.dart';
import 'package:version_checker/presentation/bloc/version_state.dart';

part 'version_event.dart';

class VersionBloc extends Bloc<VersionEvent, VersionState> {
  final CheckVersion checkVersion;

  VersionBloc(this.checkVersion) : super(VersionInitial()) {
    on<CheckVersionEvent>(_onCheckVersion);
  }

  // Handle the CheckVersionEvent
  Future<void> _onCheckVersion(
      CheckVersionEvent event, Emitter<VersionState> emit) async {
    emit(VersionLoading());
    try {
      // Execute the CheckVersion use case
      final (status, currentVersion) = await checkVersion.execute();
      emit(VersionChecked(status, currentVersion));
    } catch (e) {
      emit(VersionError(e.toString()));
    }
  }
}
