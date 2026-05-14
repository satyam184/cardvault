import 'package:flutter_bloc/flutter_bloc.dart';
import 'folder_event.dart';
import 'folder_state.dart';
import '../../../data/models/contact_model.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  FolderBloc() : super(FolderInitial()) {
    on<LoadFolderContacts>((event, emit) async {
      emit(FolderLoading());
      
      // Mock Data
      await Future.delayed(const Duration(seconds: 1));
      
      final mockContacts = [
        BusinessContact(
          id: '1',
          name: 'John Doe',
          company: 'TechCorp',
          jobTitle: 'Senior Engineer',
          email: 'john@techcorp.com',
          phone: '+1 234 567 890',
          folderId: event.folderId,
          createdAt: DateTime.now(),
        ),
        BusinessContact(
          id: '2',
          name: 'Jane Smith',
          company: 'DesignStudio',
          jobTitle: 'Creative Director',
          email: 'jane@designstudio.io',
          phone: '+1 987 654 321',
          folderId: event.folderId,
          createdAt: DateTime.now(),
          isFavorite: true,
        ),
        BusinessContact(
          id: '3',
          name: 'Robert Brown',
          company: 'FinLeap',
          jobTitle: 'Product Manager',
          email: 'robert@finleap.com',
          phone: '+1 555 000 111',
          folderId: event.folderId,
          createdAt: DateTime.now(),
        ),
      ];

      emit(FolderLoaded(
        contacts: mockContacts,
        filteredContacts: mockContacts,
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
