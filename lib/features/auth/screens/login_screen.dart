import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mongo_service.dart';
// import 'forgot_password_screen.dart'; // Ensure this exists or comment out if unused/todo
import '../widgets/social_login_button.dart';
import '../../home/screens/dashboard_screen.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

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
                    'Welcome Back! 👋',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s continue your green journey today.',
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
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscure: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember me', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                           // Navigator.push... ForgotPassword
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Login
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
                      child: const Text('Log in', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text("or continue with", style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
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
                          onPressed: _isLoading ? () {} : _handleGoogleLogin,
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
        if (_isLoading) const LoadingOverlay(message: 'Logging in...'),
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
          fillColor: const Color(0xFFF8F9FA), // Very light grey
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

  Future<void> _handleGoogleLogin() async {
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
           // Update provider with current user info
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
           
           // Update Local Provider
           userProvider.setRoleFromString('Farmer');
           userProvider.updateProfile(
             name: user.displayName,
             email: user.email,
             phone: user.phoneNumber,
           );
           // Fetch full profile from backend to ensure everything is synced
           await userProvider.fetchUserProfile(email: user.email);

           await mongoService.saveUser({
             'uid': user.uid,
             'name': user.displayName, // Ensure name is saved
             'email': user.email,
             'phoneNumber': user.phoneNumber,
             'role': 'Farmer',
             'profileImage': user.photoURL, // Save photo URL
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
          SnackBar(content: Text('Login Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
