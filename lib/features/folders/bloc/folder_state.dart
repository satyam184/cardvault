import 'package:equatable/equatable.dart';
import '../../../data/models/contact_model.dart';

abstract class FolderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  final List<BusinessContact> contacts;
  final List<BusinessContact> filteredContacts;
  final String? searchQuery;

  FolderLoaded({
    required this.contacts,
    this.filteredContacts = const [],
    this.searchQuery,
  });

  @override
  List<Object?> get props => [contacts, filteredContacts, searchQuery];
}

class FolderError extends FolderState {
  final String message;
  FolderError(this.message);
  @override
  List<Object?> get props => [message];
}
