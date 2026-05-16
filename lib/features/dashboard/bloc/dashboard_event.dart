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
