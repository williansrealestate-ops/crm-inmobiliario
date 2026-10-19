class ChatIAService {
  static String obtenerRespuesta(String mensaje) {
    final msg = mensaje.toLowerCase().trim();
    
    // Saludos
    if (_contiene(msg, ['hola', 'buenas', 'hey', 'saludos', 'buenos'])) {
      return '¡Hola! 👋 Soy el asistente virtual de Williams Real Estate. ¿En qué puedo ayudarte hoy?\n\nPuedo informarte sobre:\n• 🏠 Propiedades disponibles\n• 💰 Precios y financiamiento\n•  Ubicaciones\n• 📅 Agendar visitas\n• 📞 Datos de contacto';
    }
    
    // Despedidas
    if (_contiene(msg, ['adios', 'chao', 'hasta luego', 'gracias', 'bye'])) {
      return '¡Con gusto!  Si tienes más dudas, no dudes en escribirme. ¡Que tengas excelente día!';
    }
    
    // Precios y costos
    if (_contiene(msg, ['precio', 'costo', 'cuanto', 'cuánto', 'valor', 'cuanto cuesta', 'cuánto cuesta'])) {
      return ' Nuestros precios varían según la propiedad:\n\n• Terrenos: desde \$4.5M MXN\n• Casas: desde \$3M MXN\n• Departamentos: desde \$2M MXN\n• Haciendas: desde \$418M MXN\n\n¿Te interesa alguna propiedad en específico? Puedo darte detalles puntuales.';
    }
    
    // Financiamiento
    if (_contiene(msg, ['financiamiento', 'credito', 'crédito', 'hipoteca', 'pago', 'mensualidades', 'plan'])) {
      return '🏦 Opciones de financiamiento disponibles:\n\n• Crédito hipotecario bancario (INFONAVIT, FOVISSSTE, bancos)\n• Pago directo con el desarrollador\n• Leasing inmobiliario para locales\n• Planes de 5 a 20 años\n\n💡 Te recomiendo usar nuestra **Calculadora de Hipoteca** en el CRM para simular mensualidades. ¿Quieres que un asesor te contacte?';
    }
    
    // Ubicaciones
    if (_contiene(msg, ['ubicacion', 'ubicación', 'donde', 'dónde', 'zona', 'ciudad', 'estado'])) {
      return '📍 Tenemos propiedades en:\n\n• Jocotitlán, Estado de México\n• Cozumel, Quintana Roo\n• Manzanillo, Colima\n• Puebla\n• Dubai, UAE (inversión internacional)\n\n¿En qué zona te gustaría buscar?';
    }
    
    // Visitas y citas
    if (_contiene(msg, ['visita', 'agendar', 'cita', 'ver', 'conocer', 'recorrido', 'tour'])) {
      return '📅 ¡Excelente! Para agendar una visita:\n\n1. Selecciona la propiedad que te interesa\n2. Haz clic en el botón de **WhatsApp**\n3. Propón 2-3 fechas disponibles\n4. Un asesor confirmará en menos de 24 horas\n\n También puedes llamarnos directamente al **993-214-9996**';
    }
    
    // Contacto
    if (_contiene(msg, ['contacto', 'telefono', 'teléfono', 'whatsapp', 'email', 'correo', 'llamar', 'numero', 'número'])) {
      return '📞 Datos de contacto:\n\n• WhatsApp: 993-214-9996\n• Teléfono: 993-214-9996\n• Email: willians.realestate@gmail.com\n\n💬 Haz clic en el botón verde de WhatsApp (esquina inferior derecha) para chatear directamente con Williams.';
    }
    
    // Asesores
    if (_contiene(msg, ['asesor', 'agente', 'vendedor', 'persona', 'quien', 'quién'])) {
      return ' Contamos con un equipo de **83 asesores** especializados:\n\n• Asesores de ventas\n• Asesores de rentas\n• Especialistas en terrenos\n• Expertos en inversión internacional\n\n¿Necesitas un asesor para algo en particular?';
    }
    
    // Tipos de propiedades
    if (_contiene(msg, ['tipo', 'casa', 'departamento', 'terreno', 'local', 'oficina', 'hacienda'])) {
      return '🏠 Tipos de propiedades disponibles:\n\n• 🏡 Casas residenciales\n•  Departamentos\n• 🌳 Terrenos (agrícolas, comerciales, frente al mar)\n• 🏪 Locales comerciales\n• 🏙️ Oficinas\n• 🏛️ Haciendas históricas\n• ⛽ Gasolineras\n\n¿Cuál te interesa?';
    }
    
    // Inversión
    if (_contiene(msg, ['inversion', 'inversión', 'invertir', 'rentabilidad', 'roi', 'negocio'])) {
      return '📈 Oportunidades de inversión:\n\n• Terrenos en zonas de plusvalía (Cozumel, Manzanillo)\n• Locales comerciales en centros urbanos\n• Haciendas para desarrollo turístico\n• Propiedades en Dubai (mercado internacional)\n\n💡 Nuestro **ROI promedio** es del 12-18% anual. ¿Quieres ver propiedades de inversión?';
    }
    
    // Documentación
    if (_contiene(msg, ['documento', 'papeles', 'escritura', 'legal', 'contrato', 'requisito'])) {
      return ' Documentación necesaria:\n\n• Identificación oficial\n• Comprobante de ingresos\n• Estado de cuenta bancario\n• Pre-aprobación de crédito (si aplica)\n\n⚖️ Todas nuestras transacciones son respaldadas legalmente. ¿Necesitas más detalles?';
    }
    
    // Ayuda
    if (_contiene(msg, ['ayuda', 'help', 'no entiendo', 'como funciona', 'cómo funciona'])) {
      return ' Soy tu asistente virtual. Puedo ayudarte con:\n\n• Información de propiedades\n• Precios y financiamiento\n• Agendar visitas\n• Datos de contacto\n• Tipos de inversión\n\nEscribe tu pregunta o selecciona una opción rápida abajo. 👇';
    }
    
    // Respuesta por defecto
    return '🤔 No estoy seguro de entender tu pregunta. ¿Podrías reformularla?\n\nMientras tanto, te sugiero:\n• Explorar nuestra **Vitrina** de propiedades\n• Hablar directamente con un asesor por WhatsApp\n• Revisar la sección de **Academia** para más información\n\n¿En qué más puedo ayudarte?';
  }
  
  static List<String> getSugerencias() {
    return [
      '¿Qué propiedades tienen?',
      '¿Cómo agendar una visita?',
      'Opciones de financiamiento',
      'Datos de contacto',
      'Propiedades de inversión',
    ];
  }
  
  static bool _contiene(String texto, List<String> palabras) {
    return palabras.any((p) => texto.contains(p));
  }
}