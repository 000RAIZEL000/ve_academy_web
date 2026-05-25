import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class ShopScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>) onSessionUpdated;
  const ShopScreen({super.key, required this.session, required this.onSessionUpdated});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _items = [];
  Set<int> _comprados = {};
  bool _loading = true;
  int _tab = 0;
  int _puntos = 0;
  late TabController _tabCtrl;

  static const _categorias = ['avatar', 'fondo', 'accesorio'];
  static const _categoriasLabel = ['Avatares 🐼', 'Fondos 🌅', 'Accesorios 🎀'];

  @override
  void initState() {
    super.initState();
    _puntos = (widget.session['puntos'] as num?)?.toInt() ?? 0;
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() => _tab = _tabCtrl.index));
    _cargarTienda();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarTienda() async {
    try {
      final token = widget.session['token'] as String?;
      final id = (widget.session['id'] as num).toInt();
      final api = ApiService();
      final results = await Future.wait([
        api.getObjetosTienda(token: token),
        api.getEstudiante(id, token: token),
      ]);
      final items = results[0] as List<dynamic>;
      final est = results[1] as Map<String, dynamic>;
      final compras = (est['compras'] as List<dynamic>? ?? [])
          .map((c) => (c['objeto']['id'] as num).toInt())
          .toSet();
      setState(() {
        _items = items;
        _comprados = compras;
        _puntos = (est['puntos'] as num?)?.toInt() ?? _puntos;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _comprar(Map<String, dynamic> item) async {
    final precio = (item['precio'] as num).toInt();
    if (_puntos < precio) {
      _mostrarSnack('No tienes suficientes puntos ⭐', isError: true);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('¿Comprar?', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800)),
        content: Text('¿Quieres comprar "${item['nombre']}" por $precio puntos?',
            style: GoogleFonts.nunito(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0),
            child: Text('¡Comprar!', style: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final token = widget.session['token'] as String?;
      final id = (widget.session['id'] as num).toInt();
      final result = await ApiService().comprarObjeto(id, (item['id'] as num).toInt(), token: token);
      final nuevosPuntos = (result['puntos_restantes'] as num).toInt();
      _puntos = nuevosPuntos;
      _comprados.add((item['id'] as num).toInt());
      await SessionService.updatePuntos(nuevosPuntos);
      final updSession = Map<String, dynamic>.from(widget.session)..['puntos'] = nuevosPuntos;
      widget.onSessionUpdated(updSession);
      setState(() {});
      _mostrarSnack('¡Compra realizada! 🎉');
    } catch (e) {
      _mostrarSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _mostrarSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? AppColors.errorTexto : AppColors.exitoTexto,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  List<dynamic> get _itemsFiltrados {
    final cat = _categorias[_tab];
    return _items.where((i) => i['categoria'] == cat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
                      : _itemsFiltrados.isEmpty
                          ? _buildEmpty()
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, childAspectRatio: 0.78,
                                crossAxisSpacing: 12, mainAxisSpacing: 12,
                              ),
                              itemCount: _itemsFiltrados.length,
                              itemBuilder: (_, i) => _ShopItemCard(
                                item: _itemsFiltrados[i] as Map<String, dynamic>,
                                comprado: _comprados.contains((_itemsFiltrados[i]['id'] as num).toInt()),
                                puedePagar: _puntos >= ((_itemsFiltrados[i]['precio'] as num).toInt()),
                                onComprar: () => _comprar(_itemsFiltrados[i] as Map<String, dynamic>),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: Colors.white,
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tienda Virtual', style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.texto)),
          Text('Canjea tus puntos por premios', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave)),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.gradienteLogros,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('⭐', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('$_puntos', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF8B6914))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabCtrl,
        labelStyle: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.nunito(fontSize: 13),
        labelColor: AppColors.rosaOscuro,
        unselectedLabelColor: AppColors.textoSuave,
        indicatorColor: AppColors.rosaOscuro,
        indicatorWeight: 3,
        tabs: _categoriasLabel.map((l) => Tab(text: l)).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🛍️', style: TextStyle(fontSize: 56)),
      const SizedBox(height: 16),
      Text('Pronto habrá más artículos',
          style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      Text('Vuelve más tarde', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
    ]));
  }
}

class _ShopItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool comprado;
  final bool puedePagar;
  final VoidCallback onComprar;

  const _ShopItemCard({
    required this.item, required this.comprado,
    required this.puedePagar, required this.onComprar,
  });

  @override
  Widget build(BuildContext context) {
    final precio = (item['precio'] as num).toInt();
    final emoji = item['emoji'] as String? ?? '🎁';
    final nombre = item['nombre'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.sombraSuave],
        border: comprado ? Border.all(color: AppColors.exitoTexto, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: comprado ? AppColors.exito.withOpacity(0.2) : AppColors.lila.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: item['imagen_url'] != null && (item['imagen_url'] as String).isNotEmpty
                    ? Image.network(
                        ApiService.resolveStaticUrl(item['imagen_url'] as String),
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Text(emoji, style: const TextStyle(fontSize: 52));
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Text(emoji, style: const TextStyle(fontSize: 52)),
                      )
                    : Text(emoji, style: const TextStyle(fontSize: 52)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Column(children: [
              Text(nombre, style: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto),
                  maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              if (comprado)
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.exitoTexto, size: 18),
                  const SizedBox(width: 4),
                  Text('Comprado', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.exitoTexto)),
                ])
              else
                SizedBox(
                  width: double.infinity, height: 38,
                  child: ElevatedButton(
                    onPressed: puedePagar ? onComprar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: puedePagar ? AppColors.rosa : Colors.grey.shade200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('⭐', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$precio', style: GoogleFonts.baloo2(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: puedePagar ? AppColors.texto : Colors.grey)),
                    ]),
                  ),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
