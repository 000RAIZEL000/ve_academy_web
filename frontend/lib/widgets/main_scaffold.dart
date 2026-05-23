import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/games_menu_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/ranking_screen.dart';

class MainScaffold extends StatefulWidget {
  final Map<String, dynamic> session;
  const MainScaffold({super.key, required this.session});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late Map<String, dynamic> _session;

  @override
  void initState() {
    super.initState();
    _session = Map<String, dynamic>.from(widget.session);
  }

  void _updateSession(Map<String, dynamic> updated) {
    setState(() => _session = updated);
  }

  static const _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Lecturas'),
    _NavItem(icon: Icons.trending_up_rounded, label: 'Progreso'),
    _NavItem(icon: Icons.store_rounded, label: 'Tienda'),
    _NavItem(icon: Icons.sports_esports_rounded, label: 'Juegos'),
    _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
    _NavItem(icon: Icons.leaderboard_rounded, label: 'Ranking'),
  ];

  List<Widget> _buildScreens() => [
    HomeScreen(session: _session, onNavigate: (i) => setState(() => _currentIndex = i)),
    LibraryScreen(session: _session),
    ProgressScreen(session: _session),
    ShopScreen(session: _session, onSessionUpdated: _updateSession),
    GamesMenuScreen(session: _session),
    ProfileScreen(session: _session, onSessionUpdated: _updateSession),
    RankingScreen(session: _session),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildRail(),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.lila),
            Expanded(child: IndexedStack(index: _currentIndex, children: _buildScreens())),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _buildScreens()),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildRail() {
    return Container(
      width: 88,
      decoration: const BoxDecoration(
        gradient: AppColors.gradienteNavbar,
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Center(child: Text('📚', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 20),
            ...List.generate(_navItems.length, (i) {
              final sel = _currentIndex == i;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withOpacity(0.35) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_navItems[i].icon,
                            color: sel ? AppColors.rosaOscuro : Colors.white,
                            size: 26),
                        const SizedBox(height: 3),
                        Text(_navItems[i].label,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? AppColors.rosaOscuro : Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rosa, AppColors.lila],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lila.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (i) {
              final sel = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withOpacity(0.25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_navItems[i].icon,
                            color: sel ? AppColors.rosaOscuro : Colors.white,
                            size: i == _currentIndex ? 26 : 22),
                        const SizedBox(height: 2),
                        Text(_navItems[i].label,
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              color: sel ? AppColors.rosaOscuro : Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
