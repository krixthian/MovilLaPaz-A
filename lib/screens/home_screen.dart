import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userData;
    
    // Datos del hijo seleccionado
    final currentHijo = auth.currentHijo;
    final nombreEstudiante = currentHijo?['nombre_completo'] ?? currentHijo?['nombreEstudiante'] ?? user?['nombreEstudiante'] ?? 'Estudiante';
    final curso = currentHijo?['curso'] ?? user?['curso'] ?? '';
    final hijos = auth.hijos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de Hijo (si tiene más de uno)
            if (hijos.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: currentHijo?['ci'],
                    hint: const Text("Seleccionar estudiante"),
                    items: hijos.map<DropdownMenuItem<String>>((h) {
                      return DropdownMenuItem<String>(
                        value: h['ci'],
                        child: Text(h['nombre_completo'] ?? h['nombreEstudiante']),
                      );
                    }).toList(),
                    onChanged: (String? ci) {
                      if (ci != null) {
                        final seleccionado = hijos.firstWhere((h) => h['ci'] == ci);
                        auth.seleccionarHijo(seleccionado);
                      }
                    },
                  ),
                ),
              ),

            Card(
              elevation: 4,
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF1A237E),
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreEstudiante,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (curso.isNotEmpty)
                            Text(
                              curso,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Menú Principal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _MenuCard(
                  icon: Icons.account_circle,
                  title: 'Perfil',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
                _MenuCard(
                  icon: Icons.calendar_today,
                  title: 'Asistencia',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/attendance'),
                ),
                _MenuCard(
                  icon: Icons.assignment,
                  title: 'Kárdex',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/kardex'),
                ),
                _MenuCard(
                  icon: Icons.notifications,
                  title: 'Citaciones',
                  color: Colors.red,
                  onTap: () => Navigator.pushNamed(context, '/citaciones'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
