import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/director_home_screen.dart';
import 'screens/regente_dashboard.dart';
import 'screens/secretaria_home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/kardex_screen.dart';
import 'screens/citaciones_screen.dart';
import 'screens/tomar_asistencia_screen.dart';
import 'screens/registro_kardex_screen.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  final authProvider = AuthProvider();
  await authProvider.loadSession();
  
  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
        title: 'Unidad Educativa La Paz',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)), // Indigo
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A237E),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: authProvider.isAuthenticated
            ? (authProvider.esRegente ? '/regente' : '/home')
            : '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/director': (context) => const DirectorHomeScreen(),
          '/regente': (context) => const RegenteDashboard(),
          '/secretaria': (context) => const SecretariaHomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/attendance': (context) => const AttendanceScreen(),
          '/kardex': (context) => const KardexScreen(),
          '/citaciones': (context) => const CitacionesScreen(),
          '/tomar_asistencia': (context) => const TomarAsistenciaScreen(),
          '/registro_kardex': (context) => const RegistroKardexScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
