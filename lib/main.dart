
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/services/tflite_service.dart';
import 'core/services/database_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/preference_service.dart';
import 'core/services/weather_service.dart';
import 'package:firebase_core/firebase_core.dart';

import 'features/auth/screens/welcome_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/notifications/screens/notification_screen.dart';
import 'features/bookmarks/screens/bookmarks_screen.dart';
import 'features/explore/screens/explore_plants_screen.dart';
import 'features/explore/screens/category_detail_screen.dart';
import 'features/explore/screens/plant_detail_screen.dart';
import 'features/diagnose/screens/diagnosis_results_screen.dart';
import 'features/diagnose/screens/disease_detail_screen.dart';
import 'features/identify/screens/identify_results_screen.dart';
import 'features/identify/screens/identify_error_screen.dart';
import 'features/my_plants/screens/plant_journal_screen.dart';
import 'features/my_plants/screens/set_reminder_screen.dart';
import 'features/profile/screens/my_profile_screen.dart';
import 'features/profile/screens/app_appearance_screen.dart';
import 'features/profile/screens/app_language_screen.dart';
import 'features/profile/screens/notification_settings_screen.dart';
import 'features/profile/screens/security_settings_screen.dart';
import 'features/profile/screens/linked_accounts_screen.dart';
import 'features/profile/screens/data_analytics_screen.dart';
import 'features/profile/screens/help_support_screen.dart';
import 'features/research/screens/article_detail_screen.dart';
import 'features/community/screens/community_screen.dart';
import 'core/services/notification_service.dart';
import 'core/services/sync_service.dart';
import 'core/services/mongo_service.dart';
import 'core/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PreferenceService? prefs;
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp();
    await NotificationService().init();
    prefs = await PreferenceService.init();
  } catch (e) {
    print('Initialization error: $e');
  }
  runApp(AgriVisionApp(prefs: prefs));
}

class AgriVisionApp extends StatelessWidget {
  final PreferenceService? prefs;
  const AgriVisionApp({super.key, this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TFLiteService>(
          create: (_) => TFLiteService()..loadModel(),
          dispose: (_, service) => service.close(),
        ),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider(create: (_) => NotificationService()),
        ProxyProvider3<DatabaseService, MongoService, UserProvider, SyncService>(
          update: (context, db, mongo, user, previous) => 
            previous ?? (SyncService(db, mongo, user)..initialize()),
        ),
        Provider<MongoService>(
          create: (_) => MongoService(),
          dispose: (_, service) => service.close(),
        ),
        Provider<WeatherService>(create: (_) => WeatherService()),
        if (prefs != null) 
          ChangeNotifierProvider<PreferenceService>.value(value: prefs!),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(prefs)),
      ],
      child: Consumer<PreferenceService>(
        builder: (context, prefsService, child) {
          return MaterialApp(
            title: 'Plantify',
            debugShowCheckedModeBanner: false,
            // Localization Configuration
            locale: prefsService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
              Locale('mr'), // Marathi
              Locale('kn'), // Kannada
              Locale('gu'), // Gujarati
              Locale('or'), // Odia
              Locale('pa'), // Punjabi
              Locale('te'), // Telugu
              Locale('ml'), // Malayalam
              Locale('ta'), // Tamil
              Locale('bn'), // Bengali
              Locale('ur'), // Urdu
              Locale('fr'), // French
              Locale('pt'), // Portuguese
              Locale('es'), // Spanish
              Locale('id'), // Indonesian
              Locale('vi'), // Vietnamese
              Locale('ar'), // Arabic
              Locale('sw'), // Swahili
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/search': (context) => const SearchScreen(),
              '/notifications': (context) => const NotificationScreen(),
              '/bookmarks': (context) => const BookmarksScreen(),
              '/article_detail': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                return ArticleDetailScreen(
                  plantName: args['plantName'] ?? 'Plant',
                  initialContent: args['initialContent'],
                );
              },
              '/explore': (context) => const ExplorePlantsScreen(),
              '/category_detail': (context) => const CategoryDetailScreen(),
              '/plant_info': (context) => const PlantInfoScreen(),
              '/diagnose_results': (context) => const DiagnosisResultsScreen(),
              '/disease_detail': (context) => const DiseaseDetailScreen(),
              '/identify_results': (context) => const IdentifyResultsScreen(),
              '/identify_error': (context) => const IdentifyErrorScreen(),
              '/plant_journal': (context) => const PlantJournalScreen(),
              '/set_reminder': (context) => const SetReminderScreen(),
              '/my_profile': (context) => const MyProfileScreen(),
              '/app_appearance': (context) => const AppAppearanceScreen(),
              '/app_language': (context) => const AppLanguageScreen(),
              '/notification_settings': (context) => const NotificationSettingsScreen(),
              '/security': (context) => const SecuritySettingsScreen(),
              '/linked_accounts': (context) => const LinkedAccountsScreen(),
              '/data_analytics': (context) => const DataAnalyticsScreen(),
              '/help_support': (context) => const HelpSupportScreen(),
              '/community': (context) => const CommunityScreen(),
            },
          );
        },
      ),
    );
  }
}
