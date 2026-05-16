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
  final bool hasReachedMax;
  final int currentPage;
  final String folderId;

  FolderLoaded({
    required this.contacts,
    this.filteredContacts = const [],
    this.searchQuery,
    this.hasReachedMax = false,
    this.currentPage = 1,
    required this.folderId,
  });

  FolderLoaded copyWith({
    List<BusinessContact>? contacts,
    List<BusinessContact>? filteredContacts,
    String? searchQuery,
    bool? hasReachedMax,
    int? currentPage,
    String? folderId,
  }) {
    return FolderLoaded(
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      searchQuery: searchQuery ?? this.searchQuery,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      folderId: folderId ?? this.folderId,
    );
  }

  @override
  List<Object?> get props => [contacts, filteredContacts, searchQuery, hasReachedMax, currentPage, folderId];
}

class FolderError extends FolderState {
  final String message;
  FolderError(this.message);
  @override
  List<Object?> get props => [message];
}
