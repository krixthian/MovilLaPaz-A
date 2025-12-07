import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';

class RegistroKardexScreen extends StatefulWidget {
  const RegistroKardexScreen({super.key});

  @override
  State<RegistroKardexScreen> createState() => _RegistroKardexScreenState();
}

class _RegistroKardexScreenState extends State<RegistroKardexScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _ciController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  
  bool _isLoading = false;
  int _selectedItemId = 1; // Default ID (ej. "Falta uniforme")

  List<Map<String, dynamic>> _itemsKardex = [];
  List<Map<String, dynamic>> _estudiantes = [];
  String? _selectedCiEstudiante;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    
    // Cargar ítems de kárdex
    final resultItems = await _apiService.getKardexItems();
    
    // Cargar estudiantes del curso actual
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final curso = auth.currentCurso;
    Map<String, dynamic> resultEstudiantes = {'ok': false};
    
    if (curso != null) {
      resultEstudiantes = await _apiService.getEstudiantesCurso(curso['id']);
    }

    if (mounted) {
      setState(() {
        // Procesar ítems
        if (resultItems['ok'] == true) {
          _itemsKardex = List<Map<String, dynamic>>.from(resultItems['items']);
          if (_itemsKardex.isNotEmpty) {
            _selectedItemId = _itemsKardex[0]['id'];
          }
        }
        
        // Procesar estudiantes
        if (resultEstudiantes['ok'] == true) {
          _estudiantes = List<Map<String, dynamic>>.from(resultEstudiantes['estudiantes']);
          if (_estudiantes.isNotEmpty) {
            _selectedCiEstudiante = _estudiantes[0]['ci'];
          }
        }
        
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCiEstudiante == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un estudiante')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.postKardex(
      _selectedCiEstudiante!,
      _selectedItemId,
      _obsController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro guardado correctamente'),
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
      appBar: AppBar(title: Text('Kárdex - $nombreCurso')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Estudiante", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCiEstudiante,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      hint: const Text("Seleccione un estudiante"),
                      items: _estudiantes.map((est) {
                        return DropdownMenuItem<String>(
                          value: est['ci'],
                          child: Text(est['nombre'], overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCiEstudiante = val);
                      },
                      validator: (val) => val == null ? 'Seleccione un estudiante' : null,
                      isExpanded: true,
                    ),
                    
                    const SizedBox(height: 20),
                    const Text("Motivo / Ítem", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedItemId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: _itemsKardex.map((item) {
                        // User requested to remove points display: "(-10pts)"
                        return DropdownMenuItem<int>(
                          value: item['id'],
                          child: Text(item['descripcion'], overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedItemId = val);
                      },
                      isExpanded: true,
                    ),

                    const SizedBox(height: 20),
                    const Text("Observación (Opcional)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(
                        hintText: 'Detalles adicionales...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 200,
                      validator: (val) => Validators.validateRequiredText(val, minLength: 0),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarRegistro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('GUARDAR REGISTRO'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
