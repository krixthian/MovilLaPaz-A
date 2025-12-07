import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'mock_data_service.dart';

class ApiService {
  // DEMO MODE: Set to true to use mock data without server
  static const bool useMockData = false;

  // Server URL - Using local network IP for physical device
  static String get baseUrl {
    // For physical device APK, use the PC's local network IP
    return 'http://10.0.7.218:8000/api/v1';
    //return 'http://192.168.0.14:8000/api/v1';
  }

  Future<Map<String, dynamic>> login(String ci, String password) async {
    if (useMockData) {
      return MockDataService.login(ci, password);
    }

    final url = Uri.parse('$baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ci': ci, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'ok': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getPerfil(String ci) async {
    if (useMockData) {
      return MockDataService.getPerfil(ci);
    }

    final url = Uri.parse('$baseUrl/perfil/?ci_estudiante=$ci');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ok': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getAsistencia(String ci) async {
    if (useMockData) {
      return MockDataService.getAsistencia(ci);
    }

    final url = Uri.parse('$baseUrl/asistencia/?ci_estudiante=$ci');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ok': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getKardex(String ci) async {
    if (useMockData) {
      return MockDataService.getKardex(ci);
    }

    final url = Uri.parse('$baseUrl/kardex/?ci_estudiante=$ci');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ok': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCitaciones(String ciEstudiante) async {
    if (useMockData) {
      return MockDataService.getCitaciones(ciEstudiante);
    }

    final url = Uri.parse('$baseUrl/citaciones/?ci_estudiante=$ciEstudiante');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'ok': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Regente: Obtener estudiantes de un curso
  Future<Map<String, dynamic>> getEstudiantesCurso(int cursoId) async {
    if (useMockData) {
      return MockDataService.getEstudiantesCurso(cursoId);
    }

    final url = Uri.parse('$baseUrl/estudiantes-curso/?curso_id=$cursoId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ok': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Regente: Obtener ítems de kárdex
  Future<Map<String, dynamic>> getKardexItems() async {
    if (useMockData) {
      return MockDataService.getKardexItems();
    }

    final url = Uri.parse('$baseUrl/kardex-items/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'ok': false, 'error': 'Error ${response.statusCode}'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Regente: Enviar asistencia
  Future<Map<String, dynamic>> postAsistencia(String fecha, List<Map<String, dynamic>> asistencias) async {
    if (useMockData) {
      return MockDataService.postAsistencia(fecha, asistencias);
    }

    final url = Uri.parse('$baseUrl/regente/asistencia/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fecha': fecha,
          'asistencias': asistencias,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'ok': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Regente: Registrar Kárdex
  Future<Map<String, dynamic>> postKardex(String ciEstudiante, int itemId, String observacion) async {
    if (useMockData) {
      return MockDataService.postKardex(ciEstudiante, itemId, observacion);
    }

    final url = Uri.parse('$baseUrl/regente/kardex/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ci_estudiante': ciEstudiante,
          'item_id': itemId,
          'observacion': observacion,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'ok': false, 'error': 'Error ${response.statusCode}'};
      }
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }
}
