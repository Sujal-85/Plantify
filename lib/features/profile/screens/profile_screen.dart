
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset('assets/images/app_logo.png'),
        ),
        title: Text(
          'Account',
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color, 
            fontWeight: FontWeight.bold, 
            fontSize: 24
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // In a real app, this would re-fetch user profile data
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // User Profile Row
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/my_profile'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFE8F5E9),
                      backgroundImage: userProvider.profileImage.isNotEmpty 
                          ? NetworkImage(userProvider.profileImage) 
                          : null,
                      child: userProvider.profileImage.isEmpty 
                          ? const Icon(Icons.person, size: 40, color: AppColors.primary) 
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userProvider.name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            userProvider.email,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.2)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Upgrade Banner
              _buildUpgradeBanner(context),
              const SizedBox(height: 24),
              // Menu Items
              _buildMenuItem(context, Icons.notifications_outlined, 'Notification', () => Navigator.pushNamed(context, '/notification_settings')),
              _buildMenuItem(context, Icons.shield_outlined, 'Account & Security', () => Navigator.pushNamed(context, '/security')),
              // Skipping Billing & Subscriptions as requested
              _buildMenuItem(context, Icons.payment_outlined, 'Payment Methods', () {}),
              _buildMenuItem(context, Icons.link_outlined, 'Linked Accounts', () => Navigator.pushNamed(context, '/linked_accounts')),
              _buildMenuItem(context, Icons.visibility_outlined, 'App Appearance', () => Navigator.pushNamed(context, '/app_appearance')),
              _buildMenuItem(context, Icons.bar_chart_outlined, 'Data & Analytics', () => Navigator.pushNamed(context, '/data_analytics')),
              _buildMenuItem(context, Icons.help_outline_outlined, 'Help & Support', () => Navigator.pushNamed(context, '/help_support')),
              _buildMenuItem(context, Icons.logout, 'Logout', () async {
                final prefs = Provider.of<PreferenceService>(context, listen: false);
                await authService.signOut();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }, isLogout: true),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.orange, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade Plan to Unlock More!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Enjoy all the benefits and explore more possibilities',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    final color = isLogout ? Colors.redAccent : Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: color,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.2)),
      onTap: onTap,
    );
  }
}
