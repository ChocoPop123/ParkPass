import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/glass_widgets.dart';
import '../../theme/theme_mode_controller.dart';
import '../auth/login_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  final supabase = Supabase.instance.client;
  String userEmail = '';
  String fullName = 'Passenger';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        userEmail = user.email ?? 'No email found';

        final profileData = await supabase.from('profiles').select('full_name').eq('id', user.id).maybeSingle();

        if (profileData != null && profileData['full_name'] != null) {
          fullName = profileData['full_name'];
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: colors.accent))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My Profile",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                GlassPanel(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : "P",
                            style: TextStyle(
                              color: colors.buttonText,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GlassPanel(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, color: colors.textSecondary),
                          const SizedBox(width: 12),
                          Text(
                            "Dark Mode",
                            style: TextStyle(color: colors.textPrimary, fontSize: 16),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: ThemeModeController.instance,
                        builder: (context, mode, _) {
                          return Switch(
                            value: mode == ThemeMode.dark,
                            activeThumbColor: colors.accent,
                            onChanged: (v) => ThemeModeController.instance.setDark(v),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GlassGradientButton(
                  label: "Log Out",
                  onTap: _logout,
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
