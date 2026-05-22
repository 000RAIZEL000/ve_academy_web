import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final int estudianteId;

  const ProfileScreen({super.key, required this.estudianteId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _estudiante;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await SessionService.getToken();
    final data = await _api.getEstudiante(widget.estudianteId, token: token);
    setState(() {
      _estudiante = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.verde))
          : CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildStatsRow(),
                        const SizedBox(height: 20),
                        _buildStreakCard(),
                        const SizedBox(height: 20),
                        _buildAchievementsCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  SliverAppBar _buildHeader() {
    final nombre = _estudiante?['nombre'] as String? ?? '?';
    final edad = _estudiante?['edad'] as int? ?? 0;
    final avatar = _estudiante?['avatar'] as String? ?? 'panda';
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.headerGradientEnd,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43C6AC), Color(0xFF1a6b5a)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                    Image.network(
                      ApiService.resolveStaticUrl('/static/img/avatars/$avatar.png'),
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        inicial,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  nombre,
                  style: GoogleFonts.baloo2(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$edad años',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final puntos = _estudiante?['puntos'] as int? ?? 0;
    final racha = _estudiante?['racha_actual'] as int? ?? 0;
    final insignias = (_estudiante?['insignias'] as List?)?.length ?? 0;

    return Row(
      children: [
        _StatCard('⭐', '$puntos', 'Puntos', const Color(0xFFffd200), const Color(0xFFf7971e)),
        const SizedBox(width: 12),
        _StatCard('🔥', '$racha', 'Racha', const Color(0xFFff416c), const Color(0xFFff4b2b)),
        const SizedBox(width: 12),
        _StatCard('🏆', '$insignias', 'Logros', const Color(0xFFf6d365), const Color(0xFFfda085)),
      ],
    );
  }

  Widget _buildStreakCard() {
    final racha = _estudiante?['racha_actual'] as int? ?? 0;
    final maxRacha = _estudiante?['max_racha'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFff416c), Color(0xFFff4b2b)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff416c).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Racha actual: $racha ${racha == 1 ? 'día' : 'días'}',
                  style: GoogleFonts.baloo2(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Récord: $maxRacha ${maxRacha == 1 ? 'día' : 'días'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  racha >= maxRacha && racha > 0
                      ? '¡Estás en tu mejor racha! 🌟'
                      : racha > 0
                          ? '¡Sigue así, no pierdas la racha!'
                          : 'Lee hoy para comenzar una racha.',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    final insignias = (_estudiante?['insignias'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏆 Mis Logros',
            style: GoogleFonts.baloo2(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.texto,
            ),
          ),
          const SizedBox(height: 12),
          insignias.isEmpty
              ? const Text(
                  '¡Completa actividades para ganar logros! 📚',
                  style: TextStyle(color: AppColors.gris),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: insignias.map((ins) {
                    final logro = ins['logro'] as Map<String, dynamic>;
                    return _BadgeChip(
                      icono: logro['icono'] as String? ?? '🏆',
                      nombre: logro['nombre'] as String? ?? '',
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color1;
  final Color color2;

  const _StatCard(this.emoji, this.value, this.label, this.color1, this.color2);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color2.withAlpha(80),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.baloo2(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String icono;
  final String nombre;

  const _BadgeChip({required this.icono, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amarillo.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amarillo, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icono, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.naranjaOscuro,
            ),
          ),
        ],
      ),
    );
  }
}
