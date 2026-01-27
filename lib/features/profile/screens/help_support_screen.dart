import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildContactButton('Customer Service', Icons.headset_mic_outlined),
          const SizedBox(height: 16),
          _buildContactButton('WhatsApp', Icons.chat_bubble_outline),
          const SizedBox(height: 16),
          _buildContactButton('Website', Icons.language_outlined),
          const SizedBox(height: 16),
          _buildContactButton('Facebook', Icons.facebook_outlined),
          const SizedBox(height: 40),
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFAQItem('How to identify a plant?'),
          _buildFAQItem('How to use the diagnostic tool?'),
          _buildFAQItem('How to set reminders?'),
          _buildFAQItem('Can I use the app offline?'),
        ],
      ),
    );
  }

  Widget _buildContactButton(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      children: const [
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
