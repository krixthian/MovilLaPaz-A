import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class TomarAsistenciaScreen extends StatefulWidget {
  const TomarAsistenciaScreen({super.key});

  @override
  State<TomarAsistenciaScreen> createState() => _TomarAsistenciaScreenState();
}

class _TomarAsistenciaScreenState extends State<TomarAsistenciaScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _estudiantes = [];
  
  // Estado local de asistencia: CI -> Estado (PRESENTE, FALTA, ATRASO)
  final Map<String, String> _asistenciaMap = {};

  @override
  void initState() {
    super.initState();
    _cargarEstudiantes();
  }

  Future<void> _cargarEstudiantes() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final curso = auth.currentCurso;
    
    if (curso == null) return;

    setState(() => _isLoading = true);
    
    final result = await _apiService.getEstudiantesCurso(curso['id']);
    
    if (mounted) {
      setState(() {
        if (result['ok'] == true) {
          _estudiantes = List<Map<String, dynamic>>.from(result['estudiantes']);
          
          // Inicializar todos como PRESENTE
          for (var e in _estudiantes) {
            _asistenciaMap[e['ci']] = 'PRESENTE';
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Error al cargar estudiantes')),
          );
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _enviarAsistencia() async {
    setState(() => _isLoading = true);

    final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final List<Map<String, dynamic>> payload = [];

    _asistenciaMap.forEach((ci, estado) {
      payload.add({'ci': ci, 'estado': estado});
    });

    final result = await _apiService.postAsistencia(fecha, payload);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asistencia guardada: ${result['creados']} registros'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al guardar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final curso = auth.currentCurso;
    final nombreCurso = curso?['nombre'] ?? 'Curso Desconocido';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tomar Asistencia - $nombreCurso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _enviarAsistencia,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _estudiantes.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final est = _estudiantes[index];
                final ci = est['ci'];
                final estadoActual = _asistenciaMap[ci] ?? 'PRESENTE';

                return ListTile(
                  title: Text(est['nombre']),
                  subtitle: Text("CI: $ci"),
                  trailing: DropdownButton<String>(
                    value: estadoActual,
                    items: const [
                      DropdownMenuItem(value: 'PRESENTE', child: Text('Presente', style: TextStyle(color: Colors.green))),
                      DropdownMenuItem(value: 'FALTA', child: Text('Falta', style: TextStyle(color: Colors.red))),
                      DropdownMenuItem(value: 'ATRASO', child: Text('Atraso', style: TextStyle(color: Colors.orange))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _asistenciaMap[ci] = val;
                        });
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
