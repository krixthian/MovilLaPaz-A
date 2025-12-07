import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _ciController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ci = _ciController.text.trim();
    final password = _passwordController.text.trim();

    final success = await authProvider.login(ci, password);
    if (success && mounted) {
      // Navigate based on role
      final rol = authProvider.rol.toLowerCase();
      
      // Bloquear acceso a Directores
      if (rol.contains('director')) {
        authProvider.logout(); // Cerrar sesión inmediatamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Acceso no permitido. Use la versión web.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
      }

      if (rol.contains('regente')) {
        Navigator.pushReplacementNamed(context, '/regente');
      } else if (rol.contains('secretaria')) {
        // También bloqueamos secretaria si la app es solo para regente y padres, 
        // pero la solicitud específica fue "director". Dejaré secretaria por si acaso, 
        // o mejor bloqueo ambos si es enfoque "solo regente/padre".
        // User said: "app solo sera para el regente y el padre de familia/estudiante"
        // So I should block Secretary too.
        authProvider.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Acceso no permitido. Use la versión web.'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        // Default to parent/student home
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (mounted) {
      final errorMsg = authProvider.lastError ?? 'Credenciales incorrectas';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Color(0xFF1A237E)),
                const SizedBox(height: 20),
                const Text(
                  'Unidad Educativa La Paz',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                  TextFormField(
                    controller: _ciController,
                    decoration: const InputDecoration(
                      labelText: 'Cédula de Identidad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      counterText: "", // Hides the character counter if desired, or remove to show 0/7
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 7, // Restricts input to 7 chars
                    validator: Validators.validateCI,
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('INGRESAR', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
