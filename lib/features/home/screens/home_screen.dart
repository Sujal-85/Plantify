import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:plant_analysis/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../scan/screens/scan_screen.dart';
import '../../identify/screens/identify_screen.dart';
import '../../../core/services/database_service.dart';
import '../../history/screens/history_detail_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../../core/services/weather_service.dart';
import '../widgets/youtube_player_widget.dart';
import 'ai_assistant_screen.dart';
import '../widgets/survey_card.dart';
import 'ai_assistant_welcome_screen.dart';
import 'crop_selection_screen.dart';
import '../../../core/services/preference_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';

import '../../settings/screens/settings_screen.dart';
import '../../settings/screens/feedback_screen.dart';
import '../../settings/screens/contact_screen.dart';
import '../../settings/screens/thanks_screen.dart';
import '../../settings/screens/legal_screen.dart';
import '../../settings/screens/quickstart_screen.dart';
import '../../tools/screens/fertilizer_calculator_screen.dart';
import '../../tools/screens/pesticide_calculator_screen.dart';
import '../../tools/screens/farming_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Future<WeatherData>? _weatherFuture;
  
  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: false, // Ensure left alignment
        elevation: 0,
        titleSpacing: 8, // Shifted left per request
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            AppLocalizations.of(context)!.appTitle, // "Plantix"
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Material(
              color: const Color(0xFFE3E4FC), 
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  final prefs = Provider.of<PreferenceService>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => prefs.hasSeenAIAssistantWelcome
                          ? const AIAssistantScreen()
                          : const AIAssistantWelcomeScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                       const Icon(Icons.auto_awesome, color: Color(0xFF001C39), size: 16),
                       const SizedBox(width: 6),
                       Text(
                        AppLocalizations.of(context)!.assistant,
                        style: const TextStyle(
                          color: Color(0xFF001C39),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 'Settings':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  break;
                case 'Feedback':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()));
                  break;
                case 'Recommend':
                  Share.share('Check out Plantify! It helps you diagnose plant diseases and manage your farm efficiently. Download now: https://plantify.app');
                  break;
                case 'Contact':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen()));
                  break;
                case 'Thanks':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ThanksScreen()));
                  break;
                case 'Legal':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen()));
                  break;
                case 'Quickstart':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickstartScreen()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Settings', child: Text(AppLocalizations.of(context)!.settings)),
                PopupMenuItem(value: 'Feedback', child: Text(AppLocalizations.of(context)!.giveFeedback)),
                PopupMenuItem(value: 'Recommend', child: Text(AppLocalizations.of(context)!.recommendApp)),
                PopupMenuItem(value: 'Contact', child: Text(AppLocalizations.of(context)!.contactSocial)),
                PopupMenuItem(value: 'Thanks', child: Text(AppLocalizations.of(context)!.thanks)),
                PopupMenuItem(value: 'Legal', child: Text(AppLocalizations.of(context)!.legalNotices)),
                PopupMenuItem(value: 'Quickstart', child: Text(AppLocalizations.of(context)!.quickstart)),
              ];
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _weatherFuture = _weatherService.fetchWeather();
          });
          await _weatherFuture;
        },
        child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Crops List
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 100,
                child: Consumer<PreferenceService>(
                  builder: (context, prefs, child) {
                    final crops = prefs.selectedCrops;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: crops.length + 1,
                      itemBuilder: (context, index) {
                        if (index < crops.length) {
                          return _buildCropItem(context, crops[index]);
                        } else {
                          return _buildAddCropItem(context);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            
            // Survey Card
            const SurveyCard(),

            // 2. Main Section (Weather + Scan) with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE0F7FA), Colors.white], // Light cyan to white
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.2, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // Weather & Spraying
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<WeatherData>(
                            future: _weatherFuture,
                            builder: (context, snapshot) {
                               // Left card: Weather
                              return _buildWeatherCard(context, snapshot.data);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                           // Right card: Spraying
                          child: _buildSprayingCard(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Take Picture Section
                  Column(
                    children: [
                      // Phone with Plant Illustration
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: const Color(0xFFB9F6CA).withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Placeholder Icon for illustration
                          Transform.rotate(
                             angle: -0.1,
                             child: const Icon(Icons.smartphone_rounded, size: 80, color: Color(0xFF2E3440)),
                          ),
                          const Positioned(
                             child: Icon(Icons.local_florist, color: Color(0xFF4CAF50), size: 40)
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.seeDiagnosis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           _buildDot(false),
                           _buildDot(true), 
                           _buildDot(false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton(
                            context,
                            'Diagnose',
                            Icons.local_hospital_outlined,
                            Colors.blue[700]!,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())),
                          ),
                          const SizedBox(width: 16),
                          _buildActionButton(
                            context,
                            'Identify',
                            Icons.search_outlined,
                            Colors.green[700]!,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IdentifyScreen())),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 3. Recent Activity (History)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Provider.of<DatabaseService>(context, listen: false).getHistory(),
                builder: (context, snapshot) {
                   // Always take up space or show placeholder? 
                   // Screenshot shows a card. If empty, maybe show "No recent diagnoses".
                   if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                   }
                   final history = snapshot.data ?? [];
                   final latestItem = history.isNotEmpty ? history.first : null;
                   
                   if (latestItem == null) return const SizedBox.shrink();

                   return Row(
                     children: [
                       Expanded(
                         flex: 3,
                         child: GestureDetector(
                           onTap: () {
                               Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HistoryDetailScreen(scanItem: latestItem),
                                ),
                              );
                           },
                           child: _buildRecentCard(context, latestItem),
                         ),
                       ),
                       const SizedBox(width: 12),
                       Expanded(
                         flex: 1,
                         child: GestureDetector(
                           onTap: () {
                               Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const HistoryScreen()),
                              );
                           },
                           child: _buildViewAllCard(context),
                         ),
                       ),
                     ],
                   );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 4. Tools Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.tools,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildNewToolCard(
                      context, 
                      AppLocalizations.of(context)!.fertilizerCalculator, 
                      Icons.agriculture_rounded, 
                      false
                  ),
                  _buildNewToolCard(
                      context, 
                      AppLocalizations.of(context)!.pesticideCalculator, 
                      Icons.pest_control_rounded,
                      true
                  ),
                  _buildNewToolCard(
                      context, 
                      AppLocalizations.of(context)!.farmingCalculator, 
                      Icons.calculate_rounded, 
                      true
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 5. Videos Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.topVideos,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildVideoCard(context, '5 Home Remedies for plant disease prevention', 'https://i.ytimg.com/vi/AGtazzeCIz8/hq720.jpg?sqp=-oaymwEnCNAFEJQDSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLAqYVIVFKxXry1yl_eg0oNQGO0mbQ', 'https://youtu.be/AGtazzeCIz8?si=h5xOAtBoQ1NO9KFS'),
                  _buildVideoCard(context, 'Natural Fertilizer best for the plants', 'https://i.ytimg.com/vi/lj21NAUh74E/hq720.jpg?sqp=-oaymwEnCNAFEJQDSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLDfjh1FEMC1wVkk55sTgxwFdVbmzw', 'https://youtu.be/lj21NAUh74E?si=VhZf362YK147vRWO'),
                  _buildVideoCard(context, 'Pest Control Guide which is safe and more natural and organic', 'https://i.ytimg.com/vi/MJY67moFXK0/hq720.jpg?sqp=-oaymwEnCNAFEJQDSFryq4qpAxkIARUAAIhCGAHYAQHiAQoIGBACGAY4AUAB&rs=AOn4CLBzHsbOm9QkuvXEXdZs_U-p_93JlQ', 'https://youtu.be/MJY67moFXK0?si=AbcIxU2mLy-94Svg'),
                ],
              ),
            ),

            const SizedBox(height: 32),



            // 6. Sponsored / Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.sponsored,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            CarouselSlider(
              options: CarouselOptions(
                height: 500,
                autoPlay: true,
                viewportFraction: 0.92,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 4),
              ),
              items: [
                'assets/images/b1.png',
                'assets/images/b3.png',
                'assets/images/b4.png',
                'assets/images/b5.png',
              ].map((assetPath) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                            image: AssetImage(assetPath),
                            fit: BoxFit.cover
                        )
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 140, // Fixed width
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildRecentCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.grey.withOpacity(0.2)),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       child: Row(
         children: [
           ClipRRect(
             borderRadius: BorderRadius.circular(12),
             child: Image.file(
               File(item['imagePath']),
               width: 70,
               height: 70,
               fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) => 
                  Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.image)),
             ),
           ),
           const SizedBox(width: 12),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   DateFormat('d MMM').format(DateTime.parse(item['date'])),
                   style: const TextStyle(color: Colors.grey, fontSize: 12),
                 ),
                 const SizedBox(height: 4),
                 Text(
                   item['diseaseName'],
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                 const SizedBox(height: 8),
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8F9E3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.complete,
                      style: const TextStyle(
                         color: Color(0xFF005C35),
                         fontSize: 10,
                         fontWeight: FontWeight.bold
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

  Widget _buildViewAllCard(BuildContext context) {
    return Container(
       height: 100,
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: Colors.grey.withOpacity(0.2)),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
         ],
       ),
       child: Center(
         child: Text(
            AppLocalizations.of(context)!.viewAll,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF3D45C5),
              fontWeight: FontWeight.bold,
            ),
         ),
       ),
    );
  }

  Widget _buildNewToolCard(BuildContext context, String label, IconData icon, bool isNew) {
    return Container(
      width: 110,
      height: 110, // Fixed square aspect
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
           if (label.contains("Fertilizer")) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const FertilizerCalculatorScreen()));
           } else if (label.contains("Pesticide")) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const PesticideCalculatorScreen()));
           } else if (label.contains("Farming")) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmingCalculatorScreen()));
           }
        },
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF001C39), size: 24),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (isNew)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8DEF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.newBadge,
                  style: const TextStyle(color: Color(0xFF4A4458), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildNewLibraryCardLarge(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      height: 140, // Match height of two small cards stacked
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, // Cultivation Tips
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001C39)),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: CircleAvatar(
               backgroundColor: Colors.white,
               radius: 20,
               child: Icon(icon, color: Colors.black87, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewLibraryCardSmall(BuildContext context, String label, IconData icon, Color color, {bool hasAlert = false}) {
    return Container(
      height: 64, // Half of large card roughly minus gap
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF001C39)),
              maxLines: 2,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                 backgroundColor: Colors.white,
                 radius: 16,
                 child: Icon(icon, color: Colors.black87, size: 18),
              ),
              if (hasAlert)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2)
                    ),
                    child: const Center(
                      child: Text('1', style: TextStyle(color: Colors.white, fontSize: 8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropItem(BuildContext context, String label) {
    final filename = label.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and');
    final assetPath = 'assets/images/crops/$filename.png';

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
              boxShadow: const [
                 BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.asset(
                  assetPath,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        label.characters.first.toUpperCase(),
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCropItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CropSelectionScreen()),
        );
      },
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 8),
            const Text('', style: TextStyle(fontSize: 12)), 
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context, WeatherData? data) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF), // Light Blueish
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0D6F5), width: 1), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data?.date ?? 'Today',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${data?.temperature.toStringAsFixed(0) ?? "25"}°C', // Fallback to 25 to match image if null
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                _getWeatherIcon(data?.condition ?? 'Clear'),
                color: Colors.amber,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'Clear': return Icons.wb_sunny_rounded;
      case 'Partly Cloudy': return Icons.wb_cloudy_rounded;
      case 'Foggy': return Icons.filter_drama_rounded;
      case 'Rain': return Icons.umbrella_rounded;
      case 'Thunderstorm': return Icons.thunderstorm_rounded;
      default: return Icons.wb_sunny_rounded;
    }
  }

  Widget _buildSprayingCard(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light Greenish
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Spraying conditions',
            style: TextStyle(color: Colors.black54, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Optimal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Color(0xFFC8F9E3),
                      shape: BoxShape.circle
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF005C35), size: 16)
              ),
            ],
          ),
           const Text(
            'until 10 am',
            style: TextStyle(color: Colors.black54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF0055D4) : Colors.grey[300],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String thumbUrl, String videoUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YoutubePlayerWidget(
              videoUrl: videoUrl,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: thumbUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.error)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
