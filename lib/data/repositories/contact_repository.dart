import '../models/contact_model.dart';
import '../models/folder_model.dart';

class ContactRepository {
  final List<ContactFolder> _folders = [
    ContactFolder(id: '1', name: 'Delhi Conference 2026', contactCount: 0, createdAt: DateTime.now()),
    ContactFolder(id: '2', name: 'Mumbai Expo', contactCount: 0, createdAt: DateTime.now()),
  ];
  
  final List<BusinessContact> _contacts = [];

  List<ContactFolder> get folders => List.unmodifiable(_folders);
  List<BusinessContact> get contacts => List.unmodifiable(_contacts);

  void addFolder(String name) {
    _folders.add(ContactFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      contactCount: 0,
      createdAt: DateTime.now(),
    ));
  }

  void saveContact(BusinessContact contact, String folderId) {
    final newContact = contact.copyWith(folderId: folderId);
    _contacts.add(newContact);
    
    // Update folder count
    final index = _folders.indexWhere((f) => f.id == folderId);
    if (index != -1) {
      final folder = _folders[index];
      _folders[index] = ContactFolder(
        id: folder.id,
        name: folder.name,
        contactCount: folder.contactCount + 1,
        createdAt: folder.createdAt,
      );
    }
  }

  List<BusinessContact> getContactsByFolder(String folderId) {
    return _contacts.where((c) => c.folderId == folderId).toList();
  }

  void updateContact(BusinessContact updatedContact) {
    final index = _contacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
    }
  }
}
