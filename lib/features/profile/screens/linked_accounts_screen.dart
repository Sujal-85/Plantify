import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({super.key});

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
          'Linked Accounts',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildLinkedTile('Google', true, Icons.g_mobiledata),
          _buildLinkedTile('Facebook', false, Icons.facebook),
          _buildLinkedTile('Apple', false, Icons.apple),
        ],
      ),
    );
  }

  Widget _buildLinkedTile(String name, bool isLinked, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: isLinked ? Colors.black87 : Colors.black26),
          const SizedBox(width: 16),
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(
            isLinked ? 'Connected' : 'Not Connected',
            style: TextStyle(
              color: isLinked ? AppColors.primary : Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
