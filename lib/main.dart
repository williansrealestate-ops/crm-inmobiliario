import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS DE TUS PANTALLAS
import 'screens/clientes/clientes_screen.dart';
import 'screens/extras/asesores_screen.dart';
import 'screens/inmuebles/lista_inmuebles.dart';
import 'screens/finanzas/finanzas_screen.dart';
import 'screens/extras/backup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM Inmobiliario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0066FF),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.description, 'label': 'Guiones', 'color': const Color(0xFF9C27B0)},
    {'icon': Icons.dashboard, 'label': 'Dashboard Asesores', 'color': const Color(0xFF2196F3)},
    {'icon': Icons.bar_chart, 'label': 'Reportes', 'color': const Color(0xFF4CAF50)},
    {'icon': Icons.school, 'label': 'Academia', 'color': const Color(0xFF9C27B0)},
    {'icon': Icons.smart_toy, 'label': 'Chat IA', 'color': const Color(0xFF00BCD4)},
    {'icon': Icons.calculate, 'label': 'Calculadoras', 'color': const Color(0xFF009688)},
    {'icon': Icons.account_balance, 'label': 'Finanzas', 'color': const Color(0xFFFFC107)},
    {'icon': Icons.cloud, 'label': 'Respaldo', 'color': const Color(0xFF03A9F4)},
    {'icon': Icons.dashboard_customize, 'label': 'Dashboard Negocios', 'color': const Color(0xFFE91E63)},
    {'icon': Icons.people, 'label': 'Clientes', 'color': const Color(0xFF3F51B5)},
    {'icon': Icons.person, 'label': 'Asesores', 'color': const Color(0xFF2196F3)},
    {'icon': Icons.home, 'label': 'Inmuebles', 'color': const Color(0xFF00BCD4)},
  ];

  final List<Widget> _screens = [
    const Center(child: Text('Guiones', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Dashboard Asesores', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Reportes', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Academia', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Chat IA', style: TextStyle(color: Colors.white, fontSize: 20))),
    const Center(child: Text('Calculadoras', style: TextStyle(color: Colors.white, fontSize: 20))),
    const FinanzasScreen(),
    const BackupScreen(),
    const Center(child: Text('Dashboard Negocios', style: TextStyle(color: Colors.white, fontSize: 20))),
    const ClientesScreen(),
    const AsesoresScreen(),
    const ListaInmuebles(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ✅ SIDEBAR IZQUIERDO
          Container(
            width: _isSidebarExpanded ? 220 : 70,
            color: const Color(0xFF000000),
            child: Column(
              children: [
                // Logo superior
                Container(
                  height: 60,
                  color: const Color(0xFF0066FF),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.home, color: Colors.white, size: 24),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'REAL ESTATE',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: Icon(_isSidebarExpanded ? Icons.menu_open : Icons.menu, color: Colors.white, size: 20),
                        onPressed: () => setState(() => _isSidebarExpanded = !_isSidebarExpanded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Lista de módulos
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final isSelected = _selectedIndex == index;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? (item['color'] as Color).withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border(left: BorderSide(color: item['color'] as Color, width: 3)) : null,
                          ),
                          child: Row(
                            children: [
                              Icon(item['icon'] as IconData, color: isSelected ? item['color'] as Color : Colors.grey, size: 20),
                              if (_isSidebarExpanded) ...[
                                const SizedBox(width: 12),
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Perfil de usuario en la parte inferior
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0A0A0A),
                    border: Border(top: BorderSide(color: Color(0xFF222222))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0066FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('W', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Williams', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              Text('Modo Automático', style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Botones de tema
                Container(
                  padding: const EdgeInsets.all(8),
                  color: const Color(0xFF0A0A0A),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThemeButton(Icons.light_mode, 'Claro'),
                      _buildThemeButton(Icons.dark_mode, 'Oscuro'),
                      _buildThemeButton(Icons.settings, 'Auto', isSelected: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ✅ CONTENIDO PRINCIPAL
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(IconData icon, String label, {bool isSelected = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? const Color(0xFF0066FF) : const Color(0xFF333333)),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isSelected ? const Color(0xFF0066FF) : Colors.grey, fontSize: 10)),
      ],
    );
  }
}