import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../data/datos_locales.dart';
import '../widgets/book_cover.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>)? onSessionUpdated;
  const LibraryScreen({super.key, required this.session, this.onSessionUpdated});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<dynamic> _libros = [];
  List<dynamic> _filtrados = [];
  bool _loading = true;
  String _busqueda = '';
  int? _edadFiltro;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mostrar datos locales de inmediato — sin esperar al backend
    _libros = DatosLocales.getLibros();
    _filtrados = List.from(_libros);
    _loading = false;
    // Intentar actualizar desde la red en segundo plano
    WidgetsBinding.instance.addPostFrameCallback((_) => _actualizarDesdeRed());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _actualizarDesdeRed() async {
    try {
      final token = widget.session['token'] as String?;
      final libros = await ApiService().getLibros(token: token);
      if (!mounted) return;
      setState(() {
        _libros = libros;
        _aplicarFiltros();
      });
    } catch (_) {}
  }

  Future<void> _cargarLibros() async {
    // Pull-to-refresh: intenta red; si falla, datos locales ya están visibles
    await _actualizarDesdeRed();
  }

  void _aplicarFiltros() {
    setState(() {
      _filtrados = _libros.where((l) {
        final titulo = (l['titulo'] as String? ?? '').toLowerCase();
        final autor = (l['autor'] as String? ?? '').toLowerCase();
        final busq = _busqueda.toLowerCase();
        final matchBusq = busq.isEmpty || titulo.contains(busq) || autor.contains(busq);
        final edadMin = (l['edad_min'] as num?)?.toInt() ?? 5;
        final matchEdad = _edadFiltro == null || edadMin <= _edadFiltro!;
        return matchBusq && matchEdad;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols = w > 900 ? 3 : (w > 600 ? 2 : 2);
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildFiltrosEdad(),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
                      : _filtrados.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _cargarLibros,
                              color: AppColors.rosaOscuro,
                              child: GridView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: w > 700 ? 32 : 16, vertical: 12),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  childAspectRatio: 0.72,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                itemCount: _filtrados.length,
                                itemBuilder: (_, i) => _BookCard(
                                  libro: _filtrados[i],
                                  colorIndex: i,
                                  onTap: () => _abrirLibro(_filtrados[i]),
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mis Lecturas', style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto)),
          Text('${_filtrados.length} cuentos disponibles',
              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
        ]),
        const Spacer(),
        const Text('📚', style: TextStyle(fontSize: 32)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.sombraSuave],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) {
            _busqueda = v;
            _aplicarFiltros();
          },
          decoration: InputDecoration(
            hintText: 'Buscar cuento o autor...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.lilaOscuro),
            suffixIcon: _busqueda.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: AppColors.textoSuave),
                    onPressed: () {
                      _searchCtrl.clear();
                      _busqueda = '';
                      _aplicarFiltros();
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltrosEdad() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Text('Edad: ', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textoSuave)),
        const SizedBox(width: 8),
        ...[null, 5, 6, 7].map((e) {
          final sel = _edadFiltro == e;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                _edadFiltro = e;
                _aplicarFiltros();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppColors.rosa : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.rosaOscuro : AppColors.lila, width: 1.5),
                  boxShadow: sel ? [AppColors.sombraRosa] : [],
                ),
                child: Text(e == null ? 'Todos' : '$e años',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: sel ? AppColors.rosaOscuro : AppColors.textoSuave,
                    )),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🔍', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('No encontramos cuentos',
            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 8),
        Text('Intenta con otra búsqueda o filtro',
            style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
      ]),
    );
  }

  void _abrirLibro(Map<String, dynamic> libro) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(
          libro: libro,
          session: widget.session,
          onSessionUpdated: widget.onSessionUpdated,
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final Map<String, dynamic> libro;
  final int colorIndex;
  final VoidCallback onTap;

  const _BookCard({
    required this.libro,
    required this.colorIndex,
    required this.onTap,
  });

  static const _levelEmojis = ['⭐', '⭐⭐', '⭐⭐⭐'];
  static const _ageColors = {5: Color(0xFFFFE4F0), 6: Color(0xFFEDE4FF), 7: Color(0xFFDBF0FF)};

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.tarjetas[colorIndex % AppColors.tarjetas.length];
    final portadaUrl = ApiService.resolveStaticUrl(libro['portada_url'] as String? ?? '');
    final edadMin = (libro['edad_min'] as num?)?.toInt() ?? 5;
    final autor = libro['autor'] as String? ?? 'Anónimo';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.sombraSuave],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: BookCoverWidget(
                  portadaUrl: portadaUrl,
                  titulo: libro['titulo'] as String? ?? '',
                  index: colorIndex,
                ),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(libro['titulo'] as String? ?? '',
                        style: GoogleFonts.baloo2(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(autor,
                        style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _ageColors[edadMin] ?? AppColors.rosa.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$edadMin+ años',
                            style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700,
                                color: AppColors.rosaOscuro)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
