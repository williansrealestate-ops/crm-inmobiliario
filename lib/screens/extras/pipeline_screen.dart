import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/pipeline_service.dart';
import '../../services/integraciones_service.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  String _etapaSeleccionada = 'prospecto';

  @override
  Widget build(BuildContext context) {
    final resumen = PipelineService.getResumenPipeline();

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Row(children: [Icon(Icons.view_kanban, color: Colors.white), SizedBox(width: 8), Text('Pipeline de Ventas')]),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoOperacion(),
            tooltip: 'Nueva operación',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context), 
              border: Border(bottom: BorderSide(color: AppTheme.getBorderColor(context)))
            ),
            child: Row(
              children: [
                Expanded(child: _buildResumenItem('Total', resumen['total'], resumen['valorTotal'], const Color(0xFF0F172A))),
                const SizedBox(width: 12),
                Expanded(child: _buildResumenItem('En Proceso', _getEnProceso(resumen), _getValorEnProceso(resumen), const Color(0xFFF59E0B))),
                const SizedBox(width: 12),
                Expanded(child: _buildResumenItem('Cerradas', resumen['cerrado']['cantidad'], resumen['cerrado']['valor'], const Color(0xFF10B981))),
              ],
            ),
          ),

          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: PipelineService.etapas.length,
              itemBuilder: (context, index) {
                final etapa = PipelineService.etapas[index];
                final etapaId = etapa['id'];
                final datos = resumen[etapaId] as Map<String, dynamic>;
                final isSelected = _etapaSeleccionada == etapaId;
                final color = Color(int.parse(etapa['color']));

                return GestureDetector(
                  onTap: () => setState(() => _etapaSeleccionada = etapaId),
                  child: Container(
                    width: 155,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? color : AppTheme.getBorderColor(context), width: isSelected ? 2.5 : 1),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? color.withOpacity(0.15) : AppTheme.getShadowColor(context),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          '${etapa['icono']} ${etapa['nombre']}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? color : AppTheme.getTextSecondaryColor(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('${datos['cantidad']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
                        Text(PipelineService.formatearMoneda(datos['valor']), style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: _buildListaOperaciones(),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, int cantidad, double valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
          Text('$cantidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(PipelineService.formatearMoneda(valor), style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  int _getEnProceso(Map<String, dynamic> resumen) {
    int total = 0;
    for (var etapa in PipelineService.etapas) {
      final etapaId = etapa['id'];
      if (etapaId != 'cerrado') {
        total += ((resumen[etapaId] as Map<String, dynamic>)['cantidad'] as num).toInt();
      }
    }
    return total;
  }

  double _getValorEnProceso(Map<String, dynamic> resumen) {
    double total = 0;
    for (var etapa in PipelineService.etapas) {
      final etapaId = etapa['id'];
      if (etapaId != 'cerrado') {
        total += (resumen[etapaId] as Map<String, dynamic>)['valor'];
      }
    }
    return total;
  }

  Widget _buildListaOperaciones() {
    final operaciones = PipelineService.getOperacionesPorEtapa(_etapaSeleccionada);
    final etapaActual = PipelineService.etapas.firstWhere((e) => e['id'] == _etapaSeleccionada);
    final color = Color(int.parse(etapaActual['color']));

    if (operaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: color.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No hay operaciones en ${etapaActual['nombre']}', style: TextStyle(color: color.withOpacity(0.6), fontSize: 16)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _mostrarDialogoOperacion(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar operación'),
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: operaciones.length,
      itemBuilder: (context, index) {
        final op = operaciones[index];
        return _buildOperacionCard(op, color);
      },
    );
  }

  Widget _buildOperacionCard(Map<String, dynamic> op, Color colorEtapa) {
    final diasEnEtapa = _calcularDiasDesdeFecha(op['fechaEtapa'] ?? op['fechaCreacion'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
        boxShadow: [BoxShadow(color: AppTheme.getShadowColor(context), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(op['titulo'] ?? 'Sin título', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getTextColor(context))),
                    const SizedBox(height: 4),
                    Text(op['cliente'] ?? 'Sin cliente', style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondaryColor(context))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorEtapa.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('$diasEnEtapa días', style: TextStyle(color: colorEtapa, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: AppTheme.success),
              const SizedBox(width: 4),
              Text(PipelineService.formatearMoneda(op['valor'] ?? 0), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
              const Spacer(),
              Text(op['tipo'] ?? 'Venta', style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context))),
            ],
          ),
          if ((op['notas'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(op['notas'], style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context), fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _mostrarDialogoMover(op),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Mover', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: BorderSide(color: AppTheme.primary.withOpacity(0.3))),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _mostrarDialogoOperacion(operacion: op),
                color: const Color(0xFF3B82F6),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => _confirmarEliminar(op),
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoOperacion({Map<String, dynamic>? operacion}) {
    final tituloCtrl = TextEditingController(text: operacion?['titulo'] ?? '');
    final clienteCtrl = TextEditingController(text: operacion?['cliente'] ?? '');
    final valorCtrl = TextEditingController(text: operacion?['valor']?.toString() ?? '');
    final tipoCtrl = TextEditingController(text: operacion?['tipo'] ?? 'Venta');
    final notasCtrl = TextEditingController(text: operacion?['notas'] ?? '');
    String etapa = operacion?['etapa'] ?? 'prospecto';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text(operacion == null ? 'Nueva Operación' : 'Editar Operación', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloCtrl, decoration: const InputDecoration(labelText: 'Título/Propiedad', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: clienteCtrl, decoration: const InputDecoration(labelText: 'Cliente', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: valorCtrl, decoration: const InputDecoration(labelText: 'Valor (MXN)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tipoCtrl.text,
                  decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem<String>(value: 'Venta', child: Text('Venta')),
                    DropdownMenuItem<String>(value: 'Renta', child: Text('Renta')),
                  ],
                  onChanged: (value) => tipoCtrl.text = value ?? 'Venta',
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: etapa,
                  decoration: const InputDecoration(labelText: 'Etapa', border: OutlineInputBorder()),
                  items: PipelineService.etapas.map((e) => DropdownMenuItem<String>(value: e['id'] as String, child: Text('${e['icono']} ${e['nombre']}'))).toList(),
                  onChanged: (value) => setState(() => etapa = value ?? 'prospecto'),
                ),
                const SizedBox(height: 8),
                TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas', border: OutlineInputBorder()), maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final valor = double.tryParse(valorCtrl.text.replaceAll(',', ''));
                if (tituloCtrl.text.isNotEmpty && valor != null) {
                  if (operacion == null) {
                    PipelineService.agregarOperacion({
                      'titulo': tituloCtrl.text,
                      'cliente': clienteCtrl.text,
                      'valor': valor,
                      'tipo': tipoCtrl.text,
                      'etapa': etapa,
                      'notas': notasCtrl.text,
                      'fechaEtapa': DateTime.now().toIso8601String(),
                    });
                  } else {
                    PipelineService.actualizarOperacion(operacion['id'], {
                      'titulo': tituloCtrl.text,
                      'cliente': clienteCtrl.text,
                      'valor': valor,
                      'tipo': tipoCtrl.text,
                      'etapa': etapa,
                      'notas': notasCtrl.text,
                    });
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoMover(Map<String, dynamic> op) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Mover operación a:', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PipelineService.etapas.where((e) => e['id'] != op['etapa']).map((etapa) {
            final color = Color(int.parse(etapa['color']));
            final configActividad = PipelineService.actividadPorEtapa[etapa['id']];
            final esCierre = etapa['id'] == 'cerrado';
            
            return ListTile(
              leading: Text(etapa['icono'], style: const TextStyle(fontSize: 20)),
              title: Text(etapa['nombre'], style: TextStyle(color: AppTheme.getTextColor(context))),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (configActividad != null)
                    Text(' ${configActividad['titulo']}', style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondaryColor(context))),
                  if (esCierre)
                    const Text('💰 Comisión + 🏆 100 pts + 🏅 Badges', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                  if (!esCierre && configActividad != null)
                    const Text('🏆 Puntos de gamificación', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B))),
                ],
              ),
              trailing: Icon(Icons.arrow_forward, color: color),
              onTap: () {
                Navigator.pop(ctx);
                if (esCierre) {
                  _confirmarMovimientoConIntegraciones(op, etapa['id']);
                } else {
                  _confirmarMovimientoSimple(op, etapa['id']);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void _confirmarMovimientoConIntegraciones(Map<String, dynamic> op, String nuevaEtapa) {
    final configActividad = PipelineService.actividadPorEtapa[nuevaEtapa];
    double porcentajeComision = PipelineService.porcentajeComisionPorDefecto;
    bool registrarComision = true;
    String? inmuebleId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text('🎉 Cerrar operación', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mover "${op['titulo']}" a Cerrado?', style: TextStyle(color: AppTheme.getTextColor(context))),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📝 Se creará actividad:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      const SizedBox(height: 4),
                      if (configActividad != null) ...[
                        Text('• ${configActividad['titulo']}', style: const TextStyle(fontSize: 12)),
                        Text('• ${configActividad['descripcion']}', style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: registrarComision,
                            onChanged: (value) => setState(() => registrarComision = value ?? true),
                          ),
                          const Expanded(
                            child: Text('💰 Registrar comisión en Finanzas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                      if (registrarComision) ...[
                        const SizedBox(height: 8),
                        Text('Valor: ${PipelineService.formatearMoneda(op['valor'] ?? 0)}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('% Comisión:'),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), border: OutlineInputBorder()),
                                onChanged: (value) {
                                  final pct = double.tryParse(value);
                                  if (pct != null) setState(() => porcentajeComision = pct);
                                },
                                controller: TextEditingController(text: porcentajeComision.toString()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comisión: ${PipelineService.formatearMoneda((op['valor'] ?? 0) * (porcentajeComision / 100))}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🏆 Gamificación:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      SizedBox(height: 4),
                      Text('• +100 puntos por cerrar', style: TextStyle(fontSize: 12)),
                      Text('• Posibles badges especiales', style: TextStyle(fontSize: 12)),
                      Text('• Verificación de metas financieras', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final resultado = IntegracionesService.ejecutarIntegracionesAlMover(
                  op['id'], nuevaEtapa,
                  crearActividad: true,
                  registrarComision: registrarComision,
                  porcentajeComision: porcentajeComision,
                  inmuebleId: inmuebleId,
                );
                setState(() {});
                String mensaje = '✅ Operación cerrada\n\n';
                if (resultado['actividadCreada'] != null && resultado['actividadCreada'].toString().isNotEmpty) {
                  mensaje += '📝 Actividad: ${resultado['actividadCreada']}\n';
                }
                if (resultado['comisionRegistrada'] != null && resultado['comisionRegistrada'].toString().isNotEmpty) {
                  mensaje += '💰 Comisión: ${resultado['comisionRegistrada']}\n';
                }
                if (resultado['puntosGanados'] != null && resultado['puntosGanados'] > 0) {
                  mensaje += '🏆 Puntos: +${resultado['puntosGanados']}\n';
                }
                final badgesNuevos = (resultado['badgesNuevos'] as List? ?? []).cast<Map<String, dynamic>>();
                if (badgesNuevos.isNotEmpty) {
                  mensaje += ' Badges: ${badgesNuevos.length}\n';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(mensaje), backgroundColor: const Color(0xFF10B981), duration: const Duration(seconds: 5)),
                );
                if (badgesNuevos.isNotEmpty) {
                  Future.delayed(const Duration(seconds: 1), () => _mostrarBadgesDesbloqueados(badgesNuevos));
                }
              },
              child: const Text('Cerrar operación'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarMovimientoSimple(Map<String, dynamic> op, String nuevaEtapa) {
    final configActividad = PipelineService.actividadPorEtapa[nuevaEtapa];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('Confirmar movimiento', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mover "${op['titulo']}" a ${PipelineService.etapas.firstWhere((e) => e['id'] == nuevaEtapa)['nombre']}?', style: TextStyle(color: AppTheme.getTextColor(context))),
            if (configActividad != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 Se creará:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('• ${configActividad['titulo']}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('🏆 Ganarás puntos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final resultado = IntegracionesService.ejecutarIntegracionesAlMover(
                op['id'], nuevaEtapa,
                crearActividad: true,
                registrarComision: false,
              );
              setState(() {});
              String mensaje = '✅ Operación movida';
              if (resultado['actividadCreada'] != null && resultado['actividadCreada'].toString().isNotEmpty) {
                mensaje += '\n📝 Actividad creada';
              }
              if (resultado['puntosGanados'] != null && resultado['puntosGanados'] > 0) {
                mensaje += '\n🏆 +${resultado['puntosGanados']} puntos';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(mensaje), backgroundColor: const Color(0xFF10B981), duration: const Duration(seconds: 3)),
              );
            },
            child: const Text('Mover'),
          ),
        ],
      ),
    );
  }

  void _mostrarBadgesDesbloqueados(List<Map<String, dynamic>> badges) {
    for (var badge in badges) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.getSurfaceColor(context),
          title: Text('🏅 ¡Badge Desbloqueado!', style: TextStyle(color: AppTheme.getTextColor(context))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge['icono'] ?? '🏅', style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(badge['nombre'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.getTextColor(context))),
              const SizedBox(height: 8),
              Text(badge['descripcion'] ?? '', style: TextStyle(color: AppTheme.getTextSecondaryColor(context)), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('¡Genial!'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white)),
          ],
        ),
      );
    }
  }

  void _confirmarEliminar(Map<String, dynamic> op) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getSurfaceColor(context),
        title: Text('¿Eliminar operación?', style: TextStyle(color: AppTheme.getTextColor(context))),
        content: Text('¿Estás seguro de eliminar "${op['titulo']}"?', style: TextStyle(color: AppTheme.getTextSecondaryColor(context))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              PipelineService.eliminarOperacion(op['id']);
              Navigator.pop(ctx);
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  int _calcularDiasDesdeFecha(String fechaStr) {
    if (fechaStr.isEmpty) return 0;
    try {
      final fecha = DateTime.parse(fechaStr);
      return DateTime.now().difference(fecha).inDays;
    } catch (e) {
      return 0;
    }
  }
}