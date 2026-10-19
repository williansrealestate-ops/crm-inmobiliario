class PlantillasService {
  static List<Map<String, dynamic>> getPlantillas() {
    return [
      {
        'id': 'contrato_exclusividad',
        'nombre': 'Contrato de Exclusividad',
        'icono': '📝',
        'color': '0xFF3B82F6',
        'descripcion': 'Contrato para captación exclusiva de inmueble',
        'campos': [
          {'id': 'propietario', 'label': 'Nombre del propietario', 'tipo': 'texto'},
          {'id': 'direccion', 'label': 'Dirección del inmueble', 'tipo': 'texto'},
          {'id': 'precio', 'label': 'Precio de venta/renta', 'tipo': 'texto'},
          {'id': 'vigencia', 'label': 'Vigencia (meses)', 'tipo': 'numero'},
          {'id': 'comision', 'label': 'Comisión (%)', 'tipo': 'numero'},
          {'id': 'fecha', 'label': 'Fecha de firma', 'tipo': 'fecha'},
        ],
      },
      {
        'id': 'ficha_tecnica',
        'nombre': 'Ficha Técnica',
        'icono': '',
        'color': '0xFF10B981',
        'descripcion': 'Ficha descriptiva del inmueble para clientes',
        'campos': [
          {'id': 'titulo', 'label': 'Título del inmueble', 'tipo': 'texto'},
          {'id': 'tipo', 'label': 'Tipo (Casa, Depto, etc.)', 'tipo': 'texto'},
          {'id': 'ubicacion', 'label': 'Ubicación completa', 'tipo': 'texto'},
          {'id': 'precio', 'label': 'Precio', 'tipo': 'texto'},
          {'id': 'area_terreno', 'label': 'Área de terreno (m²)', 'tipo': 'numero'},
          {'id': 'area_construccion', 'label': 'Área de construcción (m²)', 'tipo': 'numero'},
          {'id': 'habitaciones', 'label': 'Habitaciones', 'tipo': 'numero'},
          {'id': 'banos', 'label': 'Baños', 'tipo': 'numero'},
          {'id': 'estacionamientos', 'label': 'Estacionamientos', 'tipo': 'numero'},
          {'id': 'descripcion', 'label': 'Descripción', 'tipo': 'texto_largo'},
          {'id': 'caracteristicas', 'label': 'Características (una por línea)', 'tipo': 'texto_largo'},
        ],
      },
      {
        'id': 'carta_oferta',
        'nombre': 'Carta de Oferta',
        'icono': '💼',
        'color': '0xFFF59E0B',
        'descripcion': 'Carta formal de oferta de compra',
        'campos': [
          {'id': 'comprador', 'label': 'Nombre del comprador', 'tipo': 'texto'},
          {'id': 'vendedor', 'label': 'Nombre del vendedor', 'tipo': 'texto'},
          {'id': 'direccion', 'label': 'Dirección del inmueble', 'tipo': 'texto'},
          {'id': 'precio_oferta', 'label': 'Precio ofrecido', 'tipo': 'texto'},
          {'id': 'enganche', 'label': 'Enganche (%)', 'tipo': 'numero'},
          {'id': 'fecha_entrega', 'label': 'Fecha de entrega', 'tipo': 'fecha'},
          {'id': 'condiciones', 'label': 'Condiciones especiales', 'tipo': 'texto_largo'},
        ],
      },
      {
        'id': 'aviso_uif',
        'nombre': 'Aviso UIF (Antilavado)',
        'icono': '⚖️',
        'color': '0xFFEF4444',
        'descripcion': 'Formato de aviso para operaciones relevantes',
        'campos': [
          {'id': 'tipo_operacion', 'label': 'Tipo de operación', 'tipo': 'texto'},
          {'id': 'monto', 'label': 'Monto de la operación', 'tipo': 'texto'},
          {'id': 'cliente_nombre', 'label': 'Nombre del cliente', 'tipo': 'texto'},
          {'id': 'cliente_rfc', 'label': 'RFC del cliente', 'tipo': 'texto'},
          {'id': 'cliente_curp', 'label': 'CURP del cliente', 'tipo': 'texto'},
          {'id': 'beneficiario', 'label': 'Beneficiario controlador', 'tipo': 'texto'},
          {'id': 'origen_recursos', 'label': 'Origen de los recursos', 'tipo': 'texto'},
          {'id': 'fecha', 'label': 'Fecha de la operación', 'tipo': 'fecha'},
        ],
      },
    ];
  }

  static String generarDocumento(String plantillaId, Map<String, String> datos) {
    final hoy = DateTime.now();
    final fechaFormateada = '${hoy.day.toString().padLeft(2, '0')}/${hoy.month.toString().padLeft(2, '0')}/${hoy.year}';

    switch (plantillaId) {
      case 'contrato_exclusividad':
        return '''
CONTRATO DE EXCLUSIVIDAD PARA LA COMERCIALIZACIÓN DE INMUEBLE

En la ciudad de _______________, a los ${datos['fecha'] ?? fechaFormateada} días del mes en curso.

COMPARECEN:

Por una parte, el C. ${datos['propietario'] ?? '_________________'}, a quien en lo sucesivo se le denominará "EL PROPIETARIO".

Por otra parte, _________________________, a quien en lo sucesivo se le denominará "EL ASESOR INMOBILIARIO".

Ambas partes acuerdan celebrar el presente CONTRATO DE EXCLUSIVIDAD, al tenor de las siguientes:

CLÁUSULAS:

PRIMERA. - OBJETO: EL PROPIETARIO otorga en exclusiva a EL ASESOR INMOBILIARIO la comercialización del inmueble ubicado en: ${datos['direccion'] ?? '_________________'}.

SEGUNDA. - PRECIO: El inmueble se ofrecerá en venta/renta por la cantidad de ${datos['precio'] ?? '_________________'} (${_numeroALetras(datos['precio'] ?? '0')}).

TERCERA. - VIGENCIA: El presente contrato tendrá una vigencia de ${datos['vigencia'] ?? '3'} meses, contados a partir de la fecha de firma.

CUARTA. - COMISIÓN: EL PROPIETARIO se obliga a pagar a EL ASESOR INMOBILIARIO una comisión del ${datos['comision'] ?? '6'}% sobre el valor de la operación realizada.

QUINTA. - OBLIGACIONES DEL ASESOR:
- Promocionar el inmueble en portales especializados
- Realizar visitas guiadas a prospectos calificados
- Filtrar compradores/rentatarios serios
- Asesorar en el proceso legal y fiscal

SEXTA. - OBLIGACIONES DEL PROPIETARIO:
- No comercializar el inmueble por otros medios durante la vigencia
- Proporcionar documentación completa y veraz
- Permitir visitas coordinadas con previa notificación

SÉPTIMA. - RESCISIÓN: El incumplimiento de cualquiera de las cláusulas dará derecho a la otra parte a rescindir el contrato.

Leído que fue el presente contrato y enteradas las partes de su alcance y fuerza legal, lo firman por duplicado.


_____________________________           _____________________________
      EL PROPIETARIO                         EL ASESOR INMOBILIARIO
        ${datos['propietario'] ?? ''}                              _________________________
''';

      case 'ficha_tecnica':
        return '''
═══════════════════════════════════════════════════════════
                    FICHA TÉCNICA DEL INMUEBLE
═══════════════════════════════════════════════════════════

📌 ${datos['titulo'] ?? 'Título del inmueble'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 UBICACIÓN
${datos['ubicacion'] ?? 'Dirección no especificada'}

💰 PRECIO
${datos['precio'] ?? 'Por definir'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏗️ CARACTERÍSTICAS FÍSICAS

• Tipo de inmueble:    ${datos['tipo'] ?? 'No especificado'}
• Área de terreno:     ${datos['area_terreno'] ?? '0'} m²
• Área de construcción: ${datos['area_construccion'] ?? '0'} m²
• Habitaciones:        ${datos['habitaciones'] ?? '0'}
• Baños:               ${datos['banos'] ?? '0'}
• Estacionamientos:    ${datos['estacionamientos'] ?? '0'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 DESCRIPCIÓN

${datos['descripcion'] ?? 'Sin descripción disponible'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ CARACTERÍSTICAS DESTACADAS

${datos['caracteristicas'] ?? '• Sin características especificadas'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📞 CONTACTO

Para más información o agendar una visita, contacte a su asesor inmobiliario.

Documento generado el: $fechaFormateada
═══════════════════════════════════════════════════════════
''';

      case 'carta_oferta':
        return '''
CARTA DE OFERTA DE COMPRA

Lugar y fecha: _______________, ${datos['fecha_entrega'] ?? fechaFormateada}

A quien corresponda:

Por medio de la presente, yo ${datos['comprador'] ?? '_________________'}, manifiesto mi INTERÉS FORMAL en adquirir el inmueble ubicado en:

${datos['direccion'] ?? '_________________'}

Propongo las siguientes condiciones de compra:

1. PRECIO OFERTADO: ${datos['precio_oferta'] ?? '_________________'}

2. FORMA DE PAGO:
   • Enganche: ${datos['enganche'] ?? '10'}% del valor total
   • Resto mediante: [Crédito hipotecario / Contado / Otro]

3. FECHA TENTATIVA DE ESCRITURACIÓN: ${datos['fecha_entrega'] ?? 'Por definir'}

4. CONDICIONES ESPECIALES:
${datos['condiciones'] ?? '• Ninguna condición especial'}

5. VALIDEZ DE LA OFERTA: Esta oferta tendrá vigencia de 15 días naturales a partir de la fecha de entrega.

6. DOCUMENTACIÓN REQUERIDA:
   • Identificación oficial del comprador
   • Comprobante de ingresos
   • Pre-aprobación de crédito (en su caso)

Sin otro particular, quedo a sus órdenes para cualquier aclaración.


Atentamente,


_____________________________
${datos['comprador'] ?? 'Nombre del comprador'}
Comprador

Vendedor: ${datos['vendedor'] ?? '_________________'}
''';

      case 'aviso_uif':
        return '''
AVISO DE OPERACIÓN RELEVANTE
(Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita)

FOLIO: UIF-${DateTime.now().millisecondsSinceEpoch}
FECHA DE ELABORACIÓN: $fechaFormateada

═══════════════════════════════════════════════════════════

1. DATOS DE LA OPERACIÓN

Tipo de operación: ${datos['tipo_operacion'] ?? '_________________'}
Monto de la operación: ${datos['monto'] ?? '_________________'}
Fecha de la operación: ${datos['fecha'] ?? fechaFormateada}

═══════════════════════════════════════════════════════════

2. DATOS DEL CLIENTE

Nombre completo: ${datos['cliente_nombre'] ?? '_________________'}
RFC: ${datos['cliente_rfc'] ?? '_________________'}
CURP: ${datos['cliente_curp'] ?? '_________________'}

═══════════════════════════════════════════════════════════

3. BENEFICIARIO CONTROLADOR

Nombre: ${datos['beneficiario'] ?? '_________________'}
Relación con el cliente: _________________________

═══════════════════════════════════════════════════════════

4. ORIGEN DE LOS RECURSOS

${datos['origen_recursos'] ?? '_________________'}

═══════════════════════════════════════════════════════════

5. DECLARACIÓN

Bajo protesta de decir verdad, declaro que la información proporcionada es verídica y completa, conforme a lo establecido en la Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita.


_____________________________
Nombre y firma del asesor
Cédula profesional: _______________

NOTA: Este documento debe conservarse por 5 años conforme a la LFPIORPI.
═══════════════════════════════════════════════════════════
''';

      default:
        return 'Plantilla no encontrada.';
    }
  }

  static String _numeroALetras(String numero) {
    // Simplificado - en producción usar librería completa
    return '(cantidad con letra)';
  }
}