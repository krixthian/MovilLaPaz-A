// Mock data service for demo/offline mode
class MockDataService {
  // Demo users: CI -> Password
  static const Map<String, String> demoUsers = {
    // Padres/Estudiantes
    '12345678': 'demo123',
    '87654321': 'test456',
    // Director
    '11111111': 'director123',
    // Regente
    '22222222': 'regente123',
    // Secretaria
    '33333333': 'secretaria123',
  };

  // Demo student data (for Padre role)
  static const Map<String, Map<String, dynamic>> studentData = {
    '12345678': {
      'ok': true,
      'token': 'DEMO_TOKEN_12345',
      'rol': 'Padre',
      'nombreUsuario': 'María García López',
      'ciUsuario': '12345678',
      'nombreEstudiante': 'Juan Pérez García',
      'ciEstudiante': '12345678',
      'nombrePadre': 'María García López',
      'ciPadre': '11223344',
      'curso': '6to de Secundaria A',
    },
    '87654321': {
      'ok': true,
      'token': 'DEMO_TOKEN_87654',
      'rol': 'Padre',
      'nombreUsuario': 'Carlos Martínez Rojas',
      'ciUsuario': '87654321',
      'nombreEstudiante': 'Ana Martínez Silva',
      'ciEstudiante': '87654321',
      'nombrePadre': 'Carlos Martínez Rojas',
      'ciPadre': '55667788',
      'curso': '5to de Secundaria B',
    },
    // Director
    '11111111': {
      'ok': true,
      'token': 'DEMO_TOKEN_DIRECTOR',
      'rol': 'Director',
      'nombreUsuario': 'Roberto Sánchez Pérez',
      'ciUsuario': '11111111',
      'nombreEstudiante': '',
      'ciEstudiante': '',
      'nombrePadre': '',
      'ciPadre': '',
      'curso': '',
    },
    // Regente
    '22222222': {
      'ok': true,
      'token': 'DEMO_TOKEN_REGENTE',
      'rol': 'Regente',
      'nombreUsuario': 'Patricia López Vargas',
      'ciUsuario': '22222222',
      'nombreEstudiante': '',
      'ciEstudiante': '',
      'nombrePadre': '',
      'ciPadre': '',
      'curso': '',
    },
    // Secretaria
    '33333333': {
      'ok': true,
      'token': 'DEMO_TOKEN_SECRETARIA',
      'rol': 'Secretaria',
      'nombreUsuario': 'Laura Fernández Gómez',
      'ciUsuario': '33333333',
      'nombreEstudiante': '',
      'ciEstudiante': '',
      'nombrePadre': '',
      'ciPadre': '',
      'curso': '',
    },
  };

  // Demo attendance data
  static const Map<String, List<Map<String, String>>> attendanceData = {
    '12345678': [
      {'fecha': '01/12/2025', 'estado': 'Presente'},
      {'fecha': '29/11/2025', 'estado': 'Presente'},
      {'fecha': '28/11/2025', 'estado': 'Atraso'},
      {'fecha': '27/11/2025', 'estado': 'Presente'},
      {'fecha': '26/11/2025', 'estado': 'Falta'},
      {'fecha': '25/11/2025', 'estado': 'Presente'},
    ],
    '87654321': [
      {'fecha': '01/12/2025', 'estado': 'Presente'},
      {'fecha': '29/11/2025', 'estado': 'Presente'},
      {'fecha': '28/11/2025', 'estado': 'Presente'},
      {'fecha': '27/11/2025', 'estado': 'Presente'},
      {'fecha': '26/11/2025', 'estado': 'Presente'},
    ],
  };

  // Demo kardex data
  static const Map<String, List<Map<String, dynamic>>> kardexData = {
    '12345678': [
      {'fecha': '01/12/2025', 'detalle': 'Participación activa en clase', 'puntos': 5},
      {'fecha': '28/11/2025', 'detalle': 'Llegada tarde sin justificación', 'puntos': -3},
      {'fecha': '25/11/2025', 'detalle': 'Ayuda a compañero', 'puntos': 3},
      {'fecha': '20/11/2025', 'detalle': 'Falta de uniforme', 'puntos': -2},
    ],
    '87654321': [
      {'fecha': '01/12/2025', 'detalle': 'Excelente comportamiento', 'puntos': 10},
      {'fecha': '27/11/2025', 'detalle': 'Proyecto destacado', 'puntos': 8},
      {'fecha': '22/11/2025', 'detalle': 'Colaboración en actividad grupal', 'puntos': 5},
    ],
  };

  static Future<Map<String, dynamic>> login(String ci, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (demoUsers.containsKey(ci) && demoUsers[ci] == password) {
      return studentData[ci]!;
    }

    return {
      'ok': false,
      'error': 'Credenciales incorrectas. Prueba:\nCI: 12345678\nContraseña: demo123',
    };
  }

  static Future<Map<String, dynamic>> getPerfil(String ci) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (studentData.containsKey(ci)) {
      return studentData[ci]!;
    }
    
    return {'ok': false, 'error': 'Estudiante no encontrado'};
  }

  static Future<Map<String, dynamic>> getAsistencia(String ci) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (attendanceData.containsKey(ci)) {
      return {'ok': true, 'items': attendanceData[ci]};
    }
    
    return {'ok': false, 'error': 'No hay datos de asistencia'};
  }

  static Future<Map<String, dynamic>> getKardex(String ci) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (kardexData.containsKey(ci)) {
      return {'ok': true, 'items': kardexData[ci]};
    }
    
    return {'ok': false, 'error': 'No hay datos de kárdex'};
  }

  static Future<Map<String, dynamic>> getCitaciones(String ci) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'ok': true,
      'items': [
        {
          'id': 1,
          'motivo': 'Reunión de padres de familia',
          'estado': 'AGENDADA',
          'fecha': '15/12/2025 18:00',
          'creado_en': '01/12/2025'
        },
        {
          'id': 2,
          'motivo': 'Comportamiento en clase',
          'estado': 'ATENDIDA',
          'fecha': '10/11/2025 10:30',
          'creado_en': '08/11/2025'
        }
      ]
    };
  }

  static Future<Map<String, dynamic>> getEstudiantesCurso(int cursoId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'ok': true,
      'estudiantes': [
        {'ci': '12345678', 'nombre': 'Juan Pérez García', 'id': 1},
        {'ci': '87654321', 'nombre': 'Ana Martínez Silva', 'id': 2},
      ]
    };
  }

  static Future<Map<String, dynamic>> getKardexItems() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'ok': true,
      'items': [
        {'id': 1, 'descripcion': 'Falta de uniforme', 'puntos': -5},
        {'id': 2, 'descripcion': 'Llegada tarde', 'puntos': -3},
        {'id': 4, 'descripcion': 'Participación destacada', 'puntos': 5},
      ]
    };
  }

  static Future<Map<String, dynamic>> postAsistencia(String fecha, List<Map<String, dynamic>> asistencias) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {
      'ok': true,
      'creados': asistencias.length,
      'actualizados': 0,
      'errores': []
    };
  }

  static Future<Map<String, dynamic>> postKardex(String ci, int itemId, String obs) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return {'ok': true, 'id': 999};
  }
}
