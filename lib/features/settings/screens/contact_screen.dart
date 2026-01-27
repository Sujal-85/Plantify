import 'package:flutter/material.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact & Social', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSocialCard('WhatsApp Community', 'Join 10k+ farmers', Icons.chat_bubble, Colors.green),
          _buildSocialCard('Facebook', 'Follow for updates', Icons.facebook, Colors.blue[800]!),
          _buildSocialCard('Instagram', 'Daily farming tips', Icons.camera_alt, Colors.purple),
          _buildSocialCard('YouTube', 'Watch tutorials', Icons.video_library, Colors.red),
          const SizedBox(height: 32),
          const Text('Contact Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primary),
            title: const Text('support@plantify.com'),
            subtitle: const Text('We reply within 24 hours'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: AppColors.primary),
            title: const Text('+1 800 123 4567'),
            subtitle: const Text('Mon-Fri, 9am - 5pm'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
