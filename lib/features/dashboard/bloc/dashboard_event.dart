import 'package:equatable/equatable.dart';
import '../../../data/models/folder_model.dart';
import '../../../data/models/contact_model.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class CreateFolder extends DashboardEvent {
  final String name;
  CreateFolder(this.name);
  @override
  List<Object?> get props => [name];
}
