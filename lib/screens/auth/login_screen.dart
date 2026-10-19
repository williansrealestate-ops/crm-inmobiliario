import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  
  bool _cargando = false;
  bool _esRegistro = false;
  String _error = '';
  bool _mostrarPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      await SupabaseService.loginWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      // El AuthWrapper detectará el cambio de sesión automáticamente
    } catch (e) {
      setState(() {
        _error = _traducirError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      await SupabaseService.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registro exitoso. Ahora puedes iniciar sesión.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        setState(() => _esRegistro = false);
      }
    } catch (e) {
      setState(() {
        _error = _traducirError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  String _traducirError(String mensaje) {
    final msg = mensaje.toLowerCase();
    
    // Errores de Supabase Auth
    if (msg.contains('invalid login credentials') || 
        msg.contains('invalid email or password')) {
      return 'Email o contraseña incorrectos';
    } 
    else if (msg.contains('email not confirmed')) {
      return 'Debes confirmar tu email primero';
    } 
    else if (msg.contains('user not found') || 
             msg.contains('no rows found')) {
      return 'Usuario no encontrado. Crea una cuenta primero.';
    }
    else if (msg.contains('already been registered') || 
             msg.contains('user already registered')) {
      return 'Este email ya está registrado';
    } 
    else if (msg.contains('password should be at least') || 
             msg.contains('password must be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    else if (msg.contains('network') || 
             msg.contains('failed to fetch') ||
             msg.contains('err_name_not_resolved')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    else {
      // Mostrar el error real de Supabase
      return 'Error: $mensaje';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF334155), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home_work, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Williams Real Estate',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _esRegistro ? 'Crear cuenta de asesor' : 'CRM Multi-Negocio',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  if (_esRegistro) ...[
                    _buildCampo(
                      controller: _nombreCtrl,
                      label: 'Nombre completo',
                      icono: Icons.person,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildCampo(
                    controller: _emailCtrl,
                    label: 'Correo electrónico',
                    icono: Icons.email,
                    tipo: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Ingresa tu email';
                      if (!val.contains('@')) return 'Email no válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildCampo(
                    controller: _passwordCtrl,
                    label: 'Contraseña',
                    icono: Icons.lock,
                    esPassword: true,
                    mostrarPassword: _mostrarPassword,
                    onTogglePassword: () => setState(() => _mostrarPassword = !_mostrarPassword),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
                      if (val.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_error.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_error, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : (_esRegistro ? _registrar : _iniciarSesion),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF1E40AF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _cargando
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Text(_esRegistro ? 'Crear cuenta' : 'Iniciar sesión', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: const Color(0xFF334155))),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('O', style: TextStyle(color: Colors.white54, fontSize: 12))),
                      Expanded(child: Container(height: 1, color: const Color(0xFF334155))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _cargando ? null : () {
                        setState(() {
                          _esRegistro = !_esRegistro;
                          _error = '';
                          _formKey.currentState?.reset();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _esRegistro ? 'Ya tengo cuenta - Iniciar sesión' : 'Crear cuenta nueva',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield, color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text('Conexión segura con Supabase', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampo({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType tipo = TextInputType.text,
    bool esPassword = false,
    bool mostrarPassword = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      obscureText: esPassword && !mostrarPassword,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icono, color: Colors.white54, size: 20),
        suffixIcon: esPassword
            ? IconButton(
                icon: Icon(mostrarPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white54, size: 20),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
      ),
    );
  }
}