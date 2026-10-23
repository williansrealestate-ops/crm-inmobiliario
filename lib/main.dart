import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ IMPORTS DE TUS PANTALLAS (Sin whatsapp_fab.dart)
import 'screens/clientes/clientes_screen.dart';
import 'screens/extras/asesores_screen.dart';
import 'screens/inmuebles/lista_inmuebles.dart';
import 'screens/finanzas/finanzas_screen.dart';
import 'screens/extras/backup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTA: Si ya inicializas Supabase en otro archivo, puedes comentar estas 3 líneas.
  // Si no, descomenta y pon tus credenciales reales de Supabase:
  /*
  await Supabase.initialize(
    url: 'TU_SUPABASE_URL',
    anonKey: 'TU_SUPABASE_ANON_KEY',
  );
  */

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
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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

  // ✅ LISTA DE PANTALLAS (BackupScreen está correctamente incluido)
  final List<Widget> _screens = [
    // Puedes reemplazar este Center por tu propio DashboardScreen si lo tienes
    const Center(
      child: Text('Bienvenido al CRM', style: TextStyle(color: Colors.white, fontSize: 20)),
    ),
    const ClientesScreen(),
    const AsesoresScreen(),
    const ListaInmuebles(),
    const FinanzasScreen(),
    const BackupScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM Inmobiliario'),
        actions: const [
          // Aquí puedes agregar botones globales si los necesitas
        ],
      ),
      body: _screens[_selectedIndex],
      
      // ✅ BARRA DE NAVEGACIÓN INFERIOR (Sin WhatsAppFAB)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF111111),
        selectedItemColor: const Color(0xFF0066FF),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clientes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Asesores'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inmuebles'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Finanzas'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Respaldo'),
        ],
      ),
      
      // ✅ AQUÍ SE ELIMINÓ COMPLETAMENTE EL BLOQUE "floatingActionButton: WhatsAppFAB(...)"
    );
  }
}