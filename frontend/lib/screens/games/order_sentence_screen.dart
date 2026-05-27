import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';
import '../../data/datos_locales.dart';

class OrderSentenceScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const OrderSentenceScreen({super.key, required this.slug, required this.session});

  @override
  State<OrderSentenceScreen> createState() => _OrderSentenceScreenState();
}

class _OrderSentenceScreenState extends State<OrderSentenceScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  List<String> _oraciones = [];
  int _actual = 0;
  int _correctas = 0;
  bool _completado = false;
  List<String> _palabrasDesordenadas = [];
  List<String> _respuesta = [];
  bool _verificado = false;
  bool _esCorrecto = false;

  @override
  void initState() {
    super.initState();
    final local = DatosLocales.getJuegos(widget.slug);
    if (local != null) {
      _gameData = local;
      _oraciones = List<String>.from(local.oraciones)..shuffle(Random());
      _cargarOracion();
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
    } else {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    try {
      final token = widget.session['token'] as String?;
      final data = await ApiService().getJuegos(widget.slug, token: token);
      if (!mounted || !_loading) return;
      setState(() {
        _gameData = data;
        _oraciones = List<String>.from(data.oraciones)..shuffle(Random());
        _cargarOracion();
        _loading = false;
      });
    } catch (_) {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  void _cargarOracion() {
    if (_oraciones.isEmpty || _actual >= _oraciones.length) return;
    final oracion = _oraciones[_actual];
    _palabrasDesordenadas = oracion.split(' ')..shuffle(Random());
    _respuesta = [];
    _verificado = false;
    _esCorrecto = false;
  }

  void _agregarPalabra(String palabra) {
    if (_verificado) return;
    setState(() {
      _palabrasDesordenadas.remove(palabra);
      _respuesta.add(palabra);
    });
  }

  void _quitarPalabra(String palabra) {
    if (_verificado) return;
    setState(() {
      _respuesta.remove(palabra);
      _palabrasDesordenadas.add(palabra);
    });
  }

  void _verificar() {
    final oracionCorrecta = _oraciones[_actual];
    final respuestaStr = _respuesta.join(' ');
    setState(() {
      _verificado = true;
      _esCorrecto = respuestaStr == oracionCorrecta;
      if (_esCorrecto) _correctas++;
    });
  }

  void _siguiente() {
    if (_actual < _oraciones.length - 1) {
      setState(() { _actual++; _cargarOracion(); });
    } else {
      setState(() => _completado = true);
      _notificarExito();
    }
  }

  Future<void> _notificarExito() async {
    try {
      final token = widget.session['token'] as String?;
      final estudianteId = (widget.session['id'] as num?)?.toInt();
      await ApiService().completarActividad(widget.slug, 'juego_ordenar', token: token, estudianteId: estudianteId);
    } catch (_) {}
  }

  void _reiniciar() {
    setState(() {
      _oraciones.shuffle(Random());
      _actual = 0;
      _correctas = 0;
      _completado = false;
      _cargarOracion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Ordenar Historia 🔀', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
        actions: [
          if (!_completado)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${_actual + 1}/${_oraciones.length}',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textoSuave))),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _oraciones.isEmpty
                    ? _buildVacio()
                    : _completado
                        ? _buildCompletado()
                        : _buildJuego(),
              ),
            ),
    );
  }

  Widget _buildJuego() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_actual + 1) / _oraciones.length,
              backgroundColor: AppColors.rosa.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.rosaOscuro),
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.rosa.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Ordena las palabras para formar la frase correcta:',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.rosaOscuro),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 20),

                // Zona de respuesta
                Text('Tu respuesta:', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 70),
                  child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _verificado
                        ? (_esCorrecto ? AppColors.exito.withOpacity(0.2) : AppColors.error.withOpacity(0.2))
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _verificado ? (_esCorrecto ? AppColors.exitoTexto : AppColors.errorTexto) : AppColors.lila,
                      width: 2,
                    ),
                    boxShadow: [AppColors.sombraSuave],
                  ),
                  child: Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _respuesta.map((p) => GestureDetector(
                      onTap: () => _quitarPalabra(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.lila.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(p, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.lilaOscuro)),
                      ),
                    )).toList(),
                  ),
                ),
                ),

                if (_verificado) ...[
                  const SizedBox(height: 10),
                  Text(
                    _esCorrecto ? '✅ ¡Perfecto!' : '❌ La frase correcta era:\n"${_oraciones[_actual]}"',
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700,
                        color: _esCorrecto ? AppColors.exitoTexto : AppColors.errorTexto),
                  ),
                ],

                const SizedBox(height: 20),

                // Palabras disponibles
                Text('Palabras disponibles:', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _palabrasDesordenadas.map((p) => GestureDetector(
                    onTap: () => _agregarPalabra(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.celeste.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.celesteOscuro, width: 1.5),
                      ),
                      child: Text(p, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.celesteOscuro)),
                    ),
                  )).toList(),
                ),

                const SizedBox(height: 24),

                if (!_verificado)
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _respuesta.isEmpty ? null : _verificar,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: Text('Verificar', style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto)),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _siguiente,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: Text(_actual < _oraciones.length - 1 ? 'Siguiente →' : '¡Ver resultado!',
                          style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletado() => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎉', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 16),
      Text('¡Completado!', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
      Text('$_correctas/${_oraciones.length} frases correctas',
          style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textoSuave)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _reiniciar,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Jugar otra vez', style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
          )),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Volver', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave))),
    ]),
  ));

  Widget _buildVacio() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('🔀', style: TextStyle(fontSize: 56)),
    const SizedBox(height: 16),
    Text('Sin oraciones para este libro', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
  ]));
}
