import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final int estudianteId;

  const HistoryScreen({super.key, required this.estudianteId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _historial = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await SessionService.getToken();
    final data = await _api.getHistorial(widget.estudianteId, token: token);
    setState(() {
      _historial = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.headerGradientEnd,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFe879f9), Color(0xFFa855f7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 48),
                      Text('📖', style: TextStyle(fontSize: 52)),
                      Text(
                        'Historial de Lecturas',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.morado)),
                )
              : _historial.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('📭', style: TextStyle(fontSize: 64)),
                            SizedBox(height: 16),
                            Text(
                              '¡Aún no has completado ninguna actividad!',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.gris),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _HistoryItem(item: _historial[i]),
                        childCount: _historial.length,
                      ),
                    ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final dynamic item;

  const _HistoryItem({required this.item});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final months = [
        '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
        'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
      ];
      return '${dt.day} ${months[dt.month]}. ${dt.year}';
    } catch (_) {
      return iso.substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = item['libro_titulo'] as String? ?? '?';
    final puntos = item['puntos_obtenidos'] as int? ?? 0;
    final completado = item['completado'] as bool? ?? false;
    final fecha = item['fecha'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
        border: completado
            ? Border.all(color: AppColors.verde.withAlpha(100))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: completado
                  ? AppColors.verde.withAlpha(30)
                  : AppColors.gris.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                completado ? '✅' : '📘',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.texto,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(fecha),
                  style: const TextStyle(fontSize: 12, color: AppColors.gris),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.amarillo.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '⭐ $puntos',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.naranjaOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
