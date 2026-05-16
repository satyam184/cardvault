import 'package:equatable/equatable.dart';

class ContactFolder extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int contactCount;

  const ContactFolder({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.contactCount = 0,
  });

  factory ContactFolder.fromJson(Map<String, dynamic> json) {
    return ContactFolder(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      contactCount: json['contactsCount'] ?? json['contactCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, contactCount];
}
