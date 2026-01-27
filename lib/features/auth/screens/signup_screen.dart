import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mongo_service.dart';
import '../widgets/social_login_button.dart';
import 'login_screen.dart';
import '../../home/screens/dashboard_screen.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/providers/user_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/welcome');
                }
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Center(
                    child: Lottie.asset(
                      'assets/images/lottie/Re fork farmer.json',
                      height: 160,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Create Account 👤',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Email Field
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Create a password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Signup Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                         // TODO: Implement Signup
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 10,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Sign up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Log in', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("or sign up with", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: SocialLoginButton(
                          icon: FontAwesomeIcons.google,
                          iconColor: Colors.red,
                          label: 'Google',
                          onPressed: _isLoading ? () {} : _handleGoogleSignup,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SocialLoginButton(
                          icon: FontAwesomeIcons.apple,
                          iconColor: Colors.black,
                          label: 'Apple',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading) const LoadingOverlay(message: 'Creating Account...'),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: Colors.black87
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
             color: Colors.grey.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4)
          )
        ]
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: inputType,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          filled: true,
          fillColor: const Color(0xFFF8F9FA), 
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[500],
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignup() async {
    // Same implementation as LoginScreen but for Signup flow
     setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final mongoService = Provider.of<MongoService>(context, listen: false);

    try {
      final userCredential = await authService.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        final user = userCredential.user!;
        final userDoc = await mongoService.getUser(user.uid);

        if (!mounted) return;

        if (userDoc != null && userDoc['isRegistered'] == true) {
           final userProvider = Provider.of<UserProvider>(context, listen: false);
           userProvider.updateProfile(
             name: user.displayName,
             email: user.email,
             phone: user.phoneNumber,
           );
           await userProvider.fetchUserProfile(email: user.email);
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        } else {
           // Auto-register as Farmer and skip details screen
           final prefs = Provider.of<PreferenceService>(context, listen: false);
           final userProvider = Provider.of<UserProvider>(context, listen: false);
           
           await prefs.setRegistered(true);
           await prefs.setUserRole('Farmer');
           
           userProvider.setRoleFromString('Farmer');
           userProvider.updateProfile(
             name: user.displayName,
             email: user.email,
             phone: user.phoneNumber,
           );
           await userProvider.fetchUserProfile(email: user.email);

           await mongoService.saveUser({
             'uid': user.uid,
             'name': user.displayName,
             'email': user.email,
             'phoneNumber': user.phoneNumber,
             'role': 'Farmer',
             'profileImage': user.photoURL,
             'isRegistered': true,
             'registrationDate': DateTime.now().toIso8601String(),
           });

           if (!mounted) return;
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
