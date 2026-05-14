import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../data/repositories/contact_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ContactRepository _repository;

  DashboardBloc({required ContactRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    on<LoadDashboard>((event, emit) async {
      emit(DashboardLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      _emitLoaded(emit);
    });

    on<CreateFolder>((event, emit) {
      _repository.addFolder(event.name);
      _emitLoaded(emit);
    });
  }

  void _emitLoaded(Emitter<DashboardState> emit) {
    final folders = _repository.folders;
    emit(DashboardLoaded(
      folders: folders,
      totalCards: folders.fold(0, (sum, f) => sum + f.contactCount),
    ));
  }
}
