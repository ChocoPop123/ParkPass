import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company_model.dart';

class CompanyService {
  final supabase = Supabase.instance.client;

  Future<List<CompanyModel>> getAllCompanies() async {
    final data = await supabase.from('companies').select().order('name');
    return (data as List).map((c) => CompanyModel.fromMap(c)).toList();
  }

  Future<CompanyModel> createCompany({
    required String name,
    required String registrationNumber,
    required String contactPhone,
    required String contactEmail,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    try {
      final data = await supabase
          .from('companies')
          .insert({
        'name': name,
        'registration_number': registrationNumber,
        'contact_phone': contactPhone,
        'contact_email': contactEmail,
        'admin_id': userId,
      })
          .select()
          .single();

      final company = CompanyModel.fromMap(data);
      await supabase.from('profiles').update({'company_id': company.id}).eq('id', userId);
      return company;
    } catch (e) {
      if (e.toString().contains('companies_name_unique')) {
        throw Exception('A company with this name is already registered.');
      }
      rethrow;
    }
  }

  Future<void> updateCompany({
    required String companyId,
    required String name,
    required String registrationNumber,
    required String contactPhone,
    required String contactEmail,
  }) async {
    await supabase.from('companies').update({
      'name': name,
      'registration_number': registrationNumber,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
    }).eq('id', companyId);
  }

  Future<CompanyModel> getCompanyById(String id) async {
    final data = await supabase.from('companies').select().eq('id', id).single();
    return CompanyModel.fromMap(data);
  }

  Future<String> uploadLogo(String companyId, File imageFile) async {
    final fileExt = imageFile.path.split('.').last;
    final filePath = '$companyId/logo.$fileExt';

    await supabase.storage.from('company-logos').upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = supabase.storage.from('company-logos').getPublicUrl(filePath);
    await supabase.from('companies').update({'logo_url': publicUrl}).eq('id', companyId);
    return publicUrl;
  }

  Future<String?> getMyCompanyId() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await supabase.from('profiles').select('company_id').eq('id', userId).single();
    return data['company_id'] as String?;
  }

  Future<List<Map<String, dynamic>>> getPendingConductors(String companyId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('company_id', companyId)
        .eq('role', 'conductor')
        .eq('approval_status', 'pending');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> setConductorApproval(String conductorId, String status) async {
    await supabase.from('profiles').update({'approval_status': status}).eq('id', conductorId);
  }

  Future<int> getApprovedConductorCount(String companyId) async {
    final data = await supabase
        .from('profiles')
        .select('id')
        .eq('company_id', companyId)
        .eq('role', 'conductor')
        .eq('approval_status', 'approved');
    return (data as List).length;
  }
}