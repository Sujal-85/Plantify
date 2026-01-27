import 'package:flutter/material.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildSettingItem(context, 'Language', Icons.language, trailing: 'English'),
          _buildSettingItem(context, 'Theme', Icons.dark_mode_outlined, trailing: 'Light'),
          // const Divider(height: 32),
          _buildSectionHeader('Notifications'),
          _buildSwitchItem('Push Notifications', true),
          _buildSwitchItem('Email Tips', false),
          // const Divider(height: 32),
          _buildSectionHeader('Account'),
          _buildSettingItem(context, 'Edit Profile', Icons.person_outline),
          _buildSettingItem(context, 'Log Out', Icons.logout, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon, {String? trailing, Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (color ?? AppColors.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color ?? AppColors.primary),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: trailing != null ? Text(trailing, style: TextStyle(color: Colors.grey[600])) : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildSwitchItem(String title, bool value) {
    return SwitchListTile(
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: (val) {},
    );
  }
}
