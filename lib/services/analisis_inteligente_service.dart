import '../services/local_storage_service.dart';

class AnalisisInteligenteService {
  // ✅ Obtener resumen ejecutivo del negocio
  static Map<String, dynamic> getResumenEjecutivo() {
    final clientes = LocalStorageService.getClientes();
    final inmuebles = LocalStorageService.getInmuebles();
    final actividades = LocalStorageService.getActividades();
    final asesores = LocalStorageService.getAsesores();

    final hoy = DateTime.now();
    final hoyStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';
    final estaSemana = hoy.subtract(const Duration(days: 7));

    // Clientes activos
    final clientesActivos = clientes.where((c) => c['estado'] == 'Activo').length;
    final clientesNuevosSemana = clientes.where((c) {
      final fecha = c['fechaAlta'] ?? '';
      if (fecha.isEmpty) return false;
      try {
        final partes = fecha.split('/');
        final fechaAlta = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
        return fechaAlta.isAfter(estaSemana);
      } catch (e) {
        return false;
      }
    }).length;

    // Inmuebles por estado
    final disponibles = inmuebles.where((i) => i['estadoVenta'] == 'Disponible').length;
    final reservados = inmuebles.where((i) => i['estadoVenta'] == 'Reservado').length;
    final vendidos = inmuebles.where((i) => i['estadoVenta'] == 'Vendido').length;

    // Actividades
    final actividadesHoy = actividades.where((a) => a['fecha'] == hoyStr && a['completada'] != true).length;
    final actividadesPendientes = actividades.where((a) => a['completada'] != true).length;
    final actividadesAtrasadas = actividades.where((a) {
      if (a['completada'] == true) return false;
      final fecha = a['fecha'] ?? '';
      if (fecha.isEmpty) return false;
      try {
        final partes = fecha.split('/');
        final fechaAct = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
        return fechaAct.isBefore(hoy);
      } catch (e) {
        return false;
      }
    }).length;

    // Valor del portafolio
    final valorPortafolio = inmuebles.fold(0.0, (sum, i) => sum + (double.tryParse(i['precio']?.toString().replaceAll(',', '') ?? '0') ?? 0));
    final ingresosPotenciales = inmuebles.fold(0.0, (sum, i) => sum + (double.tryParse(i['comision']?.toString() ?? '0') ?? 0));

    return {
      'clientesActivos': clientesActivos,
      'clientesNuevosSemana': clientesNuevosSemana,
      'inmueblesDisponibles': disponibles,
      'inmueblesReservados': reservados,
      'inmueblesVendidos': vendidos,
      'actividadesHoy': actividadesHoy,
      'actividadesPendientes': actividadesPendientes,
      'actividadesAtrasadas': actividadesAtrasadas,
      'valorPortafolio': valorPortafolio,
      'ingresosPotenciales': ingresosPotenciales,
      'totalClientes': clientes.length,
      'totalInmuebles': inmuebles.length,
      'totalAsesores': asesores.length,
    };
  }

  // ✅ Obtener operaciones en proceso (reservadas)
  static List<Map<String, dynamic>> getOperacionesEnProceso() {
    final inmuebles = LocalStorageService.getInmuebles();
    return inmuebles.where((i) => i['estadoVenta'] == 'Reservado').toList();
  }

  // ✅ Obtener clientes calificados sin propiedad asignada
  static List<Map<String, dynamic>> getClientesCalificadosSinPropiedad() {
    final clientes = LocalStorageService.getClientes();
    final inmuebles = LocalStorageService.getInmuebles();

    return clientes.where((c) {
      if (c['estado'] != 'Activo') return false;
      if (c['tipo'] != 'Comprador') return false;
      final presupuesto = double.tryParse(c['presupuesto']?.toString().replaceAll(',', '') ?? '0') ?? 0;
      if (presupuesto == 0) return false;

      // Verificar si ya tiene propiedad asignada
      final tienePropiedad = inmuebles.any((i) => i['propietario'] == c['nombre']);
      return !tienePropiedad;
    }).toList();
  }

