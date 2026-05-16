import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/contact_model.dart';
import 'folder_event.dart';
import 'folder_state.dart';
import '../../../data/repositories/contact_repository.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final ContactRepository _repository;
  static const int _limit = 15;

  FolderBloc({required ContactRepository repository})
    : _repository = repository,
      super(FolderInitial()) {
    on<LoadFolderContacts>(_onLoadFolderContacts);
    on<LoadMoreContacts>(_onLoadMoreContacts);
    on<SearchContacts>(_onSearchContacts);
  }

  Future<void> _onLoadFolderContacts(
    LoadFolderContacts event,
    Emitter<FolderState> emit,
  ) async {
    emit(FolderLoading());
    try {
      final contacts = await _repository.getContacts(
        page: 1,
        limit: _limit,
        folderId: event.folderId,
      );
      emit(
        FolderLoaded(
          contacts: contacts,
          filteredContacts:
              contacts, // Server already filtered it or it's page 1
          hasReachedMax: contacts.length < _limit,
          currentPage: 1,
          folderId: event.folderId,
        ),
      );
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }

  Future<void> _onLoadMoreContacts(
    LoadMoreContacts event,
    Emitter<FolderState> emit,
  ) async {
    final currentState = state;
    if (currentState is FolderLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final newContacts = await _repository.getContacts(
          page: nextPage,
          limit: _limit,
          folderId: currentState.folderId,
          search: currentState.searchQuery,
        );

        final allContacts = List<BusinessContact>.from(currentState.contacts)
          ..addAll(newContacts);
        emit(
          currentState.copyWith(
            contacts: allContacts,
            filteredContacts: allContacts,
            hasReachedMax: newContacts.length < _limit,
            currentPage: nextPage,
          ),
        );
      } catch (e) {
        emit(FolderError(e.toString()));
      }
    }
  }

  Future<void> _onSearchContacts(
    SearchContacts event,
    Emitter<FolderState> emit,
  ) async {
    final currentState = state;
    if (currentState is FolderLoaded) {
      // Show loading while searching
      emit(FolderLoading());
      try {
        final searchResults = await _repository.getContacts(
          page: 1,
          limit: _limit,
          folderId: currentState.folderId,
          search: event.query,
        );

        emit(
          FolderLoaded(
            contacts: searchResults,
            filteredContacts: searchResults,
            hasReachedMax: searchResults.length < _limit,
            currentPage: 1,
            folderId: currentState.folderId,
            searchQuery: event.query,
          ),
        );
      } catch (e) {
        emit(FolderError(e.toString()));
      }
    }
  }
}
