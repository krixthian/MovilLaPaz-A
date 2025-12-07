import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegenteDashboard extends StatelessWidget {
  const RegenteDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userData;
    final cursos = auth.cursos;
    final nombreUsuario = user?['usuario_nombre'] ?? 'Regente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Regente'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
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
            // Header
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
                      child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombreUsuario,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Regente",
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
              'Mis Cursos Asignados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
            ),
            const SizedBox(height: 16),
            
            if (cursos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("No tienes cursos asignados."),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cursos.length,
                itemBuilder: (context, index) {
                  final curso = cursos[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.class_, color: Colors.white),
                      ),
                      title: Text(
                        curso['nombre'] ?? 'Curso sin nombre',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("${curso['nivel']} ${curso['paralelo']}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        auth.seleccionarCurso(curso);
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: const Text('Tomar Asistencia'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/tomar_asistencia');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.edit_note, color: Colors.purple),
                                title: const Text('Registrar en Kárdex'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/registro_kardex');
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
