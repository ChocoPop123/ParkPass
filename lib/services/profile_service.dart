import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<String> uploadAvatar(File imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final fileExt = imageFile.path.split('.').last;
    final filePath = '$userId/avatar.$fileExt';

    await supabase.storage.from('avatars').upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

    await supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }
}