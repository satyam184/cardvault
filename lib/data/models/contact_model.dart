import 'package:equatable/equatable.dart';

class BusinessContact extends Equatable {
  final String id;
  final String name;
  final String? company;
  final String? jobTitle;
  final String? email;
  final String? phone;
  final String? website;
  final String? address;
  final String? linkedin;
  final Map<String, String>? socialHandles;
  final String folderId;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final String? notes;

  const BusinessContact({
    required this.id,
    required this.name,
    this.company,
    this.jobTitle,
    this.email,
    this.phone,
    this.website,
    this.address,
    this.linkedin,
    this.socialHandles,
    required this.folderId,
    this.frontImagePath,
    this.backImagePath,
    this.isFavorite = false,
    required this.createdAt,
    this.notes,
  });

  factory BusinessContact.fromJson(Map<String, dynamic> json) {
    return BusinessContact(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      company: json['company'],
      jobTitle: json['jobTitle'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
      address: json['address'],
      linkedin: json['linkedin'],
      socialHandles: json['socialHandles'] != null
          ? Map<String, String>.from(json['socialHandles'])
          : null,
      folderId: json['folderId'] ?? '',
      frontImagePath: json['frontImageUrl'] ?? json['frontImagePath'],
      backImagePath: json['backImageUrl'] ?? json['backImagePath'],
      isFavorite: json['isFavorite'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'company': company,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'linkedin': linkedin,
      'socialHandles': socialHandles,
      'folderId': folderId,
      'frontImageUrl': frontImagePath,
      'backImageUrl': backImagePath,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  BusinessContact copyWith({
    String? name,
    String? company,
    String? jobTitle,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? linkedin,
    Map<String, String>? socialHandles,
    String? folderId,
    String? frontImagePath,
    String? backImagePath,
    bool? isFavorite,
    String? notes,
  }) {
    return BusinessContact(
      id: id,
      name: name ?? this.name,
      company: company ?? this.company,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      linkedin: linkedin ?? this.linkedin,
      socialHandles: socialHandles ?? this.socialHandles,
      folderId: folderId ?? this.folderId,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        company,
        jobTitle,
        email,
        phone,
        website,
        address,
        linkedin,
        socialHandles,
        folderId,
        frontImagePath,
        backImagePath,
        isFavorite,
        createdAt,
        notes,
      ];
}
