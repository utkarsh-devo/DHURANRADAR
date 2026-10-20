import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/briefing_provider.dart';
import '../widgets/language_toggle.dart';
import 'briefing_tab.dart';
import 'reports_tab.dart';
import 'info_tab.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [BriefingTab(), ReportsTab(), InfoTab()];

  @override
  Widget build(BuildContext context) {
    final briefingProvider = context.watch<BriefingProvider>();
    final isHindi = briefingProvider.isHindi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.radar, color: Colors.orangeAccent, size: 22),
            const SizedBox(width: 8),
            const Text(
              'DhuanRadar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.ashaPink.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ashaPink.withOpacity(0.5)),
              ),
              child: const Text(
                'ASHA / ANM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: const [LanguageToggle(), SizedBox(width: 12)],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.wb_twilight_outlined),
            activeIcon: const Icon(Icons.wb_twilight),
            label: isHindi ? 'शाम की ब्रीफिंग' : 'Briefing',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fact_check_outlined),
            activeIcon: const Icon(Icons.fact_check),
            label: isHindi ? 'ग्राउंड चेक' : 'Ground Checks',
          ),
          // BottomNavigationBarItem(S
          //   icon: const Icon(Icons.info_outline),
          //   activeIcon: const Icon(Icons.info),
          //   label: isHindi ? 'नियम व जानकारी' : 'System Rules',
          // ),
        ],
      ),
    );
  }
}
