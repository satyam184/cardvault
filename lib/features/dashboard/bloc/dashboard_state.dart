import 'package:equatable/equatable.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/models/contact_model.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ContactFolder> folders;
  final List<BusinessContact> recentContacts;
  final int totalCards;

  DashboardLoaded({
    required this.folders,
    required this.recentContacts,
    required this.totalCards,
  });

  @override
  List<Object?> get props => [folders, recentContacts, totalCards];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