  // ✅ Obtener inmuebles sin visitas recientes
  static List<Map<String, dynamic>> getInmueblesSinVisitasRecientes() {
    final inmuebles = LocalStorageService.getInmuebles();
    final actividades = LocalStorageService.getActividades();
    final hoy = DateTime.now();
    final hace14Dias = hoy.subtract(const Duration(days: 14));

    return inmuebles.where((i) {
      if (i['estadoVenta'] != 'Disponible') return false;

      // Buscar últimas visitas
      final visitasRecientes = actividades.where((a) {
        if (a['tipo'] != 'Visita') return false;
        if (a['inmueble'] != i['titulo']) return false;
        final fecha = a['fecha'] ?? '';
        if (fecha.isEmpty) return false;
        try {
          final partes = fecha.split('/');
          final fechaAct = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
          return fechaAct.isAfter(hace14Dias);
        } catch (e) {
          return false;
        }
      }).length;

      return visitasRecientes == 0;
    }).toList();
  }

  // ✅ Generar recomendaciones diarias basadas en datos reales
  static List<Map<String, dynamic>> generarRecomendacionesDiarias() {
    final recomendaciones = <Map<String, dynamic>>[];
    final resumen = getResumenEjecutivo();
    final operacionesEnProceso = getOperacionesEnProceso();
    final clientesCalificados = getClientesCalificadosSinPropiedad();
    final inmueblesSinVisitas = getInmueblesSinVisitasRecientes();
    final actividades = LocalStorageService.getActividades();

    final hoy = DateTime.now();
    final hoyStr = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';

    // 1. Actividades del día
    final actividadesHoy = actividades.where((a) => a['fecha'] == hoyStr && a['completada'] != true).toList();
    if (actividadesHoy.isNotEmpty) {
      recomendaciones.add({
        'tipo': 'urgente',
        'titulo': ' Tienes ${actividadesHoy.length} actividades para hoy',
        'descripcion': 'Prioriza las actividades de hoy para mantener el momentum de tus operaciones.',
        'accion': 'Revisar actividades del día',
        'prioridad': 10,
      });
    }

    // 2. Operaciones reservadas que necesitan seguimiento
    for (var op in operacionesEnProceso) {
      final diasReservado = _calcularDiasDesdeFecha(op['fechaReserva'] ?? op['fechaIngreso'] ?? '');
      if (diasReservado > 7) {
        recomendaciones.add({
          'tipo': 'cerrar',
          'titulo': ' ${op['titulo']} lleva $diasReservado días reservado',
          'descripcion': 'Es momento de hacer seguimiento intensivo para cerrar esta operación. Contacta al comprador y al propietario.',
          'accion': 'Llamar al comprador',
          'prioridad': 9,
          'inmueble': op,
        });
      }
    }

    // 3. Clientes calificados sin propiedad
    if (clientesCalificados.isNotEmpty) {
      final cliente = clientesCalificados.first;
      final presupuesto = cliente['presupuesto'] ?? '0';
      recomendaciones.add({
        'tipo': 'oportunidad',
        'titulo': ' ${cliente['nombre']} busca propiedad con presupuesto de \$${_formatearNumero(presupuesto)}',
        'descripcion': 'Tienes un cliente calificado sin propiedad asignada. Busca inmuebles que coincidan con su perfil.',
        'accion': 'Buscar propiedades compatibles',
        'prioridad': 8,
        'cliente': cliente,
      });
    }

    // 4. Inmuebles sin visitas recientes
    if (inmueblesSinVisitas.isNotEmpty) {
      final inmueble = inmueblesSinVisitas.first;
      recomendaciones.add({
        'tipo': 'marketing',
        'titulo': '📢 ${inmueble['titulo']} no ha tenido visitas en 14 días',
        'descripcion': 'Este inmueble necesita más exposición. Considera renovar las fotos, ajustar el precio o intensificar el marketing.',
        'accion': 'Revisar estrategia de marketing',
        'prioridad': 7,
        'inmueble': inmueble,
      });
    }

    // 5. Actividades atrasadas
    if (resumen['actividadesAtrasadas'] > 0) {
      recomendaciones.add({
        'tipo': 'urgente',
        'titulo': '⚠️ Tienes ${resumen['actividadesAtrasadas']} actividades atrasadas',
        'descripcion': 'Las actividades atrasadas pueden estar enfriando operaciones. Reagenda o completa lo antes posible.',
        'accion': 'Revisar actividades atrasadas',
        'prioridad': 9,
      });
    }

    // 6. Seguimiento de clientes antiguos
    final clientesAntiguos = _getClientesSinSeguimientoReciente();
    if (clientesAntiguos.isNotEmpty) {
      final cliente = clientesAntiguos.first;
      recomendaciones.add({
        'tipo': 'seguimiento',
        'titulo': '📞 Haz seguimiento a ${cliente['nombre']}',
        'descripcion': 'No has tenido contacto con este cliente en más de 30 días. Un mensaje puede reactivar su interés.',
        'accion': 'Enviar mensaje de seguimiento',
        'prioridad': 6,
        'cliente': cliente,
      });
    }

    // 7. Propietarios con inmuebles antiguos
    final inmueblesAntiguos = _getInmueblesConMasDe90Dias();
    if (inmueblesAntiguos.isNotEmpty) {
      final inmueble = inmueblesAntiguos.first;
      recomendaciones.add({
        'tipo': 'captacion',
        'titulo': '🏠 ${inmueble['titulo']} lleva más de 90 días en el mercado',
        'descripcion': 'Considera hablar con el propietario sobre ajustar el precio o mejorar la estrategia de marketing.',
        'accion': 'Llamar al propietario',
        'prioridad': 7,
        'inmueble': inmueble,
      });
    }

    // Ordenar por prioridad
    recomendaciones.sort((a, b) => (b['prioridad'] as int).compareTo(a['prioridad'] as int));

    return recomendaciones.take(5).toList(); // Top 5 recomendaciones
  }

