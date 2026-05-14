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

  @override
  List<Object?> get props => [id, name, description, createdAt, contactCount];
}
