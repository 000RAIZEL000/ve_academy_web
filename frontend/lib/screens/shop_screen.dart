import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/bubbles_background.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopScreen extends StatefulWidget {
  final int estudianteId;
  const ShopScreen({super.key, required this.estudianteId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> items = [];
  Map<String, dynamic>? estudiante;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedItems = await _apiService.getObjetosTienda();
      final fetchedEstudiante = await _apiService.getEstudiante(widget.estudianteId);
      setState(() {
        items = fetchedItems;
        estudiante = fetchedEstudiante;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _buyItem(int objetoId, String nombre, int precio) async {
    if (estudiante!['puntos'] < precio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Vaya! No tienes suficientes puntos aún. 📚')),
      );
      return;
    }

    final result = await _apiService.comprarObjeto(widget.estudianteId, objetoId);
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Genial! Ya tienes el objeto: $nombre 🎉')),
      );
      _loadData(); // Recargar puntos e inventario
    }
  }

  @override
  Widget build(BuildContext context) {
    return BubblesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.texto),
          title: Text(
            'Tienda de Avatares',
            style: GoogleFonts.baloo2(color: AppColors.texto, fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                backgroundColor: AppColors.amarillo,
                side: BorderSide.none,
                label: Text(
                  '⭐ ${estudiante?['puntos'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
                ),
              ),
            )
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? const Center(child: Text('La tienda está cerrada por hoy 🌙'))
                : GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ShopCard(
                        item: item,
                        onBuy: () => _buyItem(item['id'], item['nombre'], item['precio']),
                      );
                    },
                  ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onBuy;

  const _ShopCard({required this.item, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: AppColors.fondo,
              child: const Icon(Icons.stars, size: 60, color: AppColors.naranja), // Placeholder
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  item['nombre'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.texto),
                ),
                Text(
                  '${item['precio']} pts',
                  style: const TextStyle(color: AppColors.verdeOscuro, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: AppColors.naranja,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onBuy,
                  child: const Text('Canjear', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
