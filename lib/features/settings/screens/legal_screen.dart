import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Legal Notices', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLegalItem('Terms of Service', 'Last updated: Jan 2025'),
          // const Divider(),
          _buildLegalItem('Privacy Policy', 'Last updated: Jan 2025'),
          // const Divider(),
          _buildLegalItem('Data Usage', 'How we use your crop data'),
          // const Divider(),
          _buildLegalItem('Third Party Licenses', 'Open source software used'),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, String subtitle) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}
