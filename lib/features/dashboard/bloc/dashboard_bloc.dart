import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../data/repositories/contact_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ContactRepository _repository;

  DashboardBloc({required ContactRepository repository}) 
      : _repository = repository,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<CreateFolder>(_onCreateFolder);
  }

  Future<void> _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final folders = await _repository.getFolders();
      emit(DashboardLoaded(
        folders: folders,
        totalCards: folders.fold(0, (sum, f) => sum + f.contactCount),
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onCreateFolder(CreateFolder event, Emitter<DashboardState> emit) async {
    try {
      await _repository.createFolder(event.name, description: event.description);
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError('Failed to create folder: ${e.toString()}'));
    }
  }
}
