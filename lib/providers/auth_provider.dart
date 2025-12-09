import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  String? _lastError;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userData => _userData;
  String? get lastError => _lastError;
  // Getters de Rol
  String get rol => _userData?['rol'] ?? 'padre';
  bool get esRegente => rol == 'regente';
  bool get esPadre => rol == 'padre';

  // Getters de Listas
  List<dynamic> get hijos => _userData?['hijos'] ?? [];
  List<dynamic> get cursos => _userData?['cursos'] ?? [];

  // Estado Seleccionado
  Map<String, dynamic>? _currentHijo;
  Map<String, dynamic>? _currentCurso;

  Map<String, dynamic>? get currentHijo => _currentHijo;
  Map<String, dynamic>? get currentCurso => _currentCurso;

  void seleccionarHijo(Map<String, dynamic> hijo) {
    _currentHijo = hijo;
    notifyListeners();
  }

  void seleccionarCurso(Map<String, dynamic> curso) {
    _currentCurso = curso;
    notifyListeners();
  }

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null && _userData != null) {
      await prefs.setString('token', _token!);
      // Guardamos userData como JSON string si es necesario, 
      // pero por simplicidad guardaremos los campos clave o todo el json
      // Importante: userData tiene listas, así que jsonEncode es mejor.
      // Necesitamos importar dart:convert arriba si no está.
      // Como _userData es Map<String, dynamic>, usamos jsonEncode.
      // Pero api_service devuelve Map, así que asumimos que es serializable.
    }
  }
  
  // Mejor enfoque: Guardar todo el JSON de respuesta
  Future<void> _persistSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userData != null) {
      await prefs.setString('user_data', json.encode(_userData));
    }
  }

  Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userDataStr = prefs.getString('user_data');
      
      if (userDataStr != null) {
        _userData = json.decode(userDataStr);
        _token = _userData?['token'];
        _isAuthenticated = true;

        // Restaurar selección por defecto
        if (esPadre && hijos.isNotEmpty) {
          _currentHijo = hijos[0];
        }
        if (esRegente && cursos.isNotEmpty) {
          _currentCurso = cursos[0];
        }

        // Reconectar notificaciones
        if (_userData?['usuario_id'] != null) {
          _notificationService.connect(_userData!['usuario_id'].toString());
          // Actualizar nombres de estudiantes
          if (hijos.isNotEmpty) {
             _notificationService.updateStudentNames(hijos);
          }
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error cargando sesión: $e");
    }
    return false;
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<bool> login(String ci, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(ci, password);

    _isLoading = false;
    if (result['ok'] == true) {
      _isAuthenticated = true;
      _token = result['token'];
      _userData = result;
      _lastError = null;

      // Inicializar selección por defecto
      if (esPadre && hijos.isNotEmpty) {
        _currentHijo = hijos[0];
      }
      if (esRegente && cursos.isNotEmpty) {
        _currentCurso = cursos[0];
      }
      
      // Conectar notificaciones
      if (result['usuario_id'] != null) {
        _notificationService.connect(result['usuario_id'].toString());
        // Actualizar nombres de estudiantes para notificaciones
        if (hijos.isNotEmpty) {
           _notificationService.updateStudentNames(hijos);
        }
      }
      
      // Guardar sesión
      await _persistSession();
      
      notifyListeners();
      return true;
    } else {
      _lastError = result['error'] ?? 'Error desconocido';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _notificationService.disconnect();
    _clearSession(); // Borrar persistencia
    _isAuthenticated = false;
    _token = null;
    _userData = null;
    _currentHijo = null;
    _currentCurso = null;
    notifyListeners();
  }
}
