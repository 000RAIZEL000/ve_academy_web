import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'games/memory_screen.dart';
import 'games/find_image_screen.dart';
import 'games/order_sentence_screen.dart';
import 'games/complete_word_screen.dart';

class GamesMenuScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const GamesMenuScreen({super.key, required this.session});

  @override
  State<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  List<dynamic> _libros = [];
  bool _loading = true;
  String? _libroSeleccionadoSlug;

  static const _juegos = [
    {
      'key': 'memoria',
      'title': 'Memoria',
      'desc': 'Encuentra los pares de palabras e imágenes',
      'emoji': '🧠',
      'color': Color(0xFFEDE4FF),
    },
    {
      'key': 'palabra_imagen',
      'title': 'Palabra e Imagen',
      'desc': 'Une cada palabra con su imagen correcta',
      'emoji': '🖼️',
      'color': Color(0xFFDBF0FF),
    },
    {
      'key': 'ordenar',
      'title': 'Ordenar Historia',
      'desc': 'Ordena las frases para contar la historia',
      'emoji': '🔀',
      'color': Color(0xFFFDE8F5),
    },
    {
      'key': 'completar',
      'title': 'Completar Palabras',
      'desc': 'Completa las palabras del cuento',
      'emoji': '✏️',
      'color': Color(0xFFFFFBD4),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  Future<void> _cargarLibros() async {
    try {
      final token = widget.session['token'] as String?;
      final libros = await ApiService().getLibros(token: token);
      setState(() {
        _libros = libros;
        if (libros.isNotEmpty) {
          _libroSeleccionadoSlug = libros[0]['slug'] as String;
        }
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _abrirJuego(String juegoKey) {
    if (_libroSeleccionadoSlug == null) return;
    final session = widget.session;
    final slug = _libroSeleccionadoSlug!;

    switch (juegoKey) {
      case 'memoria':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => MemoryScreen(slug: slug, session: session)));
        break;
      case 'palabra_imagen':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => FindImageScreen(slug: slug, session: session)));
        break;
      case 'ordenar':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => OrderSentenceScreen(slug: slug, session: session)));
        break;
      case 'completar':
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => CompleteWordScreen(slug: slug, session: session)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Minijuegos', style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto)),
                        Text('¡Aprende jugando! 🎮', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
                      ]),
                      const Spacer(),
                      const Text('🎯', style: TextStyle(fontSize: 32)),
                    ]),
                    const SizedBox(height: 20),

                    if (_libros.isNotEmpty) ...[
                      Text('Selecciona el cuento:',
                          style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 44,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _libros.length,
                          itemBuilder: (_, i) {
                            final libro = _libros[i] as Map<String, dynamic>;
                            final slug = libro['slug'] as String;
                            final sel = _libroSeleccionadoSlug == slug;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _libroSeleccionadoSlug = slug),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: sel ? AppColors.rosa : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: sel ? AppColors.rosaOscuro : AppColors.lila, width: 1.5),
                                    boxShadow: sel ? [AppColors.sombraRosa] : [],
                                  ),
                                  child: Text(
                                    libro['titulo'] as String? ?? '',
                                    style: GoogleFonts.nunito(
                                        fontSize: 13, fontWeight: FontWeight.w700,
                                        color: sel ? AppColors.rosaOscuro : AppColors.texto),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Text('Elige un juego:',
                        style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: _juegos.map((j) {
                        final enabled = _libroSeleccionadoSlug != null;
                        return GestureDetector(
                          onTap: enabled ? () => _abrirJuego(j['key'] as String) : null,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: (j['color'] as Color).withOpacity(enabled ? 1.0 : 0.5),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [AppColors.sombraSuave],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(j['emoji'] as String, style: const TextStyle(fontSize: 52)),
                                const SizedBox(height: 12),
                                Text(j['title'] as String,
                                    style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.texto),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 6),
                                Text(j['desc'] as String,
                                    style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textoSuave),
                                    textAlign: TextAlign.center, maxLines: 2),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.rosa.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text('+10 puntos',
                                      style: GoogleFonts.nunito(
                                          fontSize: 11, fontWeight: FontWeight.w700,
                                          color: AppColors.rosaOscuro)),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    _buildPuntosInfo(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPuntosInfo() {
    final puntos = (widget.session['puntos'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradienteLogros,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        const Text('⭐', style: TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mis Puntos', style: GoogleFonts.nunito(fontSize: 13, color: Color(0xFF8B6914))),
          Text('$puntos pts', style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF8B6914))),
        ]),
        const Spacer(),
        Text('¡Juega\ny gana!', style: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8B6914)), textAlign: TextAlign.center),
      ]),
    );
  }
}
