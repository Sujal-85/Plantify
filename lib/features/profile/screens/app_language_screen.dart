import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/preference_service.dart';
import '../../../../core/theme/app_colors.dart';

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  // Temporary state for selection before saving
  String? _selectedLanguageCode;

  final List<Map<String, String>> _languages = [
    {'name': 'मराठी', 'sub': 'तुमच्या भाषेत शेती', 'code': 'mr'},
    {'name': 'ಕನ್ನಡ', 'sub': 'ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ ಕೃಷಿ', 'code': 'kn'},
    {'name': 'ગુજરાતી', 'sub': 'ખેતી તમારી ભાષામાં', 'code': 'gu'},
    {'name': 'ଓଡ଼ିଆ', 'sub': 'ଆପଣଙ୍କ ଭାଷାରେ କୃଷି', 'code': 'or'},
    {'name': 'ਪੰਜਾਬੀ', 'sub': 'ਤੁਹਾਡੀ ਭਾਸ਼ਾ ਵਿੱਚ ਖੇਤੀਬਾੜੀ', 'code': 'pa'},
    {'name': 'తెలుగు', 'sub': 'మీ భాషలో వ్యవసాయం', 'code': 'te'},
    {'name': 'മലയാളം', 'sub': 'നിങ്ങളുടെ ഭാഷയിൽ കൃഷി', 'code': 'ml'},
    {'name': 'தமிழ்', 'sub': 'உங்கள் மொழியில் வேளாண்மை', 'code': 'ta'},
    {'name': 'বাংলা', 'sub': 'চাষাবাদ এখন আপনার ভাষায়', 'code': 'bn'},
    {'name': 'اردو', 'sub': 'آپ کی زبان میں کاشتکاری', 'code': 'ur'},
    {'name': 'हिन्दी', 'sub': 'खेતી આપણી ભાષા મેં', 'code': 'hi'},
    {'name': 'English', 'sub': 'Farming in your language', 'code': 'en'},
    {'name': 'Français', 'sub': 'L\'agriculture dans votre langue', 'code': 'fr'},
    {'name': 'Português', 'sub': 'Agricultura no seu idioma', 'code': 'pt'},
    {'name': 'Español', 'sub': 'Información agrícola en su idioma', 'code': 'es'},
    {'name': 'Indonesia', 'sub': 'Bertani dalam bahasa Anda', 'code': 'id'},
    {'name': 'Tiếng Việt', 'sub': 'Làm nông nghiệp bằng ngôn ngữ của bạn', 'code': 'vi'},
    {'name': 'العربية', 'sub': 'الزراعة بلغتك', 'code': 'ar'},
    {'name': 'kiswahili', 'sub': 'Kilimo katika lugha yako', 'code': 'sw'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize selection from current provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = Provider.of<PreferenceService>(context, listen: false);
      setState(() {
        _selectedLanguageCode = prefs.currentLocale.languageCode;
      });
    });
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
        title: const Text(
          'App Language',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguageCode == lang['code'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE3E8FF) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedLanguageCode = lang['code'];
                      });
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      lang['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      lang['sub']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedLanguageCode != null) {
                         Provider.of<PreferenceService>(context, listen: false)
                            .setLocale(Locale(_selectedLanguageCode!));
                         Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
