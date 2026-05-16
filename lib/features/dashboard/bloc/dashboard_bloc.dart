import 'package:dio/dio.dart';
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
      final folders = await _repository.getFolders(limit: 3);
      emit(DashboardLoaded(
        folders: folders,
        totalCards: folders.fold(0, (sum, f) => sum + f.contactCount),
      ));
    } catch (e) {
      String message = e.toString();
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          message = "Connection Timeout. Is the backend running?";
        } else if (e.response?.statusCode == 401) {
          message = "Session expired. Please login again.";
        } else if (e.response?.statusCode == 404) {
          message = "Folders API not found.";
        }
      }
      emit(DashboardError(message));
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