  // ✅ Análisis de perfil profesional
  static Map<String, dynamic> getAnalisisPerfil() {
    final clientes = LocalStorageService.getClientes();
    final inmuebles = LocalStorageService.getInmuebles();
    final actividades = LocalStorageService.getActividades();

    final totalVentas = inmuebles.where((i) => i['estadoVenta'] == 'Vendido').length;
    final totalIngresos = inmuebles.fold(0.0, (sum, i) => sum + (double.tryParse(i['comision']?.toString() ?? '0') ?? 0));
    final tasaCierre = inmuebles.isNotEmpty ? (totalVentas / inmuebles.length * 100) : 0;
    final actividadesCompletadas = actividades.where((a) => a['completada'] == true).length;
    final tasaProductividad = actividades.isNotEmpty ? (actividadesCompletadas / actividades.length * 100) : 0;

    // Nivel profesional
    String nivel;
    if (totalVentas >= 20 && tasaCierre >= 30) {
      nivel = 'Experto';
    } else if (totalVentas >= 10 && tasaCierre >= 20) {
      nivel = 'Avanzado';
    } else if (totalVentas >= 5) {
      nivel = 'Intermedio';
    } else {
      nivel = 'Principiante';
    }

    // Fortalezas y áreas de mejora
    final fortalezas = <String>[];
    final areasMejora = <String>[];

    if (tasaCierre >= 25) fortalezas.add('Alta tasa de cierre (${tasaCierre.toStringAsFixed(0)}%)');
    if (tasaProductividad >= 70) fortalezas.add('Excelente productividad (${tasaProductividad.toStringAsFixed(0)}%)');
    if (clientes.length >= 20) fortalezas.add('Buena base de clientes (${clientes.length})');

    if (tasaCierre < 20) areasMejora.add('Mejorar tasa de cierre (actual: ${tasaCierre.toStringAsFixed(0)}%)');
    if (tasaProductividad < 60) areasMejora.add('Aumentar productividad (actual: ${tasaProductividad.toStringAsFixed(0)}%)');
    if (clientes.length < 10) areasMejora.add('Expandir base de clientes (actual: ${clientes.length})');

    return {
      'nivel': nivel,
      'totalVentas': totalVentas,
      'totalIngresos': totalIngresos,
      'tasaCierre': tasaCierre,
      'tasaProductividad': tasaProductividad,
      'fortalezas': fortalezas,
      'areasMejora': areasMejora,
    };
  }

