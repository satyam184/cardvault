import '../../../data/models/folder_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../data/repositories/contact_repository.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final ContactRepository repository;

  DashboardBloc({required this.repository})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<CreateFolder>(_onCreateFolder);
    on<UpdateFolder>(_onUpdateFolder);
    on<DeleteFolder>(_onDeleteFolder);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        repository.getFolders(limit: 3),
        repository.getContactStats(),
      ]);

      final folders = results[0] as List<ContactFolder>;
      final totalCards = results[1] as int;

      emit(DashboardLoaded(folders: folders, totalCards: totalCards));
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

  Future<void> _onCreateFolder(
    CreateFolder event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await repository.createFolder(
        event.name,
        description: event.description,
      );
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError('Failed to create folder: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateFolder(
    UpdateFolder event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await repository.updateFolder(
        event.folderId,
        event.name,
        description: event.description,
      );
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError('Failed to update folder: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteFolder(
    DeleteFolder event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      await repository.deleteFolder(event.folderId);
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError('Failed to delete folder: ${e.toString()}'));
    }
  }
}
