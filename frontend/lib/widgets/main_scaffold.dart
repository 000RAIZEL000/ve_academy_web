import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/shop_screen.dart';
import '../screens/games_menu_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/ranking_screen.dart';
import '../services/session_service.dart';
import '../services/progress_service.dart';

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
    HomeScreen(session: _session, onNavigate: (i) => setState(() => _currentIndex = i), onSessionUpdated: _updateSession),
    LibraryScreen(session: _session, onSessionUpdated: _updateSession),
    ProgressScreen(session: _session),
    ShopScreen(session: _session, onSessionUpdated: _updateSession),
    GamesMenuScreen(session: _session, onSessionUpdated: _updateSession),
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
            const AppLogo(size: 48, withShadow: true),
            const SizedBox(height: 6),
            Text(
              'V&E Academy',
              style: GoogleFonts.baloo2(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.25),
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/avatars/${_session['avatar'] as String? ?? 'panda'}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
            const SizedBox(height: 10),
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
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              tooltip: 'Cerrar Sesión',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    title: Text('¿Cerrar Sesión?', style: GoogleFonts.baloo2(fontWeight: FontWeight.w800)),
                    content: const Text('¿Estás seguro de que quieres salir?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No, volver')),
                      ElevatedButton(
                        onPressed: () async {
                          await ProgressService.clearAll();
                          await SessionService.clearSession();
                          if (!mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosaOscuro),
                        child: const Text('Sí, salir'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
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
                        if (i == 5)
                          Container(
                            width: i == _currentIndex ? 28 : 24,
                            height: i == _currentIndex ? 28 : 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: sel ? AppColors.rosaOscuro : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/avatars/${_session['avatar'] as String? ?? 'panda'}.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(Icons.person_rounded,
                                    color: sel ? AppColors.rosaOscuro : Colors.white,
                                    size: 16),
                              ),
                            ),
                          )
                        else
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
