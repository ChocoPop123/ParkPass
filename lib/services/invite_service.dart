import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

class InviteService {
  final supabase = Supabase.instance.client;

  /// Generates codes like PP-LINK-7F3A92
  String generateInviteCode(String company) {
    final random = Random();

    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    String suffix = '';

    for (int i = 0; i < 6; i++) {
      suffix += chars[random.nextInt(chars.length)];
    }

    final prefix = company
        .replaceAll(' ', '')
        .toUpperCase()
        .substring(0, min(4, company.length));

    return 'PP-$prefix-$suffix';
  }

  Future<String> createInvite({
    required String operatorId,
    required String companyName,
  }) async {
    final code = generateInviteCode(companyName);

    await supabase.from('conductor_invites').insert({
      'operator_id': operatorId,
      'invite_code': code,
      'used': false,
    });

    return code;
  }

  Future<bool> validateInvite(String code) async {
    final result = await supabase
        .from('conductor_invites')
        .select()
        .eq('invite_code', code)
        .eq('used', false);

    return result.isNotEmpty;
  }

  Future<void> markInviteUsed(String code) async {
    await supabase
        .from('conductor_invites')
        .update({'used': true})
        .eq('invite_code', code);
  }
}