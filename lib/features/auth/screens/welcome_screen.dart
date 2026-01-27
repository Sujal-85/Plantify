import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mongo_service.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/providers/user_provider.dart';
import '../widgets/social_login_button.dart';
import '../../home/screens/dashboard_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleSocialSignIn(Future<dynamic> Function() signInMethod) async {
    setState(() => _isLoading = true);
    
    try {
      final userCredential = await signInMethod();
      if (userCredential != null && mounted) {
        final user = userCredential.user;
        if (user != null) {
          // Verify/Sync with MongoDB
          final mongoService = context.read<MongoService>();
          final userProvider = context.read<UserProvider>();
          final prefs = context.read<PreferenceService>();

          final userDoc = await mongoService.getUser(user.uid);
          
          if (mounted) {
            if (userDoc == null) {
              // Auto-register as Farmer for social logins
              await mongoService.saveUser({
                'uid': user.uid,
                'email': user.email,
                'phoneNumber': user.phoneNumber,
                'displayName': user.displayName,
                'role': 'Farmer',
                'isRegistered': true,
                'registrationDate': DateTime.now().toIso8601String(),
              });
              await prefs.setRegistered(true);
              await prefs.setUserRole('Farmer');
              userProvider.setRoleFromString('Farmer');
            } else {
              await prefs.setRegistered(true);
              final role = userDoc['role'] as String? ?? 'Farmer';
              await prefs.setUserRole(role);
              userProvider.setRoleFromString(role);
            }

            // PERSIST USER DATA
            await prefs.saveUserProfile(
              uid: user.uid,
              name: user.displayName ?? 'User',
              email: user.email ?? '',
              photoUrl: user.photoURL,
            );
            userProvider.updateProfile(
              uid: user.uid,
              name: user.displayName ?? 'User',
              email: user.email ?? '',
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),

          Opacity(
            opacity: _isLoading ? 0.5 : 1.0,
            child: AbsorbPointer(
              absorbing: _isLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      
                      const Spacer(flex: 1),
                      
                      Text(
                        "Plantify",
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your smart companion for\nhealthier crops & plants.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                      ),
                      
                      const Spacer(flex: 2),

                      SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        iconColor: Colors.red,
                        label: 'Continue with Google',
                        onPressed: () => _handleSocialSignIn(authService.signInWithGoogle),
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        icon: FontAwesomeIcons.apple,
                        iconColor: Colors.black,
                        label: 'Continue with Apple',
                        onPressed: () => _handleSocialSignIn(authService.signInWithApple),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("or", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignupScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Sign up with Email',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey[600], fontSize: 16),
                            children: const [
                              TextSpan(
                                text: "Log in",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'By continuing, you agree to our Policy & Terms',
                          style: TextStyle(color: Colors.grey[400], fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
