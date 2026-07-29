import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<String> uploadAvatar(XFile imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final fileExt = imageFile.name.split('.').last;
    final filePath = '$userId/avatar.$fileExt';

    // Using readAsBytes() makes this work on Web, Android, and iOS.
    final bytes = await imageFile.readAsBytes();

    await supabase.storage.from('avatars').uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

    await supabase.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);

    return publicUrl;
  }
}