  // ✅ Generar mensaje de bienvenida personalizado
  static String generarMensajeBienvenida() {
    final resumen = getResumenEjecutivo();
    final recomendaciones = generarRecomendacionesDiarias();
    final perfil = getAnalisisPerfil();

    String mensaje = '¡Buenos días! 👋\n\n';
    mensaje += '**Resumen de hoy:**\n';
    mensaje += '• ${resumen['actividadesHoy']} actividades programadas\n';
    mensaje += '• ${resumen['inmueblesReservados']} operaciones en proceso\n';
    mensaje += '• ${resumen['clientesActivos']} clientes activos\n\n';

    if (recomendaciones.isNotEmpty) {
      mensaje += '** Top recomendación:**\n';
      mensaje += '${recomendaciones.first['titulo']}\n';
      mensaje += '${recomendaciones.first['descripcion']}\n\n';
    }

    mensaje += '**Tu nivel:** ${perfil['nivel']} 🏆\n';
    mensaje += '• Ventas: ${perfil['totalVentas']}\n';
    mensaje += '• Tasa de cierre: ${perfil['tasaCierre'].toStringAsFixed(0)}%\n\n';

    mensaje += '¿En qué puedo ayudarte hoy?';

    return mensaje;
  }

  // ✅ Métodos auxiliares
  static int _calcularDiasDesdeFecha(String fechaStr) {
    if (fechaStr.isEmpty) return 0;
    try {
      final partes = fechaStr.split('/');
      final fecha = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
      final hoy = DateTime.now();
      return hoy.difference(fecha).inDays;
    } catch (e) {
      return 0;
    }
  }

  static String _formatearNumero(String numero) {
    final valor = double.tryParse(numero.replaceAll(',', '')) ?? 0;
    if (valor >= 1000000) return '${(valor / 1000000).toStringAsFixed(1)}M';
    if (valor >= 1000) return '${(valor / 1000).toStringAsFixed(0)}K';
    return valor.toStringAsFixed(0);
  }

  static List<Map<String, dynamic>> _getClientesSinSeguimientoReciente() {
    final clientes = LocalStorageService.getClientes();
    final actividades = LocalStorageService.getActividades();
    final hoy = DateTime.now();
    final hace30Dias = hoy.subtract(const Duration(days: 30));

    return clientes.where((c) {
      if (c['estado'] != 'Activo') return false;

      final ultimoContacto = actividades.where((a) {
        if (a['cliente'] != c['nombre']) return false;
        final fecha = a['fecha'] ?? '';
        if (fecha.isEmpty) return false;
        try {
          final partes = fecha.split('/');
          final fechaAct = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
          return fechaAct.isAfter(hace30Dias);
        } catch (e) {
          return false;
        }
      }).isEmpty;

      return ultimoContacto;
    }).toList();
  }

  static List<Map<String, dynamic>> _getInmueblesConMasDe90Dias() {
    final inmuebles = LocalStorageService.getInmuebles();
    final hoy = DateTime.now();
    final hace90Dias = hoy.subtract(const Duration(days: 90));

    return inmuebles.where((i) {
      if (i['estadoVenta'] != 'Disponible') return false;
      final fecha = i['fechaIngreso'] ?? '';
      if (fecha.isEmpty) return false;
      try {
        final partes = fecha.split('/');
        final fechaIng = DateTime(int.parse(partes[2]), int.parse(partes[1]), int.parse(partes[0]));
        return fechaIng.isBefore(hace90Dias);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}