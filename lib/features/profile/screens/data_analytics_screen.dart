import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DataAnalyticsScreen extends StatefulWidget {
  const DataAnalyticsScreen({super.key});

  @override
  State<DataAnalyticsScreen> createState() => _DataAnalyticsScreenState();
}

class _DataAnalyticsScreenState extends State<DataAnalyticsScreen> {
  bool _shareUsage = true;
  bool _crashlytics = true;

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
          'Data & Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Your data is processed to improve your experience. We never sell your personal information.',
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildSwitchTile('Share Usage Data', _shareUsage, (v) => setState(() => _shareUsage = v)),
          _buildSwitchTile('Anonymous Crash Reporting', _crashlytics, (v) => setState(() => _crashlytics = v)),
          const SizedBox(height: 32),
          _buildOption('Download My Data', Icons.download_outlined),
          _buildOption('Delete My Account', Icons.delete_outline, isDangerous: true),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String title, IconData icon, {bool isDangerous = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDangerous ? Colors.redAccent : Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.w500,
          color: isDangerous ? Colors.redAccent : Colors.black87,
        ),
      ),
      onTap: () {},
    );
  }
}
