import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/ai_assistant_screen.dart';
import '../../../core/services/preference_service.dart';
import 'package:provider/provider.dart';

class AIAssistantWelcomeScreen extends StatelessWidget {
  const AIAssistantWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    '🌱',
                    style: TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Welcome to the Plantify\ndigital assistant! 🌱',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[850],
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildSectionHeader('Limitations'),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.shield_outlined,
                'Answers are given as guide but do not replace individual discussion with an advisor.',
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Privacy'),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.shield_outlined,
                'Conversations will be stored to further improve the service. Your data will not be passed to third parties.',
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                Icons.shield_outlined,
                'This service builds on ChatGPT API from OpenAI. By using this service OpenAI\'s provisions as stipulated here apply.',
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = Provider.of<PreferenceService>(context, listen: false);
                    await prefs.setSeenAIAssistantWelcome(true);
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AIAssistantScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2), // Using the blue from image
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start chatting',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[800], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
