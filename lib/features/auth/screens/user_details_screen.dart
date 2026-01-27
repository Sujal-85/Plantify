
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/mongo_service.dart'; // Adjust path
import '../../../core/providers/user_provider.dart';
import '../../../core/services/preference_service.dart';
import '../../home/screens/dashboard_screen.dart';
import '../../../core/theme/app_colors.dart';

class UserDetailsScreen extends StatefulWidget {
  final String uid;
  final String? email;
  final String? phoneNumber;

  const UserDetailsScreen({
    super.key,
    required this.uid,
    this.email,
    this.phoneNumber,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _cropsController = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;

  final List<String> _roles = [
    'Farmer',
    'Researcher',
    'Plant Lover',
    'Common User'
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _farmSizeController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete your profile to get the best experience.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              
              _buildTextField(_nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              
              _buildTextField(_phoneController, 'Phone Number', Icons.phone_android_outlined, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'City', Icons.location_city_outlined)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_stateController, 'State', Icons.map_outlined)),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'I am a...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                onChanged: (value) => setState(() => _selectedRole = value),
                validator: (value) => value == null ? 'Please select a role' : null,
              ),
              
              if (_selectedRole == 'Farmer') ...[
                const SizedBox(height: 16),
                _buildTextField(_farmSizeController, 'Farm Size (Acres)', Icons.square_foot_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(_cropsController, 'Primary Crops', Icons.grass_outlined),
              ],
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
    );
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final mongoService = Provider.of<MongoService>(context, listen: false);
        PreferenceService? prefs;
        try {
          prefs = Provider.of<PreferenceService>(context, listen: false);
        } catch (_) {}
        
        final userData = {
          'uid': widget.uid,
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'role': _selectedRole,
          'farmSize': _selectedRole == 'Farmer' ? _farmSizeController.text.trim() : null,
          'primaryCrops': _selectedRole == 'Farmer' ? _cropsController.text.trim() : null,
          'email': widget.email,
          'createdAt': DateTime.now().toIso8601String(),
          'isRegistered': true,
        };

        await mongoService.saveUser(userData);
        await prefs?.setRegistered(true);
        await prefs?.setUserRole(_selectedRole);

        if (mounted) {
          // Update provider state
          Provider.of<UserProvider>(context, listen: false).setRoleFromString(_selectedRole);
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
