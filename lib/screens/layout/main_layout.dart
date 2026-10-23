import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../extras/actividades_screen.dart';
import '../clientes/lista_clientes.dart';
import '../extras/asesores_screen.dart';
import '../inmuebles/lista_inmuebles.dart';
import '../extras/mapa_screen.dart';
import '../extras/calendario_screen.dart';
import '../extras/guiones_screen.dart';
import '../extras/reportes_screen.dart';
import '../extras/vitrina_screen.dart';
import '../extras/conocimientos_screen.dart';
import '../extras/generador_documentos_screen.dart';
import '../extras/perfil_screen.dart';
import '../extras/calculadoras_screen.dart';
import '../extras/finanzas_screen.dart';
import '../extras/pipeline_screen.dart';
import '../extras/contactos_screen.dart';
import '../extras/examenes_screen.dart';
import '../extras/notificaciones_screen.dart';
import '../extras/avaluos_screen.dart';
import '../extras/backup_screen.dart';
import '../extras/automatizacion_screen.dart';
import '../extras/firma_digital_screen.dart';
import '../extras/referidos_screen.dart';
import '../extras/calculadora_cliente_screen.dart';
import '../extras/analiticas_screen.dart';
import '../extras/geolocalizacion_screen.dart';
import '../extras/asistente_ia_chat_screen.dart';
import '../extras/comisiones_screen.dart';
import '../extras/analisis_mercado_screen.dart'; // ✅ NUEVO IMPORT

class MainLayout extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode? currentThemeMode;
  const MainLayout({super.key, this.onThemeToggle, this.currentThemeMode});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _screens = [
    {'titulo': 'Dashboard', 'icono': Icons.dashboard},
    {'titulo': 'Actividades', 'icono': Icons.task},
    {'titulo': 'Clientes', 'icono': Icons.people},
    {'titulo': 'Asesores', 'icono': Icons.person},
    {'titulo': 'Inmuebles', 'icono': Icons.home},
    {'titulo': 'Vitrina', 'icono': Icons.storefront},
    {'titulo': 'Mapa', 'icono': Icons.map},
    {'titulo': 'Calendario', 'icono': Icons.calendar_today},
    {'titulo': 'Guiones', 'icono': Icons.article},
    {'titulo': 'Reportes', 'icono': Icons.analytics},
    {'titulo': 'Academia', 'icono': Icons.school},
    {'titulo': 'Chat IA', 'icono': Icons.smart_toy},
    {'titulo': 'Documentos', 'icono': Icons.description},
    {'titulo': 'Mi Perfil', 'icono': Icons.emoji_events},
    {'titulo': 'Calculadoras', 'icono': Icons.calculate},
    {'titulo': 'Finanzas', 'icono': Icons.account_balance_wallet},
    {'titulo': 'Pipeline', 'icono': Icons.view_kanban},
    {'titulo': 'Contactos', 'icono': Icons.contacts},
    {'titulo': 'Exámenes', 'icono': Icons.quiz},
    {'titulo': 'Notificaciones', 'icono': Icons.notifications},
    {'titulo': 'Avalúos', 'icono': Icons.analytics},
    {'titulo': 'Backup', 'icono': Icons.cloud_upload},
    {'titulo': 'Automatización', 'icono': Icons.auto_awesome},
    {'titulo': 'Firma Digital', 'icono': Icons.edit_note},
    {'titulo': 'Referidos', 'icono': Icons.group_add},
    {'titulo': 'Calculadora Cliente', 'icono': Icons.calculate_outlined},
    {'titulo': 'Analytics', 'icono': Icons.analytics_outlined},
    {'titulo': 'Rutas y Mapa', 'icono': Icons.route},
    {'titulo': 'Comisiones', 'icono': Icons.account_balance_wallet},
    {'titulo': 'Análisis Mercado', 'icono': Icons.trending_up}, // ✅ NUEVA ENTRADA
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPantallaActual() {
    switch (_selectedIndex) {
      case 0: return const DashboardScreen();
      case 1: return const ActividadesScreen();
      case 2: return const ListaClientes();
      case 3: return const AsesoresScreen();
      case 4: return const ListaInmuebles();
      case 5: return const VitrinaScreen();
      case 6: return const MapaScreen();
      case 7: return const CalendarioScreen();
      case 8: return const GuionesScreen();
      case 9: return const ReportesScreen();
      case 10: return const ConocimientosScreen();
      case 11: return const AsistenteIAChatScreen();
      case 12: return const GeneradorDocumentosScreen();
      case 13: return const PerfilScreen();
      case 14: return const CalculadorasScreen();
      case 15: return const FinanzasScreen();
      case 16: return const PipelineScreen();
      case 17: return const ContactosScreen();
      case 18: return const ExamenesScreen();
      case 19: return const NotificacionesScreen();
      case 20: return const AvaluosScreen();
      case 21: return const BackupScreen();
      case 22: return const AutomatizacionScreen();
      case 23: return const FirmaDigitalScreen();
      case 24: return const ReferidosScreen();
      case 25: return const CalculadoraClienteScreen();
      case 26: return const AnaliticasScreen();
      case 27: return const GeolocalizacionScreen();
      case 28: return const ComisionesScreen();
      case 29: return const AnalisisMercadoScreen(); // ✅ NUEVO CASO
      default: return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: const Color(0xFF0D1B4C),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.home, color: Color(0xFFE8D44D), size: 28),
                      SizedBox(width: 8),
                      Text('REAL ESTATE', style: TextStyle(color: Color(0xFFE8D44D), fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF1A2F6F)),
                Expanded(
                  child: ListView.builder(
                    itemCount: _screens.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return ListTile(
                        leading: Icon(_screens[index]['icono'], color: isSelected ? const Color(0xFFE8D44D) : Colors.white70),
                        title: Text(_screens[index]['titulo'], style: TextStyle(color: isSelected ? const Color(0xFFE8D44D) : Colors.white70, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, fontSize: 13)),
                        selected: isSelected,
                        selectedTileColor: const Color(0xFF1A2F6F),
                        onTap: () => _onItemTapped(index),
                        dense: true,
                      );
                    },
                  ),
                ),
                const Divider(color: Color(0xFF1A2F6F)),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: esOscuro ? const Color(0xFF1E293B) : const Color(0xFF1A2F6F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: esOscuro ? const Color(0xFF334155) : const Color(0xFF2A3F7F)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFE8D44D),
                        radius: 18,
                        child: Text('W', style: TextStyle(color: Color(0xFF0D1B4C), fontWeight: FontWeight.w800, fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Williams', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                            Text(
                              esOscuro ? '🌙 Modo Oscuro' : '☀️ Modo Claro',
                              style: const TextStyle(color: Colors.white60, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onThemeToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 24,
                          decoration: BoxDecoration(
                            color: esOscuro ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: esOscuro ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                esOscuro ? Icons.dark_mode : Icons.light_mode,
                                size: 12,
                                color: esOscuro ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppTheme.getBackgroundColor(context),
              child: _getPantallaActual(),
            ),
          ),
        ],
      ),
    );
  }
}