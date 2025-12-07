import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'mock_data_service.dart';

class ApiService {
  // DEMO MODE: Set to true to use mock data without server
  static const bool useMockData = false;
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Server URL - Production
  static String get baseUrl {
    return 'https://unidad-educativa-la-paz-a.onrender.com/api/v1';
  }

  // Generic request wrapper
  Future<Map<String, dynamic>> _request(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(timeoutDuration);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        // Bad Request usually means validation error or wrong credentials in login
        return {'ok': false, 'error': 'Usuario o contraseña incorrectos'};
      } else if (response.statusCode == 401) {
        return {'ok': false, 'error': 'Sesión expirada o no autorizada'};
      } else if (response.statusCode == 500) {
        return {'ok': false, 'error': 'Error interno del servidor'};
      } else {
        return {'ok': false, 'error': 'Error ${response.statusCode}'};
      }
    } on SocketException {
      return {'ok': false, 'error': 'No hay conexión a internet'};
    } on TimeoutException {
      return {'ok': false, 'error': 'Tiempo de espera agotado'};
    } catch (e) {
      return {'ok': false, 'error': 'Error inesperado: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String ci, String password) async {
    if (useMockData) {
      return MockDataService.login(ci, password);
    }

    final url = Uri.parse('$baseUrl/login/');
    return _request(() => http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ci': ci, 'password': password}),
    ));
  }

  Future<Map<String, dynamic>> getPerfil(String ci) async {
    if (useMockData) {
      return MockDataService.getPerfil(ci);
    }

    final url = Uri.parse('$baseUrl/perfil/?ci_estudiante=$ci');
    return _request(() => http.get(url));
  }

  Future<Map<String, dynamic>> getAsistencia(String ci) async {
    if (useMockData) {
      return MockDataService.getAsistencia(ci);
    }

    final url = Uri.parse('$baseUrl/asistencia/?ci_estudiante=$ci');
    return _request(() => http.get(url));
  }

  Future<Map<String, dynamic>> getKardex(String ci) async {
    if (useMockData) {
      return MockDataService.getKardex(ci);
    }

    final url = Uri.parse('$baseUrl/kardex/?ci_estudiante=$ci');
    return _request(() => http.get(url));
  }

  Future<Map<String, dynamic>> getCitaciones(String ciEstudiante) async {
    if (useMockData) {
      return MockDataService.getCitaciones(ciEstudiante);
    }

    final url = Uri.parse('$baseUrl/citaciones/?ci_estudiante=$ciEstudiante');
    return _request(() => http.get(url));
  }

  // Regente: Obtener estudiantes de un curso
  Future<Map<String, dynamic>> getEstudiantesCurso(int cursoId) async {
    if (useMockData) {
      return MockDataService.getEstudiantesCurso(cursoId);
    }

    final url = Uri.parse('$baseUrl/estudiantes-curso/?curso_id=$cursoId');
    return _request(() => http.get(url));
  }

  // Regente: Obtener ítems de kárdex
  Future<Map<String, dynamic>> getKardexItems() async {
    if (useMockData) {
      return MockDataService.getKardexItems();
    }

    final url = Uri.parse('$baseUrl/kardex-items/');
    return _request(() => http.get(url));
  }

  // Regente: Enviar asistencia
  Future<Map<String, dynamic>> postAsistencia(String fecha, List<Map<String, dynamic>> asistencias) async {
    if (useMockData) {
      return MockDataService.postAsistencia(fecha, asistencias);
    }

    final url = Uri.parse('$baseUrl/regente/asistencia/');
    return _request(() => http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fecha': fecha,
        'asistencias': asistencias,
      }),
    ));
  }

  // Regente: Registrar Kárdex
  Future<Map<String, dynamic>> postKardex(String ciEstudiante, int itemId, String observacion) async {
    if (useMockData) {
      return MockDataService.postKardex(ciEstudiante, itemId, observacion);
    }

    final url = Uri.parse('$baseUrl/regente/kardex/');
    return _request(() => http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ci_estudiante': ciEstudiante,
        'item_id': itemId,
        'observacion': observacion,
      }),
    ));
  }
}
