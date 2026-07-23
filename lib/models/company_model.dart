class CompanyModel {
  final String id;
  final String name;
  final String? username;
  final String? registrationNumber;
  final String? contactPhone;
  final String? contactEmail;
  final String? logoUrl;

  CompanyModel({
    required this.id,
    required this.name,
    this.username,
    this.registrationNumber,
    this.contactPhone,
    this.contactEmail,
    this.logoUrl,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'],
      name: map['name'],
      username: map['username'] as String?,
      registrationNumber: map['registration_number'],
      contactPhone: map['contact_phone'],
      contactEmail: map['contact_email'],
      logoUrl: map['logo_url'] as String?,
    );
  }
}