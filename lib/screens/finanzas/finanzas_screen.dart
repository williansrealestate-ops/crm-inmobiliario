import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;
  
  String _search = '';
  String _categoriaFiltro = 'Todas';
  String _cuentaFiltro = 'Todas';
  String _negocioFiltro = 'Todos';
  bool _soloPendientes = false;
  bool _soloReconciliadas = false;

  final List<String> _categorias = ['Todas', 'Proyecto', 'Servicios', 'Personal', 'Transporte', 'Alquiler', 'Mobiliario', 'Deudas', 'Otros'];
  final List<String> _cuentasLista = ['Todas', 'Efectivo', 'Banco', 'Tarjeta', 'Inversión'];
  final List<String> _negocios = ['Todos', 'Minerales', 'Combustible', 'Agropecuario', 'Proyectos'];
  final List<String> _meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066FF),
        title: const Row(children: [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 8),
          Text('Finanzas Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: _mostrarFormularioTransaccion),
          IconButton(icon: const Icon(Icons.cloud_upload, color: Colors.white), onPressed: _generarDatosEjemplo, tooltip: 'Generar datos'),
          IconButton(icon: const Icon(Icons.swap_horiz, color: Colors.white), onPressed: _mostrarTransferencia, tooltip: 'Transferir'),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Hoy'),
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.dashboard_customize), text: 'Dashboard'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ingresos'),
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.credit_card), text: 'Cuentas'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendario'),
            Tab(icon: Icon(Icons.show_chart), text: 'Reportes'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Presupuestos'),
            Tab(icon: Icon(Icons.flag), text: 'Metas'),
            Tab(icon: Icon(Icons.money_off), text: 'Deudas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVistaHoy(),
          _buildResumen(),
          _buildDashboard(),
          _buildListaTransacciones('Ingreso'),
          _buildListaTransacciones('Gasto'),
          _buildCuentas(),
          _buildCalendario(), // ✅ PESTAÑA CALENDARIO ACTIVA
          _buildPlaceholder('Reportes'),
          _buildPlaceholder('Presupuestos'),
          _buildPlaceholder('Metas'),
          _buildPlaceholder('Deudas'),
        ],
      ),
    );
  }

  // ==========================================
  // ✅ PESTAÑA "CALENDARIO" (AGRUPADO POR DÍA)
  // ==========================================
  Widget _buildCalendario() {
    DateTime mesSeleccionado = DateTime.now();

    return StatefulBuilder(
      builder: (context, setEstado) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Navegación de Mes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      setEstado(() {
                        mesSeleccionado = DateTime(mesSeleccionado.year, mesSeleccionado.month - 1);
                      });
                    },
                  ),
                  Text(
                    '${_meses[mesSeleccionado.month - 1]} ${mesSeleccionado.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      setEstado(() {
                        mesSeleccionado = DateTime(mesSeleccionado.year, mesSeleccionado.month + 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lista de Días con Transacciones
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final docs = snapshot.data!.docs;
                    
                    // Filtrar transacciones del mes seleccionado
                    final transaccionesDelMes = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final fechaStr = data['fecha'] as String? ?? '';
                      if (fechaStr.length >= 7) {
                        final partes = fechaStr.split('-');
                        if (partes.length >= 2) {
                          final anio = int.tryParse(partes[0]);
                          final mes = int.tryParse(partes[1]);
                          return anio == mesSeleccionado.year && mes == mesSeleccionado.month;
                        }
                      }
                      return false;
                    }).toList();

                    if (transaccionesDelMes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey.shade700, size: 64),
                            const SizedBox(height: 16),
                            Text('No hay transacciones en ${_meses[mesSeleccionado.month - 1]}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                          ],
                        ),
                      );
                    }

                    // Agrupar por día
                    Map<String, List<Map<String, dynamic>>> porDia = {};
                    for (var doc in transaccionesDelMes) {
                      final data = doc.data() as Map<String, dynamic>;
                      final fechaStr = data['fecha'] as String? ?? '';
                      if (fechaStr.length >= 10) {
                        final dia = fechaStr.substring(8, 10);
                        if (!porDia.containsKey(dia)) {
                          porDia[dia] = [];
                        }
                        porDia[dia]!.add(data);
                      }
                    }

                    // Ordenar días de mayor a menor
                    final diasOrdenados = porDia.keys.toList()..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      itemCount: diasOrdenados.length,
                      itemBuilder: (context, index) {
                        final dia = diasOrdenados[index];
                        final transacciones = porDia[dia]!;
                        
                        // Calcular total del día
                        double totalDia = 0;
                        for (var t in transacciones) {
                          final monto = (t['monto'] ?? 0).toDouble();
                          if (t['tipo'] == 'Ingreso') {
                            totalDia += monto;
                          } else {
                            totalDia -= monto;
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: ExpansionTile(
                            backgroundColor: const Color(0xFF111111),
                            collapsedBackgroundColor: const Color(0xFF111111),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            title: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0066FF).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      dia,
                                      style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Día $dia • ${transacciones.length} transacciones',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${_meses[mesSeleccionado.month - 1]} ${mesSeleccionado.year}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${totalDia.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: totalDia >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              const Divider(color: Color(0xFF222222)),
                              ...transacciones.map((t) {
                                final esIngreso = t['tipo'] == 'Ingreso';
                                return ListTile(
                                  leading: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      esIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: esIngreso ? Colors.green : Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(t['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  subtitle: Text('${t['categoria'] ?? 'General'} • ${t['negocio'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  trailing: Text(
                                    '${esIngreso ? "+" : "-"}\$${(t['monto'] ?? 0).toStringAsFixed(2)}',
                                    style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // ✅ PESTAÑA "CUENTAS" (SALDOS EN TIEMPO REAL)
  // ==========================================
  Widget _buildCuentas() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💳 Mis Cuentas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Saldos calculados automáticamente', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                
                final cuentas = [
                  {'nombre': 'Efectivo', 'icon': Icons.money, 'color': Colors.green},
                  {'nombre': 'Banco', 'icon': Icons.account_balance, 'color': Colors.blue},
                  {'nombre': 'Tarjeta', 'icon': Icons.credit_card, 'color': Colors.orange},
                  {'nombre': 'Inversión', 'icon': Icons.trending_up, 'color': Colors.purple},
                ];

                return ListView.builder(
                  itemCount: cuentas.length,
                  itemBuilder: (context, index) {
                    final cuenta = cuentas[index];
                    double balance = 0;
                    int numTransacciones = 0;
                    
                    for (var doc in docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['cuenta'] == cuenta['nombre']) {
                        final monto = (data['monto'] ?? 0).toDouble();
                        if (data['tipo'] == 'Ingreso') balance += monto;
                        if (data['tipo'] == 'Gasto') balance -= monto;
                        numTransacciones++;
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF222222)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(color: (cuenta['color'] as Color).withOpacity(0.2), shape: BoxShape.circle),
                            child: Icon(cuenta['icon'] as IconData, color: cuenta['color'] as Color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cuenta['nombre'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                Text('$numTransacciones transacciones', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            '\$${balance.toStringAsFixed(2)}',
                            style: TextStyle(color: balance >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ✅ PESTAÑAS INGRESOS Y GASTOS (LISTA FILTRABLE)
  // ==========================================
  Widget _buildListaTransacciones(String tipo) {
    final colorPrincipal = tipo == 'Ingreso' ? Colors.green : Colors.red;
    final iconoPrincipal = tipo == 'Ingreso' ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF111111),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _categoriaFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _categoriaFiltro = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _cuentaFiltro,
                        decoration: const InputDecoration(
                          labelText: 'Cuenta',
                          filled: true,
                          fillColor: Color(0xFF1A1A1A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                        ),
                        dropdownColor: const Color(0xFF1A1A1A),
                        style: const TextStyle(color: Colors.white),
                        items: _cuentasLista.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setState(() => _cuentaFiltro = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _negocioFiltro,
                  decoration: const InputDecoration(
                    labelText: 'Negocio',
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)), borderSide: BorderSide.none),
                  ),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: _negocios.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setState(() => _negocioFiltro = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Solo pendientes', style: TextStyle(color: Colors.white, fontSize: 12)),
                        value: _soloPendientes,
                        activeColor: const Color(0xFF0066FF),
                        onChanged: (v) => setState(() => _soloPendientes = v ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Solo reconciliadas', style: TextStyle(color: Colors.white, fontSize: 12)),
                        value: _soloReconciliadas,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() => _soloReconciliadas = v ?? false),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }
                  
                  final transacciones = snapshot.data?.docs ?? [];
                  final filtrados = transacciones.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final concepto = (data['concepto'] ?? '').toString().toLowerCase();
                    final categoria = data['categoria'] ?? 'General';
                    final cuenta = data['cuenta'] ?? 'Efectivo';
                    final negocio = data['negocio'] ?? 'Minerales';
                    final reconciliada = data['reconciliada'] ?? false;
                    
                    return data['tipo'] == tipo && 
                           (_search.isEmpty || concepto.contains(_search)) && 
                           (_categoriaFiltro == 'Todas' || categoria == _categoriaFiltro) && 
                           (_cuentaFiltro == 'Todas' || cuenta == _cuentaFiltro) && 
                           (_negocioFiltro == 'Todos' || negocio == _negocioFiltro) && 
                           (!_soloPendientes || !reconciliada) && 
                           (!_soloReconciliadas || reconciliada);
                  }).toList();

                  if (filtrados.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(iconoPrincipal, color: Colors.grey, size: 64),
                          const SizedBox(height: 16),
                          Text('No hay ${tipo.toLowerCase()}s registrados', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  final total = filtrados.fold<double>(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['monto'] ?? 0).toDouble());

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: colorPrincipal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorPrincipal),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total:', style: TextStyle(color: colorPrincipal, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('\$${total.toStringAsFixed(2)}', style: TextStyle(color: colorPrincipal, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final doc = filtrados[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final acreedor = data['acreedor'] ?? '';
                            final reconciliada = data['reconciliada'] ?? false;
                            final tags = List<String>.from(data['tags'] ?? []);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: colorPrincipal.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(iconoPrincipal, color: colorPrincipal, size: 22),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(child: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                                if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text('${data['categoria'] ?? 'General'} • ${data['cuenta'] ?? 'Efectivo'} • ${data['negocio'] ?? 'Sin negocio'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            if (acreedor.isNotEmpty) Text('Acreedor: $acreedor', style: const TextStyle(color: Colors.orange, fontSize: 11)),
                                            if (tags.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 4,
                                                children: tags.map((t) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                                  child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)),
                                                )).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Text('\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: colorPrincipal, fontSize: 16, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.copy, color: Colors.blue, size: 18),
                                        onPressed: () => _duplicarTransaccion(data),
                                        tooltip: 'Duplicar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                                        onPressed: () => _mostrarFormularioTransaccion(transaccion: data, docId: doc.id),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                        onPressed: () => _confirmarEliminar(doc.id, data['concepto'] ?? ''),
                                        tooltip: 'Eliminar',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _duplicarTransaccion(Map<String, dynamic> data) async {
    await _firestore.collection('transacciones').add({
      'concepto': '${data['concepto']} (copia)',
      'monto': data['monto'] ?? 0,
      'categoria': data['categoria'] ?? 'General',
      'fecha': data['fecha'] ?? DateTime.now().toIso8601String().split('T')[0],
      'descripcion': data['descripcion'] ?? '',
      'metodo_pago': data['metodo_pago'] ?? 'Efectivo',
      'referencia': data['referencia'] ?? '',
      'tipo': data['tipo'] ?? 'Ingreso',
      'cuenta': data['cuenta'] ?? 'Efectivo',
      'subcuenta': data['subcuenta'] ?? 'Minerales',
      'negocio': data['negocio'] ?? 'Minerales',
      'acreedor': data['acreedor'] ?? '',
      'tags': data['tags'] ?? [],
      'reconciliada': false,
      'created_at': FieldValue.serverTimestamp(),
    });
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Duplicada'), backgroundColor: Colors.green));
  }

  Future<void> _confirmarEliminar(String id, String concepto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Eliminar transacción', style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "$concepto"?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestore.collection('transacciones').doc(id).delete();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Eliminado'), backgroundColor: Colors.red));
    }
  }

  // ==========================================
  // ✅ PESTAÑA "HOY"
  // ==========================================
  Widget _buildVistaHoy() {
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${hoy.day} de ${_meses[hoy.month - 1]} ${hoy.year}',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('transacciones').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Row(
                          children: [
                            Expanded(child: _miniCard('...', Icons.schedule, Colors.orange)),
                            const SizedBox(width: 12),
                            Expanded(child: _miniCard('...', Icons.check_circle, Colors.green)),
                          ],
                        );
                      }
                      final docs = snapshot.data!.docs;
                      int pendientes = 0;
                      int completadas = 0;
                      for (var doc in docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        if (data['fecha'] == fechaHoy) {
                          if (data['reconciliada'] == true) {
                            completadas++;
                          } else {
                            pendientes++;
                          }
                        }
                      }
                      return Row(
                        children: [
                          Expanded(child: _miniCard('$pendientes Pendientes', Icons.schedule, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _miniCard('$completadas Completadas', Icons.check_circle, Colors.green)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('📋 Transacciones de Hoy', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['fecha'] == fechaHoy).toList();
                if (docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy, color: Colors.grey, size: 64),
                        SizedBox(height: 16),
                        Text('No hay transacciones para hoy', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Usa el botón + para agregar una', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  );
                }

                double totalIngresos = 0;
                double totalGastos = 0;
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final monto = (data['monto'] ?? 0).toDouble();
                  if (data['tipo'] == 'Ingreso') {
                    totalIngresos += monto;
                  } else {
                    totalGastos += monto;
                  }
                }

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(children: [const Text('Ingresos', style: TextStyle(color: Colors.grey)), Text('\$${totalIngresos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold))]),
                          Column(children: [const Text('Gastos', style: TextStyle(color: Colors.grey)), Text('\$${totalGastos.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
                          Column(children: [const Text('Balance', style: TextStyle(color: Colors.grey)), Text('\$${(totalIngresos - totalGastos).toStringAsFixed(2)}', style: TextStyle(color: (totalIngresos - totalGastos) >= 0 ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ),
                    ...docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final esIngreso = data['tipo'] == 'Ingreso';
                      final reconciliada = data['reconciliada'] ?? false;
                      final tags = List<String>.from(data['tags'] ?? []);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: reconciliada ? Colors.green : const Color(0xFF222222)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: esIngreso ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(esIngreso ? Icons.arrow_upward : Icons.arrow_downward, color: esIngreso ? Colors.green : Colors.red, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(data['concepto'] ?? 'Sin concepto', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                      if (reconciliada) const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${data['categoria'] ?? 'General'} • ${data['negocio'] ?? 'Sin negocio'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  if (tags.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: tags.map((t) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFF0066FF).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                        child: Text(t, style: const TextStyle(color: Color(0xFF0066FF), fontSize: 10)),
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${esIngreso ? "+" : "-"}\$${(data['monto'] ?? 0).toStringAsFixed(2)}', style: TextStyle(color: esIngreso ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                if (!reconciliada)
                                  TextButton(
                                    onPressed: () async {
                                      await _firestore.collection('transacciones').doc(doc.id).update({'reconciliada': true});
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Transacción aprobada'), backgroundColor: Colors.green),
                                        );
                                      }
                                    },
                                    child: const Text('Aprobar', style: TextStyle(color: Color(0xFF0066FF), fontSize: 11)),
                                  )
                                else
                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCard(String titulo, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(titulo, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // ==========================================
  // ✅ PESTAÑA "RESUMEN"
  // ==========================================
  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0044AA)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Balance Total', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('transacciones').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
                      double ingresos = 0, gastos = 0;
                      for (var doc in snapshot.data!.docs) {
                        final data = doc.data() as Map<String, dynamic>;
                        final monto = (data['monto'] ?? 0).toDouble();
                        if (data['tipo'] == 'Ingreso') ingresos += monto;
                        if (data['tipo'] == 'Gasto') gastos += monto;
                      }
                      return Text('\$${(ingresos - gastos).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _tarjetaResumen('Ingresos', Colors.green, Icons.arrow_upward)),
                const SizedBox(width: 12),
                Expanded(child: _tarjetaResumen('Gastos', Colors.red, Icons.arrow_downward)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaResumen(String titulo, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF222222))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(titulo, style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('transacciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('\$0', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
              double total = 0;
              for (var doc in snapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['tipo'] == titulo) total += (data['monto'] ?? 0).toDouble();
              }
              return Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold));
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ✅ PESTAÑA "DASHBOARD" COMPACTO
  // ==========================================
  Widget _buildDashboard() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Dashboard Ejecutivo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Indicadores clave de rendimiento', style: TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('transacciones').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final docs = snapshot.data!.docs;
                double ingresos = 0, gastos = 0;
                int numTransacciones = 0;
                Map<String, double> porNegocio = {};

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final monto = (data['monto'] ?? 0).toDouble();
                  final tipo = data['tipo'] ?? '';
                  final negocio = data['negocio'] ?? 'Otros';

                  if (tipo == 'Ingreso') ingresos += monto;
                  if (tipo == 'Gasto') gastos += monto;
                  numTransacciones++;

                  porNegocio[negocio] = (porNegocio[negocio] ?? 0) + (tipo == 'Ingreso' ? monto : -monto);
                }

                final margenGanancia = ingresos > 0 ? ((ingresos - gastos) / ingresos * 100) : 0;
                final ticketPromedio = numTransacciones > 0 ? ingresos / numTransacciones : 0;
                final flujoNeto = ingresos - gastos;

                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.8,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: [
                        _kpiCard('Ingresos', '\$${ingresos.toStringAsFixed(0)}', Icons.trending_up, Colors.green),
                        _kpiCard('Gastos', '\$${gastos.toStringAsFixed(0)}', Icons.trending_down, Colors.red),
                        _kpiCard('Flujo Neto', '\$${flujoNeto.toStringAsFixed(0)}', Icons.account_balance_wallet, flujoNeto >= 0 ? Colors.green : Colors.red),
                        _kpiCard('Margen', '${margenGanancia.toStringAsFixed(1)}%', Icons.percent, Colors.blue),
                        _kpiCard('Ticket Prom.', '\$${ticketPromedio.toStringAsFixed(0)}', Icons.receipt_long, Colors.orange),
                        _kpiCard('Transacciones', '$numTransacciones', Icons.list_alt, Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('📈 Rendimiento por Negocio', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...porNegocio.entries.map((e) {
                      final porcentaje = ingresos > 0 ? (e.value / ingresos * 100).abs() : 0;
                      final color = e.value >= 0 ? Colors.green : Colors.red;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.key,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            Text(
                              '\$${e.value.toStringAsFixed(0)}',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${porcentaje.toStringAsFixed(1)}%',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 9)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String nombre) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, color: Colors.grey.shade700, size: 64),
          const SizedBox(height: 16),
          Text('$nombre - En desarrollo', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  void _mostrarFormularioTransaccion({Map<String, dynamic>? transaccion, String? docId}) {
    final conceptoCtrl = TextEditingController(text: transaccion?['concepto'] ?? '');
    final montoCtrl = TextEditingController(text: transaccion?['monto']?.toString() ?? '0');
    String tipo = transaccion?['tipo'] ?? 'Ingreso';
    String cuenta = transaccion?['cuenta'] ?? 'Efectivo';
    String negocio = transaccion?['negocio'] ?? 'Minerales';
    bool reconciliada = transaccion?['reconciliada'] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(transaccion == null ? Icons.add_circle : Icons.edit, color: const Color(0xFF0066FF), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        transaccion == null ? 'Nueva Transacción' : 'Editar',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: conceptoCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Concepto *',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: montoCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Ingreso', style: TextStyle(color: Colors.white)),
                        value: 'Ingreso',
                        groupValue: tipo,
                        activeColor: Colors.green,
                        onChanged: (v) => setSheetState(() => tipo = v!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Gasto', style: TextStyle(color: Colors.white)),
                        value: 'Gasto',
                        groupValue: tipo,
                        activeColor: Colors.red,
                        onChanged: (v) => setSheetState(() => tipo = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: cuenta,
                  decoration: const InputDecoration(
                    labelText: 'Cuenta',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: ['Efectivo', 'Banco', 'Tarjeta', 'Inversión'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setSheetState(() => cuenta = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: negocio,
                  decoration: const InputDecoration(
                    labelText: 'Negocio',
                    labelStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A1A),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: const Color(0xFF1A1A1A),
                  style: const TextStyle(color: Colors.white),
                  items: _negocios.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
                  onChanged: (v) => setSheetState(() => negocio = v!),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Reconciliada', style: TextStyle(color: Colors.white)),
                  value: reconciliada,
                  activeColor: Colors.green,
                  onChanged: (v) => setSheetState(() => reconciliada = v ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (conceptoCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('️ Concepto obligatorio'), backgroundColor: Colors.orange));
                        return;
                      }
                      final hoy = DateTime.now();
                      final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
                      final data = {
                        'concepto': conceptoCtrl.text.trim(),
                        'monto': double.tryParse(montoCtrl.text) ?? 0,
                        'tipo': tipo,
                        'cuenta': cuenta,
                        'negocio': negocio,
                        'categoria': 'General',
                        'fecha': transaccion?['fecha'] ?? fechaHoy,
                        'reconciliada': reconciliada,
                        'tags': transaccion?['tags'] ?? [],
                        'descripcion': transaccion?['descripcion'] ?? '',
                        'subcuenta': negocio,
                        'metodo_pago': 'Efectivo',
                        'referencia': '',
                        'acreedor': '',
                      };
                      if (docId == null) {
                        data['created_at'] = FieldValue.serverTimestamp();
                        await _firestore.collection('transacciones').add(data);
                      } else {
                        await _firestore.collection('transacciones').doc(docId).update(data);
                      }
                      Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(docId == null ? '✅ Creada' : '✅ Actualizada'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(transaccion == null ? 'Crear' : 'Guardar', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarTransferencia() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transferencia entre cuentas - Próximamente'), backgroundColor: Colors.orange),
    );
  }

  Future<void> _generarDatosEjemplo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Generar Datos', style: TextStyle(color: Colors.white)),
        content: const Text('¿Crear transacciones de ejemplo para hoy?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
        ],
      ),
    );
    if (confirm != true) return;
    
    final hoy = DateTime.now();
    final fechaHoy = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
    
    final ejemplos = [
      {'concepto': 'Venta del día', 'monto': 5000.0, 'categoria': 'Proyecto', 'tipo': 'Ingreso', 'negocio': 'Minerales', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#negocio']},
      {'concepto': 'Pago proveedor', 'monto': 1500.0, 'categoria': 'Deudas', 'tipo': 'Gasto', 'negocio': 'Combustible', 'cuenta': 'Efectivo', 'reconciliada': true, 'tags': ['#urgente']},
      {'concepto': 'Servicio consultoría', 'monto': 8000.0, 'categoria': 'Servicios', 'tipo': 'Ingreso', 'negocio': 'Proyectos', 'cuenta': 'Banco', 'reconciliada': false, 'tags': ['#cliente']},
    ];
    
    for (var t in ejemplos) {
      await _firestore.collection('transacciones').add({
        ...t,
        'fecha': fechaHoy,
        'descripcion': 'Ejemplo del día',
        'subcuenta': t['negocio'],
        'metodo_pago': 'Efectivo',
        'referencia': '',
        'acreedor': '',
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 3 transacciones de ejemplo creadas para hoy'), backgroundColor: Colors.green),
      );
    }
  }
}