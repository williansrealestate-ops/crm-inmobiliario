import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/theme.dart';

// ✅ Imports de pantallas
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/dashboard/dashboard_negocios.dart';
import 'screens/actividades/actividades_screen.dart';
import 'screens/clientes/clientes_screen.dart';
import 'screens/extras/asesores_screen.dart';
import 'screens/inmuebles/lista_inmuebles.dart';
import 'screens/vitrina/vitrina_screen.dart';
import 'screens/mapa/mapa_screen.dart';
import 'screens/calendario/calendario_screen.dart';
import 'screens/guiones/guiones_screen.dart';
import 'screens/dashboard/dashboard_asesores.dart';
import 'screens/reportes/reportes_screen.dart';
import 'screens/academia/academia_screen.dart';
import 'screens/chat_ia/chat_ia_screen.dart';
import 'screens/calculadoras/calculadoras_screen.dart';
import 'screens/finanzas/finanzas_screen.dart';
import 'screens/extras/backup_screen.dart';
import 'screens/vitrina/vitrina_publica_screen.dart';
import 'screens/auth/login_screen.dart';

import 'services/notificaciones_service.dart';
import 'services/supabase_service.dart';
import 'widgets/notification_panel.dart';
import 'widgets/whatsapp_fab.dart';

String _mapaHtmlContent = '';

void actualizarMapa(String htmlContent) {
  _mapaHtmlContent = htmlContent;
}

void registrarMapViewFactory() {
  ui_web.platformViewRegistry.registerViewFactory(
    'mapa-view',
    (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.borderRadius = '12px'
        ..allowFullscreen = true;
      iframe.srcdoc = _mapaHtmlContent;
      return iframe;
    },
  );

  ui_web.platformViewRegistry.registerViewFactory(
    'mapa-detalle',
    (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..allowFullscreen = true;
      iframe.src = 'https://www.openstreetmap.org/export/embed.html?bbox=-105%2C15%2C-90%2C25&layer=mapnik';
      return iframe;
    },
  );
}

// ✅ Función principal con inicialización de Supabase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializar Supabase
  await SupabaseService.initialize(
    url: 'https://qbuknjiqrzxqrqpoixiq.supabase.co',
    anonKey: 'sb_publishable_phlPx9hNs6-6yTTauRNdYQ_0UpY-9wB',
  );

  registrarMapViewFactory();

  final esVitrinaPublica = html.window.location.hash == '#/vitrina';

  if (esVitrinaPublica) {
    runApp(const VitrinaPublicaScreen());
  } else {
    runApp(const RealEstateApp());
  }
}

class RealEstateApp extends StatefulWidget {
  const RealEstateApp({super.key});

  @override
  State<RealEstateApp> createState() => _RealEstateAppState();
}

class _RealEstateAppState extends State<RealEstateApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void cambiarTema(ThemeMode modo) {
    setState(() => _themeMode = modo);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Real Estate CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: const AuthWrapper(),
    );
  }
}

