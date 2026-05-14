import 'package:flutter_bloc/flutter_bloc.dart';
import 'folder_event.dart';
import 'folder_state.dart';
import '../../../data/repositories/contact_repository.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final ContactRepository _repository;

  FolderBloc({required ContactRepository repository}) 
      : _repository = repository,
        super(FolderInitial()) {
    on<LoadFolderContacts>((event, emit) async {
      emit(FolderLoading());
      final contacts = _repository.getContactsByFolder(event.folderId);
      emit(FolderLoaded(
        contacts: contacts,
        filteredContacts: contacts,
      ));
    });

    on<SearchContacts>((event, emit) {
      final currentState = state;
      if (currentState is FolderLoaded) {
        final query = event.query.toLowerCase();
        final filtered = currentState.contacts.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
                 (contact.company?.toLowerCase().contains(query) ?? false);
        }).toList();
        
        emit(FolderLoaded(
          contacts: currentState.contacts,
          filteredContacts: filtered,
          searchQuery: event.query,
        ));
      }
    });
  }
}
