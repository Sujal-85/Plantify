
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../onboarding/onboarding_screen.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/mongo_service.dart';
import '../home/screens/dashboard_screen.dart';
import '../../core/services/preference_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Keep animation
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final mongoService = Provider.of<MongoService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    PreferenceService? prefs;
    try {
      prefs = Provider.of<PreferenceService>(context, listen: false);
    } catch (_) {}

    final user = authService.currentUser;

    if (user != null) {
      // 1. Check local preferences first (Fastest/Offline friendly)
      if (prefs != null && prefs.isRegistered) {
        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const DashboardScreen())
          );
        }
        return;
      }

      // 2. Local check failed, verify with MongoDB
      try {
        final userDoc = await mongoService.getUser(user.uid).timeout(const Duration(seconds: 5));
        if (mounted) {
          if (userDoc != null && userDoc['isRegistered'] == true) {
            // Update local cache for next time
            await prefs?.setRegistered(true);
            final roleString = userDoc['role'] as String?;
            if (roleString != null) {
              userProvider.setRoleFromString(roleString);
              await prefs?.setUserRole(roleString);
            }
            
            if (!mounted) return;
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => const DashboardScreen())
            );
          } else {
            // Auto-register as Farmer and skip details screen
            await prefs?.setRegistered(true);
            await prefs?.setUserRole('Farmer');
            userProvider.setRoleFromString('Farmer');
            
            await mongoService.saveUser({
              'uid': user.uid,
              'email': user.email,
              'phoneNumber': user.phoneNumber,
              'role': 'Farmer',
              'isRegistered': true,
              'registrationDate': DateTime.now().toIso8601String(),
            });

            if (!mounted) return;
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (_) => const DashboardScreen())
            );
          }
        }
      } catch (e) {
        // Connection error? Don't force registration if we suspect they might be registered
        debugPrint("Splash MongoDB check failed: $e");
        if (mounted) {
          // If we can't verify, better to go to dashboard if they got past auth, 
          // or show a warning. For now, let's trust the dashboard to handle sync.
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (_) => const DashboardScreen())
          );
        }
      }
    } else {
      // Not logged in -> Onboarding
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'assets/images/splash.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

