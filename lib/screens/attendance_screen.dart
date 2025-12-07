import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _asistencias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  void _loadAttendance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ci = authProvider.userData?['ciEstudiante'] ?? '';

    if (ci.isNotEmpty) {
      final data = await _apiService.getAsistencia(ci);
      if (mounted) {
        setState(() {
          if (data['ok'] == true) {
            _asistencias = data['items'] ?? [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'presente':
        return Colors.green;
      case 'falta':
        return Colors.red;
      case 'atraso':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asistencias.isEmpty
              ? const Center(child: Text('No hay registros de asistencia'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _asistencias.length,
                  itemBuilder: (context, index) {
                    final item = _asistencias[index];
                    final estado = item['estado'] ?? 'Desconocido';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(estado),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        title: Text(
                          'Fecha: ${item['fecha']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Estado: $estado',
                          style: TextStyle(
                            color: _getStatusColor(estado),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
