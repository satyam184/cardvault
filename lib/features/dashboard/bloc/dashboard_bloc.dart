import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import '../../../data/models/folder_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>((event, emit) async {
      emit(DashboardLoading());
      
      // Mock Data
      await Future.delayed(const Duration(seconds: 1));
      
      final mockFolders = [
        ContactFolder(
          id: '1',
          name: 'Delhi Conference 2026',
          createdAt: DateTime.now(),
          contactCount: 12,
        ),
        ContactFolder(
          id: '2',
          name: 'Mumbai Expo',
          createdAt: DateTime.now(),
          contactCount: 5,
        ),
        ContactFolder(
          id: '3',
          name: 'Client Meetings',
          createdAt: DateTime.now(),
          contactCount: 28,
        ),
      ];

      emit(DashboardLoaded(
        folders: mockFolders,
        recentContacts: const [], // Empty for now
        totalCards: 45,
      ));
    });

    on<CreateFolder>((event, emit) async {
      // Logic for creating folder (would update state or call repo)
    });
  }
}
