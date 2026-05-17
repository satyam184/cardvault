import 'package:equatable/equatable.dart';

abstract class FolderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFolderContacts extends FolderEvent {
  final String folderId;
  LoadFolderContacts(this.folderId);
  @override
  List<Object?> get props => [folderId];
}

class SearchContacts extends FolderEvent {
  final String query;
  SearchContacts(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadMoreContacts extends FolderEvent {
  final String folderId;
  LoadMoreContacts(this.folderId);
  @override
  List<Object?> get props => [folderId];
}
