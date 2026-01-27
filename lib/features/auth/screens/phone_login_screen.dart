
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/mongo_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/dashboard_screen.dart';
import 'user_details_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (!_codeSent)
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (e.g. +919359742537)',
                  hintText: 'Include country code with +',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              )
            else
              Column(
                children: [
                  const Text('Enter the 6-digit code sent to your phone'),
                  const SizedBox(height: 16),
                  Pinput(
                    length: 6,
                    controller: _otpController,
                    onCompleted: (pin) => _verifyOtp(pin),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : (_codeSent ? () => _verifyOtp(_otpController.text) : _verifyPhone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_codeSent ? 'Verify' : 'Send Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    String phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid phone number")));
      setState(() => _isLoading = false);
      return;
    }

    // Basic auto-fix for missing +
    if (!phone.startsWith('+')) {
      // Prompt user or assume? User in image had 9359742537. 
      // This looks like an Indian number (10 digits) or similar.
      // I'll just warn the user or add a small helper.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please include country code starting with +"))
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      await authService.verifyPhoneNumber(
        phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Verification Failed: ${e.message}")));
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (_verificationId == null || otp.length < 6) return;
    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid OTP: $e")));
      }
    }
  }

  Future<void> _signInWithCredential(AuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        if (!mounted) return;
        final mongoService = Provider.of<MongoService>(context, listen: false);
        final userDoc = await mongoService.getUser(user.uid);

        if (!mounted) return;

        if (userDoc != null && userDoc['isRegistered'] == true) {
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(builder: (_) => const DashboardScreen()),
             (route) => false,
           );
        } else {
           Navigator.pushAndRemoveUntil(
             context,
             MaterialPageRoute(
               builder: (_) => UserDetailsScreen(
                 uid: user.uid,
                 phoneNumber: user.phoneNumber,
               ),
             ),
             (route) => false,
           );
        }
      }
    } catch (e) {
       if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign In Failed: $e")));
       }
    }
  }
}
