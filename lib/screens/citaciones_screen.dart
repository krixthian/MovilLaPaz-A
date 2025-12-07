import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CitacionesScreen extends StatefulWidget {
  const CitacionesScreen({super.key});

  @override
  State<CitacionesScreen> createState() => _CitacionesScreenState();
}

class _CitacionesScreenState extends State<CitacionesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _citaciones = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCitaciones();
  }

  Future<void> _loadCitaciones() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentHijo = auth.currentHijo;
    
    // Si es padre y tiene hijo seleccionado, usar su CI. Si no, usar el del usuario (caso estudiante)
    final ci = currentHijo != null ? currentHijo['ci'] : auth.userData?['usuario_ci'];

    if (ci == null) {
      setState(() {
        _error = "No se pudo identificar al estudiante";
        _isLoading = false;
      });
      return;
    }

    final result = await _apiService.getCitaciones(ci);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['ok'] == true) {
          _citaciones = result['items'] ?? [];
        } else {
          _error = result['error'] ?? 'Error al cargar citaciones';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citaciones'),
        backgroundColor: const Color(0xFF1A237E), // Azul oscuro institucional
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _citaciones.isEmpty
                  ? const Center(child: Text('No hay citaciones registradas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _citaciones.length,
                      itemBuilder: (context, index) {
                        final item = _citaciones[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item['fecha'] ?? 'Sin fecha',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A237E),
                                      ),
                                    ),
                                    _buildEstadoChip(item['estado']),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['motivo'] ?? 'Sin motivo',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Creado: ${item['creado_en']}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildEstadoChip(String? estado) {
    Color color;
    switch (estado) {
      case 'ABIERTA':
        color = Colors.orange;
        break;
      case 'AGENDADA':
        color = Colors.blue;
        break;
      case 'ATENDIDA':
        color = Colors.green;
        break;
      case 'CANCELADA':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        estado ?? 'DESCONOCIDO',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