// ✅ Widget que decide si mostrar Login o MainScreen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                  const SizedBox(height: 16),
                  const Text(
                    'Conectando con Supabase...',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return MainScreen(
            themeMode: ThemeMode.system,
            onThemeChanged: (modo) {},
          );
        }

        return const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  const MainScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _menuAbierto = true;
  
  bool _mostrarNotificaciones = false;
  Map<String, dynamic> _resumenNotificaciones = {};

  final String _numeroWhatsApp = '529932149996';

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onVerNotificaciones: _toggleNotificaciones),  // 0
      ActividadesScreen(),                                          // 1
      ClientesScreen(),                                             // 2
      AsesoresScreen(),                                             // 3
      ListaInmuebles(),                                             // 4
      VitrinaScreen(),                                              // 5
      const MapaScreen(),                                           // 6
      const CalendarioScreen(),                                     // 7
      GuionesScreen(),                                              // 8
      DashboardAsesores(),                                          // 9
      const ReportesScreen(),                                       // 10 ✅ NUEVO
      AcademiaScreen(),                                             // 11
      ChatIAScreen(),                                               // 12
      CalculadorasScreen(),                                         // 13
      FinanzasScreen(),                                             // 14
      BackupScreen(),                                               // 15
      const DashboardNegociosScreen(),                              // 16
    ];
    _cargarResumenNotificaciones();
  }

  Future<void> _cargarResumenNotificaciones() async {
    try {
      final resumen = await NotificacionesService.getResumen();
      if (mounted) {
        setState(() {
          _resumenNotificaciones = resumen;
        });
      }
    } catch (e) {
      // Error manejado silenciosamente
    }
  }

  void _toggleNotificaciones() {
    setState(() {
      _mostrarNotificaciones = !_mostrarNotificaciones;
      if (_mostrarNotificaciones) {
        _cargarResumenNotificaciones();
      }
    });
  }

  void _cerrarSesion() async {
    await SupabaseService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              if (_menuAbierto) _buildSideMenu(),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(_menuAbierto ? Icons.menu_open : Icons.menu, color: Colors.white),
                            onPressed: () => setState(() => _menuAbierto = !_menuAbierto),
                          ),
                          const SizedBox(width: 8),
                          Icon(_getIconForIndex(_selectedIndex), color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            _getTitleForIndex(_selectedIndex),
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: _cerrarSesion,
                            tooltip: 'Cerrar sesión',
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications, color: Colors.white),
                                onPressed: _toggleNotificaciones,
                                tooltip: 'Notificaciones',
                              ),
                              if ((_resumenNotificaciones['noLeidas'] ?? 0) > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                    child: Text(
                                      '${_resumenNotificaciones['noLeidas']}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _screens[_selectedIndex]),
                  ],
                ),
              ),
            ],
          ),
          if (_mostrarNotificaciones)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: NotificationPanel(
                onNotificacionLeida: () {
                  setState(() {
                    _mostrarNotificaciones = false;
                    _cargarResumenNotificaciones();
                  });
                },
              ),
            ),
          if (_mostrarNotificaciones)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _mostrarNotificaciones = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          if (_selectedIndex != 5)
            Positioned(
              right: 20,
              bottom: 20,
              child: WhatsAppFAB(
                numero: _numeroWhatsApp,
                mensaje: 'Hola Williams, me interesa conocer más sobre sus propiedades',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: AppTheme.getBackgroundColor(context),
        border: Border(right: BorderSide(color: AppTheme.getDividerColor(context))),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              border: Border(bottom: BorderSide(color: AppTheme.getDividerColor(context))),
            ),
            child: const Row(
              children: [
                Icon(Icons.home, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text('REAL ESTATE', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(Icons.dashboard, 'Dashboard', 0, const Color(0xFF3B82F6)),
                _buildMenuItem(Icons.task, 'Actividades', 1, const Color(0xFF10B981)),
                _buildMenuItem(Icons.people, 'Clientes', 2, const Color(0xFF8B5CF6)),
                _buildMenuItem(Icons.person, 'Asesores', 3, const Color(0xFFF59E0B)),
                _buildMenuItem(Icons.home_work, 'Inmuebles', 4, const Color(0xFF06B6D4)),
                _buildMenuItem(Icons.storefront, 'Vitrina', 5, const Color(0xFFEC4899)),
                _buildMenuItem(Icons.map, 'Mapa', 6, const Color(0xFF14B8A6)),
                _buildMenuItem(Icons.calendar_today, 'Calendario', 7, const Color(0xFF64748B)),
                _buildMenuItem(Icons.description, 'Guiones', 8, const Color(0xFF8B5CF6)),
                _buildMenuItem(Icons.analytics, 'Dashboard Asesores', 9, const Color(0xFF3B82F6)),
                _buildMenuItem(Icons.bar_chart, 'Reportes', 10, const Color(0xFF10B981)),  // ✅ NUEVO
                _buildMenuItem(Icons.school, 'Academia', 11, const Color(0xFF8B5CF6)),
                _buildMenuItem(Icons.smart_toy, 'Chat IA', 12, const Color(0xFF06B6D4)),
                _buildMenuItem(Icons.calculate, 'Calculadoras', 13, const Color(0xFF14B8A6)),
                _buildMenuItem(Icons.account_balance, 'Finanzas', 14, const Color(0xFFF59E0B)),
                _buildMenuItem(Icons.cloud_upload, 'Respaldo', 15, const Color(0xFF14B8A6)),
                _buildMenuItem(Icons.business_center, 'Dashboard Negocios', 16, const Color(0xFFEC4899)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              border: Border(top: BorderSide(color: AppTheme.getDividerColor(context))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('W', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Williams', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                          Text(_nombreTema(widget.themeMode), style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildThemeButton(Icons.light_mode, 'Claro', ThemeMode.light, isDark)),
                    const SizedBox(width: 4),
                    Expanded(child: _buildThemeButton(Icons.dark_mode, 'Oscuro', ThemeMode.dark, isDark)),
                    const SizedBox(width: 4),
                    Expanded(child: _buildThemeButton(Icons.settings, 'Auto', ThemeMode.system, isDark)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(IconData icon, String label, ThemeMode modo, bool isDark) {
    final isSelected = widget.themeMode == modo;
    return GestureDetector(
      onTap: () => widget.onThemeChanged(modo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.getDividerColor(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? AppTheme.primary : AppTheme.getTextSecondaryColor(context)),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nombreTema(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light: return 'Modo Claro';
      case ThemeMode.dark: return 'Modo Oscuro';
      case ThemeMode.system: return 'Modo Automático';
    }
  }

  Widget _buildMenuItem(IconData icon, String title, int index, Color color) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    const icons = [
      Icons.dashboard,              // 0 - Dashboard
      Icons.task,                   // 1 - Actividades
      Icons.people,                 // 2 - Clientes
      Icons.person,                 // 3 - Asesores
      Icons.home_work,              // 4 - Inmuebles
      Icons.storefront,             // 5 - Vitrina
      Icons.map,                    // 6 - Mapa
      Icons.calendar_today,         // 7 - Calendario
      Icons.description,            // 8 - Guiones
      Icons.analytics,              // 9 - Dashboard Asesores
      Icons.bar_chart,              // 10 - Reportes ✅
      Icons.school,                 // 11 - Academia
      Icons.smart_toy,              // 12 - Chat IA
      Icons.calculate,              // 13 - Calculadoras
      Icons.account_balance,        // 14 - Finanzas
      Icons.cloud_upload,           // 15 - Respaldo
      Icons.business_center,        // 16 - Dashboard Negocios
    ];
    return icons[index] ?? Icons.home;
  }

  String _getTitleForIndex(int index) {
    const titles = [
      'Dashboard',                   // 0
      'Actividades',                 // 1
      'Clientes',                    // 2
      'Asesores',                    // 3
      'Inmuebles',                   // 4
      'Vitrina',                     // 5
      'Mapa',                        // 6
      'Calendario',                  // 7
      'Guiones',                     // 8
      'Dashboard Asesores',          // 9
      'Reportes',                    // 10 ✅
      'Academia',                    // 11
      'Chat IA',                     // 12
      'Calculadoras',                // 13
      'Finanzas',                    // 14
      'Respaldo',                    // 15
      'Dashboard Negocios',          // 16
    ];
    return titles[index] ?? 'Real Estate';
  }
}