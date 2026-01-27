import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _generalNotifications = true;
  bool _sound = true;
  bool _vibrate = false;
  bool _appUpdates = true;
  bool _newServiceAvailable = false;
  bool _newTipsAvailable = true;

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
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSwitchTile('General Notification', _generalNotifications, (v) => setState(() => _generalNotifications = v)),
          _buildSwitchTile('Sound', _sound, (v) => setState(() => _sound = v)),
          _buildSwitchTile('Vibrate', _vibrate, (v) => setState(() => _vibrate = v)),
          _buildSwitchTile('App Updates', _appUpdates, (v) => setState(() => _appUpdates = v)),
          _buildSwitchTile('New Service Available', _newServiceAvailable, (v) => setState(() => _newServiceAvailable = v)),
          _buildSwitchTile('New Tips Available', _newTipsAvailable, (v) => setState(() => _newTipsAvailable = v)),
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
}
