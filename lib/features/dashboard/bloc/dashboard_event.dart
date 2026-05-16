import 'package:equatable/equatable.dart';
import '../../../data/models/folder_model.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class CreateFolder extends DashboardEvent {
  final String name;
  final String? description;
  CreateFolder(this.name, {this.description});
  @override
  List<Object?> get props => [name, description];
}

class UpdateFolder extends DashboardEvent {
  final String folderId;
  final String name;
  final String? description;
  UpdateFolder(this.folderId, this.name, {this.description});
  @override
  List<Object?> get props => [folderId, name, description];
}

class DeleteFolder extends DashboardEvent {
  final String folderId;
  DeleteFolder(this.folderId);
  @override
  List<Object?> get props => [folderId];
}
