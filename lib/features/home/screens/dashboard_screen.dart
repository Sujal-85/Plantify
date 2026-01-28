import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../my_plants/screens/my_plants_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../diagnose/screens/diagnose_tab.dart';
import '../../scan/screens/scan_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../community/screens/community_screen.dart';
import 'package:plant_analysis/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  static void updateIndex(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<DashboardScreenState>();
    if (state != null) {
      state.setState(() {
        state._currentIndex = index;
      });
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityScreen(),
    const DiagnoseTab(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: SizedBox(
            height: 90, // Increased height
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).cardTheme.color,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.spa_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.spa),
                  ),
                  label: AppLocalizations.of(context)!.yourCrops,
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.chat_bubble_outline_rounded),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.chat_bubble_rounded),
                  ),
                  label: AppLocalizations.of(context)!.community,
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.bug_report_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.bug_report_rounded),
                  ),
                  label: AppLocalizations.of(context)!.diagnosis,
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.history_outlined),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.history_rounded),
                  ),
                  label: AppLocalizations.of(context)!.history,
                ),
                BottomNavigationBarItem(
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline_rounded),
                  ),
                  activeIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_rounded),
                  ),
                  label: AppLocalizations.of(context)!.you,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: (_currentIndex == 1 || _currentIndex == 4) 
          ? null 
            : FloatingActionButton(
                heroTag: 'scanner_fab',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );
                },
                backgroundColor: AppColors.primary,
                elevation: 4,
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
