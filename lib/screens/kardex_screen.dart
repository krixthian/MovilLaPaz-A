import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class KardexScreen extends StatefulWidget {
  const KardexScreen({super.key});

  @override
  State<KardexScreen> createState() => _KardexScreenState();
}

class _KardexScreenState extends State<KardexScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _registros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKardex();
  }

  void _loadKardex() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ci = authProvider.userData?['ciEstudiante'] ?? '';

    if (ci.isNotEmpty) {
      final data = await _apiService.getKardex(ci);
      if (mounted) {
        setState(() {
          if (data['ok'] == true) {
            _registros = data['items'] ?? [];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kárdex')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? const Center(child: Text('No hay registros en el kárdex'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _registros.length,
                  itemBuilder: (context, index) {
                    final item = _registros[index];
                    final puntos = item['puntos'] ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['fecha'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['detalle'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
