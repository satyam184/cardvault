import '../../core/network/dio_client.dart';
import '../models/contact_model.dart';
import '../models/folder_model.dart';

class ContactRepository {
  final DioClient _dioClient;
  final List<BusinessContact> _contacts = [];

  ContactRepository(this._dioClient);

  Future<List<ContactFolder>> getFolders() async {
    try {
      final response = await _dioClient.dio.get('/api/folders');
      final List foldersJson = response.data['folders'];
      return foldersJson.map((json) => ContactFolder.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ContactFolder> createFolder(String name, {String? description}) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/folders',
        data: {
          'name': name,
          'description': description ?? '',
        },
      );
      return ContactFolder.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  List<BusinessContact> get contacts => List.unmodifiable(_contacts);

  void saveContact(BusinessContact contact, String folderId) {
    final newContact = contact.copyWith(folderId: folderId);
    _contacts.add(newContact);
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
