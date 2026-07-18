class CompanyModel {
  final String id;
  final String name;
  final String? registrationNumber;
  final String? contactPhone;
  final String? contactEmail;

  CompanyModel({
    required this.id,
    required this.name,
    this.registrationNumber,
    this.contactPhone,
    this.contactEmail,
  });

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    return CompanyModel(
      id: map['id'],
      name: map['name'],
      registrationNumber: map['registration_number'],
      contactPhone: map['contact_phone'],
      contactEmail: map['contact_email'],
    );
  }
}