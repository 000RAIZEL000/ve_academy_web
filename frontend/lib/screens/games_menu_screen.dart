import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../data/datos_locales.dart';
import 'games/memory_screen.dart';
import 'games/find_image_screen.dart';
import 'games/order_sentence_screen.dart';
import 'games/complete_word_screen.dart';
import 'games/riddles_screen.dart';
import 'games/word_search_screen.dart';

class GamesMenuScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>)? onSessionUpdated;
  const GamesMenuScreen({super.key, required this.session, this.onSessionUpdated});

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
    {
      'key': 'adivinanzas',
      'title': 'Adivinanzas',
      'desc': '¿Puedes adivinar de qué personaje se trata?',
      'emoji': '🕵️',
      'color': Color(0xFFE2FFE2),
    },
    {
      'key': 'sopa',
      'title': 'Sopa de Letras',
      'desc': 'Encuentra las palabras escondidas',
      'emoji': '🔍',
      'color': Color(0xFFFFF0D4),
    },
  ];

  @override
  void initState() {
    super.initState();
    // Mostrar libros locales de inmediato
    final libros = DatosLocales.getLibros();
    _libros = libros;
    if (libros.isNotEmpty) _libroSeleccionadoSlug = libros[0]['slug'] as String;
    _loading = false;
    // Actualizar desde red en segundo plano
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDesdeRed());
  }

  Future<void> _actualizarDesdeRed() async {
    try {
      final token = widget.session['token'] as String?;
      final libros = await ApiService().getLibros(token: token);
      if (!mounted) return;
      setState(() {
        _libros = libros;
        if (_libroSeleccionadoSlug == null && libros.isNotEmpty) {
          _libroSeleccionadoSlug = libros[0]['slug'] as String;
        }
      });
    } catch (_) {}
  }

  Future<void> _abrirJuego(String juegoKey) async {
    if (_libroSeleccionadoSlug == null) return;
    final session = widget.session;
    final slug = _libroSeleccionadoSlug!;

    Widget screen;
    switch (juegoKey) {
      case 'memoria': screen = MemoryScreen(slug: slug, session: session); break;
      case 'palabra_imagen': screen = FindImageScreen(slug: slug, session: session); break;
      case 'ordenar': screen = OrderSentenceScreen(slug: slug, session: session); break;
      case 'completar': screen = CompleteWordScreen(slug: slug, session: session); break;
      case 'adivinanzas': screen = RiddlesScreen(slug: slug, session: session); break;
      case 'sopa': screen = WordSearchScreen(slug: slug, session: session); break;
      default: return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _refreshSession();
  }

  Future<void> _refreshSession() async {
    try {
      final token = widget.session['token'] as String?;
      if (token == null) return;
      final data = await ApiService().verifyToken(token);
      final newSession = Map<String, dynamic>.from(widget.session);
      newSession['puntos'] = data['puntos'];
      // Solo informar al padre, no mutar localmente para que didUpdateWidget detecte el cambio
      if (widget.onSessionUpdated != null) widget.onSessionUpdated!(newSession);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
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
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          children: _juegos.map((j) {
                            final enabled = _libroSeleccionadoSlug != null;
                            return GestureDetector(
                              onTap: enabled ? () => _abrirJuego(j['key'] as String) : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: (j['color'] as Color).withOpacity(enabled ? 1.0 : 0.5),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [AppColors.sombraSuave],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(j['emoji'] as String, style: const TextStyle(fontSize: 44)),
                                    const SizedBox(height: 10),
                                    Text(j['title'] as String,
                                        style: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.texto),
                                        textAlign: TextAlign.center),
                                    const SizedBox(height: 4),
                                    Text(j['desc'] as String,
                                        style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave),
                                        textAlign: TextAlign.center, maxLines: 2),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.rosa.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text('+10 pts',
                                          style: GoogleFonts.nunito(
                                              fontSize: 10, fontWeight: FontWeight.w700,
                                              color: AppColors.rosaOscuro)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),
                        _buildPuntosInfo(),
                      ],
                    ),
                  ),
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
