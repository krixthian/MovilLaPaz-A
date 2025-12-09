import 'dart:convert';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;
  String? _currentUserId;
  Map<String, String> _studentNames = {};

  void updateStudentNames(List<dynamic> children) {
    _studentNames.clear();
    for (var child in children) {
      final ci = child['ci']?.toString() ?? child['ci_estudiante']?.toString() ?? child['id']?.toString();
      final name = child['nombre_completo'] ?? child['nombreEstudiante'];
      if (ci != null && name != null) {
        _studentNames[ci] = name.toString();
      }
    }
    print("NotificationService: Nombres de estudiantes actualizados: $_studentNames");
  }

  // Inicializar notificaciones locales
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Aquí podrías manejar el click en la notificación
        print("Notificación clickeada: ${details.payload}");
      },
    );
    
    // Solicitar permisos en Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Conectar al WebSocket
  void connect(String userId) {
    if (_isConnected && _currentUserId == userId) return;
    
    disconnect();
    _currentUserId = userId;

    // Construir URL del WebSocket
    // Usamos la misma IP que ApiService pero con protocolo ws://
    final baseUrl = ApiService.baseUrl;
    final wsUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('/api/v1', '/ws/notifs/?uid=$userId');

    print("Conectando WS a: $wsUrl");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      print("WS: Canal creado exitosamente");

      _subscription = _channel!.stream.listen(
        (message) {
          print("WS Mensaje recibido RAW: $message");
          _handleMessage(message);
        },
        onDone: () {
          print("WS Desconectado (onDone)");
          _isConnected = false;
          _reconnect(userId);
        },
        onError: (error) {
          print("WS Error (onError): $error");
          _isConnected = false;
          _reconnect(userId);
        },
      );
    } catch (e) {
      print("Error CRÍTICO al conectar WS: $e");
      _reconnect(userId);
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
    _currentUserId = null;
  }

  void _reconnect(String userId) {
    if (_currentUserId != userId) return;
    // Reintentar en 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentUserId == userId && !_isConnected) {
        print("Reconectando WS...");
        connect(userId);
      }
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      
      // Verificar si es una notificación de citación
      if (data['type'] == 'notify.unread' && data['event'] == 'citacion') {
        String? nombreEstudiante = data['nombre_estudiante'];
        
        // Si no viene el nombre, buscarlo localmente por CI
        if (nombreEstudiante == null) {
          final ci = data['ci_estudiante']?.toString() ?? 
                     data['ci']?.toString() ?? 
                     data['estudiante_ci']?.toString() ??
                     data['student_ci']?.toString();
                     
          if (ci != null) {
            nombreEstudiante = _studentNames[ci];
          }
        }
        
        // Fallback final
        nombreEstudiante ??= 'su hijo(a)';

        _showNotification(
          id: data['citacion_id'] ?? 0,
          title: "Citación Agendada",
          body: "Tienes una nueva citación agendada para $nombreEstudiante.",
          payload: jsonEncode(data),
        );
      }
    } catch (e) {
      print("Error procesando mensaje WS: $e");
    }
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'citaciones_channel', // id del canal
      'Citaciones', // nombre del canal
      channelDescription: 'Notificaciones de nuevas citaciones',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}
