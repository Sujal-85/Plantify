import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _nameController = TextEditingController(text: userProvider.name);
    _emailController = TextEditingController(text: userProvider.email);
    _phoneController = TextEditingController(text: userProvider.phone);
    _birthdateController = TextEditingController(text: userProvider.birthdate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

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
        title: Text(
          AppLocalizations.of(context)!.myProfile,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image with Edit Button
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFFF5F5F5),
                    child: Icon(Icons.person, size: 80, color: Colors.black12),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel(AppLocalizations.of(context)!.fullName),
            _buildTextField(_nameController),
            const SizedBox(height: 24),
            _buildFieldLabel(AppLocalizations.of(context)!.email),
            _buildTextField(_emailController, icon: Icons.email_outlined),
            const SizedBox(height: 24),
            _buildFieldLabel(AppLocalizations.of(context)!.phoneNumber),
            _buildTextField(_phoneController, isPhone: true),
            const SizedBox(height: 24),
            _buildFieldLabel(AppLocalizations.of(context)!.gender),
            _buildDropdownField(),
            const SizedBox(height: 24),
            _buildFieldLabel(AppLocalizations.of(context)!.birthdate),
            _buildTextField(_birthdateController, icon: Icons.calendar_today_outlined),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                 context.read<UserProvider>().updateProfile(
                   name: _nameController.text,
                   email: _emailController.text,
                   phone: _phoneController.text,
                   birthdate: _birthdateController.text,
                 );
                 Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {IconData? icon, bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.black54, size: 20) : (isPhone ? _buildPhonePrefix() : null),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPhonePrefix() {
    return Container(
      width: 80,
      padding: const EdgeInsets.only(left: 20),
      child: const Row(
        children: [
          Text('🇺🇸', style: TextStyle(fontSize: 20)),
          Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGender,
          isExpanded: true,
          items: [AppLocalizations.of(context)!.male, AppLocalizations.of(context)!.female, AppLocalizations.of(context)!.other].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedGender = val!),
        ),
      ),
    );
  }
}
