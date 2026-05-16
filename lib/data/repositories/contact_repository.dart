import '../../core/network/dio_client.dart';
import '../models/contact_model.dart';
import '../models/folder_model.dart';

class ContactRepository {
  final DioClient _dioClient;

  ContactRepository(this._dioClient);

  Future<List<ContactFolder>> getFolders({int page = 1, int limit = 10}) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/folders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      
      // Safety check for response structure
      if (response.data is Map && response.data.containsKey('folders')) {
        final List foldersJson = response.data['folders'];
        return foldersJson.map((json) => ContactFolder.fromJson(json)).toList();
      } else if (response.data is List) {
        // Fallback if the API returns a direct list
        return (response.data as List).map((json) => ContactFolder.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } catch (e) {
      print('DEBUG: getFolders Error: $e');
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

  Future<ContactFolder> updateFolder(String folderId, String name, {String? description}) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/folders/$folderId',
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

  Future<void> deleteFolder(String folderId) async {
    try {
      await _dioClient.dio.delete('/api/folders/$folderId');
    } catch (e) {
      rethrow;
    }
  }



  Future<List<BusinessContact>> getContacts({
    int page = 1,
    int limit = 15,
    String? folderId,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (folderId != null) queryParams['folderId'] = folderId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dioClient.dio.get(
        '/api/contacts',
        queryParameters: queryParams,
      );

      if (response.data is Map && response.data.containsKey('contacts')) {
        final List contactsJson = response.data['contacts'];
        return contactsJson.map((json) => BusinessContact.fromJson(json)).toList();
      } else if (response.data is List) {
        return (response.data as List).map((json) => BusinessContact.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected API response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BusinessContact> createContact(BusinessContact contact, String folderId) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/contacts',
        data: {
          'folderId': folderId,
          'name': contact.name,
          'company': contact.company ?? '',
          'jobTitle': contact.jobTitle ?? '',
          'email': contact.email ?? '',
          'phone': contact.phone ?? '',
          'website': contact.website ?? '',
          'address': contact.address ?? '',
          'linkedin': '',
          'socialHandles': {
            'instagram': '',
            'twitter': ''
          }
        },
      );
      return BusinessContact.fromJson(response.data['contact']);
    } catch (e) {
      rethrow;
    }
  }

  Future<BusinessContact> updateContact(String contactId, Map<String, dynamic> updateData) async {
    try {
      final response = await _dioClient.dio.patch(
        '/api/contacts/$contactId',
        data: updateData,
      );
      // It seems the API returns the updated contact directly or nested in "contact".
      // Let's handle both based on previous APIs, but the user's example shows the contact directly.
      if (response.data is Map && response.data.containsKey('name') && response.data.containsKey('_id')) {
        return BusinessContact.fromJson(response.data);
      } else if (response.data is Map && response.data.containsKey('contact')) {
        return BusinessContact.fromJson(response.data['contact']);
      }
      return BusinessContact.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _dioClient.dio.delete('/api/contacts/$contactId');
    } catch (e) {
      rethrow;
    }
  }
}
