// ============================================================
// BASE DE CONOCIMIENTO ACADÉMICA - REAL ESTATE
// Versión: 2026.1
// Última actualización: Octubre 2026
// ============================================================

class ContenidoAcademico {
  static const String version = '2026.1';
  static const String ultimaActualizacion = 'Octubre 2026';

  // ============================================================
  // BASE DE CONOCIMIENTO PARA CHATBOT
  // ============================================================
  static final Map<String, Map<String, dynamic>> baseConocimientoChatbot = {
    'captacion': {
      'titulo': 'Captación de Inmuebles',
      'contenido': '''
🏠 **CAPTACIÓN PROFESIONAL DE INMUEBLES**

**1. PREPARACIÓN ANTES DE LA CAPTACIÓN:**
• Investiga la zona: precios por m², plusvalía (5 años), demanda
• Prepara tu presentación profesional (tarjetas, carpeta, tablet)
• Lleva AMV (Análisis de Mercado de Valores) pre-elaborado
• Revisa el historial de la propiedad en registros públicos

**2. PRIMERA VISITA AL PROPIETARIO:**
• Puntualidad (llega 5 min antes)
• Vestimenta formal
• Saludo cordial y presentación de credenciales AMPI
• Escucha activa: deja que el propietario hable primero
• Identifica su motivación real (¿por qué vende?)

**3. ANÁLISIS TÉCNICO DEL INMUEBLE:**
• Medidas reales (lleva cinta métrica láser)
• Estado de conservación (estructura, instalaciones, acabados)
• Documentación disponible (escrituras, predial, agua)
• Identifica plusvalías y minusvalías
• Toma fotografías profesionales (mínimo 20 fotos)

**4. PRESENTACIÓN DEL AMV:**
• Muestra 3-5 propiedades comparables vendidas
• Explica el método comparativo de mercado
• Justifica el precio recomendado con datos
• Entrega copia impresa del AMV al propietario

**5. CIERRE DE LA EXCLUSIVA:**
• Explica beneficios de la exclusividad vs. abierta
• Presenta contrato de exclusividad (3-6 meses)
• Define comisión (6% venta / 1 mes de renta)
• Establece plan de marketing personalizado
• Firma de contrato y entrega de documentación

**6. POST-CAPTACIÓN (Primeras 48 horas):**
• Fotografía profesional y tour virtual 360°
• Publicación en 5+ portales inmobiliarios
• Campaña en redes sociales segmentada
• Aviso a base de datos de clientes calificados
• Colocación de letrero "SE VENDE" en el inmueble
''',
      'caso': '''
💼 **CASO DE ÉXITO - CAPTACIÓN EN POLANCO, CDMX**

**Situación:** Casa de lujo en Polanco, propietario escéptico, 3 agentes previos fallaron.

**Estrategia aplicada:**
1. Investigación de 15 días del mercado de Polanco
2. AMV con 8 comparables (no 3 como usual)
3. Presentación con video de propiedades vendidas
4. Plan de marketing premium (fotógrafo profesional, drone, video cinematográfico)
5. Compromiso de 20 visitas calificadas en 30 días

**Resultado:**
• Captación en exclusiva por 6 meses
• Precio: \$45M MXN (propietario pedía \$52M)
• 23 visitas en 45 días
• Venta cerrada en \$44.5M en 52 días
• Comisión: \$2.67M MXN
• Propietario refirió 2 propiedades más

**Lección:** La preparación y profesionalismo vencen el escepticismo.
''',
    },
    'documentos': {
      'titulo': 'Documentación Legal Completa',
      'contenido': '''
📄 **DOCUMENTACIÓN ESENCIAL PARA OPERACIONES INMOBILIARIAS**

**A) PARA COMPRAVENTA DE INMUEBLES:**

**Del Vendedor:**
1. Escritura pública de propiedad (original y copia)
2. Identificación oficial vigente (INE/Pasaporte)
3. CURP actualizada
4. Comprobante de domicilio (no mayor a 3 meses)
5. Estado de cuenta predial (últimos 5 años pagados)
6. Estado de cuenta de agua (últimos 5 años pagados)
7. Certificado de Libertad de Gravamen (vigencia 30 días)
8. Constancia de Situación Fiscal (RFC activo)
9. Acreditación de origen de recursos (Ley Antilavado)
10. Acta de matrimonio (si es casado bajo sociedad conyugal)
11. Consentimiento del cónyuge (si aplica)
12. Juicio sucesorio o escritura de adjudicación (si es herencia)
13. Poder notarial (si actúa representante legal)

**Del Comprador:**
1. Identificación oficial vigente
2. CURP
3. Comprobante de domicilio
4. Constancia de Situación Fiscal
5. Pre-aprobación de crédito o comprobantes de fondos
6. Acreditación de origen de recursos

**B) PARA ARRENDAMIENTO:**

**Del Arrendador:**
1. Escritura de propiedad
2. Identificación oficial
3. RFC (para emitir recibos de arrendamiento)
4. Contrato de arrendamiento firmado

**Del Arrendatario:**
1. Identificación oficial
2. Comprobante de ingresos (3 meses)
3. Referencias personales (2)
4. Referencia laboral
5. Depósito en garantía (1-2 meses de renta)
6. Fiador o póliza jurídica

**C) DOCUMENTOS FISCALES:**
1. Factura de la comisión (CFDI)
2. Contrato de intermediación
3. Recibos de retención de ISR (si aplica)
4. Declaración anual del ejercicio

**D) DOCUMENTOS DE debida diligencia:**
1. Uso de suelo (certificado de la alcaldía/municipio)
2. Licencia de construcción (si aplica)
3. Manifestación de impacto ambiental (si aplica)
4. Certificado de zonificación
5. Alineamiento y número oficial

️ **IMPORTANTE:** Todos los documentos deben estar vigentes y en original para la firma ante notario.
''',
      'caso': '''
 **ERROR CRÍTICO EVITADO - CERTIFICADO DE GRAVAMEN**

**Situación:** Operación de \$8.5M MXN, todo parecía en orden.

**Hallazgo:** Al solicitar el Certificado de Libertad de Gravamen actualizado (con 15 días de antigüedad máximo), se descubrió:
• Embargo preventivo por demanda laboral del vendedor
• Hipoteca no cancelada de crédito Infonavit
• Adeudo predial de 3 años (\$45,000 MXN)

**Acción tomada:**
1. Se detuvo la operación inmediatamente
2. Se notificó al comprador y su abogado
3. Se exigió al vendedor resolver todas las cargas
4. Se renegoció el precio (-\$120,000 MXN por los adeudos)

**Resultado:** 
• Operación reanudada 45 días después
• Vendedor cubrió adeudos y canceló hipoteca
• Compra-venta exitosa con todas las cargas liberadas
• Cliente agradeció la profesionalidad

**Lección:** NUNCA confíes en documentos con más de 30 días de antigüedad. Solicita certificados actualizados 48 horas antes de la firma.
''',
    },
    'objeciones': {
      'titulo': 'Manejo Profesional de Objeciones',
      'contenido': '''
 **MANEJO PROFESIONAL DE OBJECIONES**

**FÓRMULA MAESTRA: ESCUCHAR - VALIDAR - REENCUADRAR - CERRAR**

**OBJECIÓN 1: "ES MUY CARO"**

❌ NO digas: "No es caro, es el precio de mercado"
✅ SÍ di: "Entiendo tu preocupación por el precio. ¿Qué te hace sentir que está alto?"

**Técnica del comparativo:**
"Te muestro 3 propiedades similares vendidas en los últimos 6 meses:
- Casa en Col. X: \$3.2M (vendida en 45 días)
- Casa en Col. Y: \$3.5M (vendida en 30 días)  
- Esta propiedad: \$3.4M (tiene 15% más de terreno)

El precio está alineado con el mercado. ¿Qué te parece si hacemos una oferta y negociamos?"

**OBJECIÓN 2: "LO VOY A PENSAR"**

❌ NO digas: "¿Qué hay que pensar? ¡Es una gran oportunidad!"
✅ SÍ di: "Claro, es una decisión importante. Para ayudarte a pensar mejor, ¿qué información adicional necesitas?"

**Técnica de la objeción oculta:**
"Normalmente cuando alguien me dice que lo va a pensar, es porque hay algo específico que le genera duda. ¿Es el precio, la ubicación, o algo más?"

**OBJECIÓN 3: "LA COMISIÓN ES MUY ALTA"**

 NO digas: "Es lo que cobra todo el mundo"
✅ SÍ di: "Entiendo. Te explico qué incluye mi comisión del 6%:"

**Desglose de valor:**
• Marketing profesional: \$25,000 (fotos, video, portales, ads)
• Filtrado de clientes: 40+ horas de trabajo
• Asesoría legal y fiscal incluida
• Blindaje contra operaciones riesgosas
• Seguimiento hasta escrituración
• Garantía de satisfacción

"Si vendes solo, ahorras el 6% pero asumes todos los riesgos. Mi comisión se paga sola con el mejor precio de venta."

**OBJECIÓN 4: "CONOZCO A OTRO AGENTE"**

✅ "Excelente, compara nuestros servicios. Yo ofrezco:
- Plan de marketing personalizado (no genérico)
- Reportes semanales de actividad
- Base de datos de 500+ clientes calificados
- Experiencia de X años en la zona
- Certificación AMPI y CONOCER

¿Qué te parece si hacemos una reunión sin compromiso para que compares?"

**OBJECIÓN 5: "NO TENGO PRISA"**

✅ "Perfecto, sin prisa. Pero déjame mostrarte el costo de esperar:"
• Inflación inmobiliaria: 8% anual en esta zona
• Mantenimiento del inmueble: \$5,000/mes
• Impuestos prediales: \$15,000/año
• Oportunidad de inversión del capital

"En 6 meses, 'no tener prisa' te cuesta aproximadamente \$180,000. ¿Vale la pena esperar?"

**OBJECIÓN 6: "NECESITO HABLARLO CON MI ESPOSA/ESPOSO"**

✅ "Por supuesto, es una decisión en pareja. ¿Qué te parece si agendamos una visita juntos este fin de semana? Así ambos conocen la propiedad y pueden tomar la decisión con toda la información."

**OBJECIÓN 7: "YA VIMOS OTRAS PROPIEDADES Y NO NOS GUSTARON"**

✅ "¿Qué fue específicamente lo que no les gustó de las otras? Así puedo filtrar mejor y mostrarles solo lo que realmente les va a encantar."

**OBJECIÓN 8: "EL MERCADO ESTÁ MAL"**

✅ "Es cierto que hay incertidumbre, pero precisamente por eso:"
• Las tasas de interés están bajando
• Hay menos competencia de compradores
• Los vendedores están más dispuestos a negociar
• Es el mejor momento para comprar a buen precio

"Los que compran en mercados 'malos' son los que más ganan cuando el mercado se recupera."
''',
      'caso': '''
💼 **OBJECIÓN MAESTRA - CIERRE DE \$12M EN 2 HORAS**

**Situación:** Cliente vio propiedad de \$12M. Le encantó pero dijo: "Necesito pensarlo, tengo otras opciones."

**Diagnóstico del asesor:**
- El cliente vio 3 propiedades esa semana
- Tenía pre-aprobación de crédito vigente
- Su esposa no estaba en la visita
- Hacía muchas preguntas específicas (señal de interés)

**Estrategia aplicada:**
1. **Validar:** "Entiendo, es una decisión importante de \$12M"
2. **Indagar:** "De las 3 propiedades que viste, ¿qué tiene esta que las otras no?"
3. **Descubrir:** Cliente admitió: "El jardín y la distribución son perfectos para mis hijos"
4. **Reencuadrar:** "Entonces ya encontraste lo que buscabas. Lo que falta es tomar la decisión"
5. **Urgencia real:** "El propietario me comentó que tiene otra visita mañana con oferta en mano"
6. **Cierre:** "¿Qué te parece si hacemos una oferta hoy y tu esposa la revisa esta noche?"

**Resultado:**
- Oferta presentada: \$11.7M (3% abajo del precio)
- Aceptada en 24 horas
- Escrituración en 30 días
- Comisión: \$702,000 MXN

**Lección:** La objeción "lo voy a pensar" casi siempre oculta miedo a decidir. Descubre el miedo real y ayúdalo a superarlo.
''',
    },
    'antilavado': {
      'titulo': 'Ley Antilavado (LFPIORPI) - Guía Completa 2026',
      'contenido': '''
⚖️ **LEY ANTILAVADO - CUMPLIMIENTO OBLIGATORIO 2026**

**LEY APLICABLE:** Ley Federal para la Prevención e Identificación de Operaciones con Recursos de Procedencia Ilícita (LFPIORPI)

**¿QUIÉNES ESTÁN OBLIGADOS?**
Todas las personas físicas y morales que realicen "Actividades Vulnerables", incluyendo:
• Compra-venta de inmuebles
• Arrendamiento de inmuebles
• Construcción inmobiliaria
• Fideicomisos inmobiliarios

**UMBRAL 2026 (Actualizado):**
• **Enajenación de inmuebles:** 7,350 UMAs (~\$785,000 MXN)
• **Arrendamiento:** 3,150 UMAs mensuales (~\$336,000 MXN/mes)
• **Construcción:** 3,675 UMAs (~\$392,000 MXN)

*UMA 2026: \$106.83 MXN diarios*

**OBLIGACIONES DEL ASESOR INMOBILIARIO:**

**1. IDENTIFICACIÓN DEL CLIENTE (KYC):**
Solicitar y conservar copia de:
• Identificación oficial vigente (INE/Pasaporte)
• CURP actualizada
• Comprobante de domicilio (no mayor a 3 meses)
• RFC (persona física o moral)
• Acta constitutiva (si es persona moral)
• Poder del representante legal (si aplica)

**2. IDENTIFICACIÓN DEL BENEFICIARIO CONTROLADOR:**
• ¿Quién es el dueño real del dinero?
• ¿Quién toma las decisiones finales?
• Documentar con declaración bajo protesta de decir verdad

**3. ORIGEN DE LOS RECURSOS:**
El cliente debe declarar por escrito el origen de los recursos:
• Salarios y sueldos
• Actividades empresariales
• Venta de otros bienes
• Herencias o donativos
• Rendimientos financieros
• Créditos bancarios

**4. AVISO A LA UIF:**
Cuando la operación supere el umbral, debes presentar:
• **Aviso de Operación Relevante** ante la UIF
• Plazo: dentro de los 5 días hábiles siguientes
• Plataforma: www.uif.gob.mx
• Formato: electrónico con e.firma

**5. CONSERVACIÓN DE DOCUMENTOS:**
• Tiempo mínimo: **5 años** después de la operación
• Formato: físico y digital
• Acceso: disponible para autoridades cuando lo soliciten

**6. REPORTE DE OPERACIONES INUSUALES:**
Debes reportar cuando detectes:
• Cliente que se niega a proporcionar información
• Pagos en efectivo por encima de lo razonable
• Inconsistencias en la información proporcionada
• Conducta nerviosa o evasiva del cliente
• Operaciones que no corresponden al perfil del cliente

**SANCIONES POR INCUMPLIMIENTO:**

**Multas económicas:**
• Leves: 100 a 5,000 UMAs (\$10,683 a \$534,150 MXN)
• Graves: 5,001 a 10,000 UMAs (\$534,257 a \$1,068,300 MXN)
• Muy graves: 10,001 a 200,000 UMAs (\$1,068,407 a \$21,366,000 MXN)

**Sanciones penales:**
• Prisión de 2 a 10 años por operaciones con recursos de procedencia ilícita
• Inhabilitación para ejercer la actividad
• Decomiso de bienes

**CHECKLIST ANTI-LAVADO POR OPERACIÓN:**

☐ Identificación oficial del cliente (vigente)
☐ CURP actualizada
☐ Comprobante de domicilio
☐ RFC activo
☐ Identificación del beneficiario controlador
 Declaración de origen de recursos (firmada)
☐ Verificación en listas restrictivas (OFAC, ONU)
☐ Análisis de perfil de riesgo del cliente
☐ Aviso a UIF (si supera umbral)
☐ Conservación de documentos (5 años)

**PERFIL DE RIESGO DEL CLIENTE:**

**RIESGO BAJO:**
• Empleado formal con salario comprobable
• Operación dentro de sus capacidades económicas
• Documentación completa y consistente

**RIESGO MEDIO:**
• Empresario con ingresos variables
• Operación ligeramente arriba de su perfil
• Algunas inconsistencias menores

**RIESGO ALTO:**
• Pago en efectivo sin justificación
• Se niega a proporcionar información
• Operación muy arriba de su perfil económico
• Aparece en listas restrictivas
• Conducta evasiva o nerviosa

⚠️ **REGLA DE ORO:** Ante la duda, NO realices la operación y consulta con un especialista en cumplimiento.
''',
      'caso': '''
💼 **CASO REAL - MULTA DE \$2.5M POR INCUMPLIMIENTO**

**Empresa:** Inmobiliaria "Los Pinos" en CDMX
**Año:** 2024
**Operación:** Venta de casa en Lomas de Chapultepec por \$18M MXN

**Lo que hicieron mal:**
1. No solicitaron origen de recursos del comprador
2. Buyer pagó \$5M en efectivo "sin preguntar"
3. No presentaron aviso a la UIF (superaba umbral)
4. No identificaron al beneficiario controlador (era testaferro)

**Lo que pasó:**
• UIF detectó patrón inusual en transacciones bancarias
• Investigación de 6 meses
• Multa de \$2.5M MXN a la inmobiliaria
• Multa de \$800K MXN al asesor responsable
• Inhabilitación de 3 años para ejercer
• Investigación penal por operaciones con recursos de procedencia ilícita

**El comprador:** Resultó ser funcionario público con recursos de corrupción. Condenado a 8 años de prisión.

**Lección:** No existe "no sabía". La ignorancia de la ley no exime de su cumplimiento. Cada operación es tu responsabilidad profesional y legal.

**¿Cómo evitarlo?**
1. Implementa protocolo de cumplimiento en tu inmobiliaria
2. Capacita a todos tus asesores anualmente
3. Usa checklists para cada operación
4. Consulta con abogado especialista en cumplimiento
5. Cuando algo "huela mal", no lo huelas más: repórtalo
''',
    },
    'precalificacion': {
      'titulo': 'Precalificación Profesional de Clientes',
      'contenido': '''
📈 **SISTEMA DE PRECALIFICACIÓN PROFESIONAL**

**¿POR QUÉ PRECALIFICAR?**
• Ahorras 60% de tiempo en visitas innecesarias
• Aumentas tu tasa de cierre de 10% a 35%
• Mejoras la experiencia del cliente
• Proteges tu tiempo y energía

**CHECKLIST DE PRECALIFICACIÓN (10 PUNTOS):**

**1. PRESUPUESTO Y FINANCIAMIENTO:**
¿Cuál es su presupuesto máximo?
¿Tiene crédito pre-aprobado o pagará de contado?
¿Cuál es su capacidad de pago mensual?
¿Tiene enganche disponible? (Mínimo 10-20%)

**2. URGENCIA Y TIEMPO:**
¿Cuándo necesita mudarse? (Escala 1-10)
¿Qué pasa si no encuentra en 3 meses?
¿Está rentando actualmente? ¿Cuándo vence su contrato?

**3. TOMA DE DECISIONES:**
¿Quién toma la decisión final?
¿Necesita consultar con alguien más? (esposa, socio, banco)
¿Ha comprado propiedades antes?

**4. NECESIDADES REALES:**
¿Qué busca específicamente? (recámaras, ubicación, amenidades)
¿Qué es NO NEGOCIABLE para usted?
¿Qué puede ceder si encuentra la propiedad ideal?

**5. HISTORIAL DE BÚSQUEDA:**
¿Ha visitado otras propiedades? ¿Cuáles?
¿Por qué no le gustaron?
¿Qué le gustó de las que visitó?

**SEÑALES DE CLIENTE CALIFICADO (SCORE 8-10):**
✅ Crédito pre-aprobado vigente
✅ Enganche disponible (10-20% mínimo)
✅ Urgencia real (mudanza en 60-90 días)
✅ Poder de decisión (no necesita consultar)
✅ Ha hecho research previo
✅ Hace preguntas específicas y técnicas
✅ Disponible para visitas en horarios flexibles
✅ Proporciona documentación sin resistencia

**SEÑALES DE CLIENTE NO CALIFICADO (SCORE 0-4):**
❌ "Solo estoy viendo"
❌ No tiene crédito ni enganche
 "No tengo prisa, quizás en un año"
❌ "Necesito que me digas cuánto me prestan"
❌ Cancela visitas constantemente
❌ Hace preguntas genéricas (no específicas)
❌ No proporciona información personal
❌ "Déjame checar con mi esposa" (y nunca regresa)

**SEÑALES DE CLIENTE MODERADO (SCORE 5-7):**
⚠️ Tiene interés pero le falta algo
⚠️ Puede calificarse en 30-60 días
⚠️ Merece seguimiento cada 15 días

**TÉCNICA DE CALIFICACIÓN BANT:**

**B - Budget (Presupuesto):**
"¿Cuál es el rango de inversión que tiene considerado?"
"¿Ya tiene definido cómo va a financiar la compra?"

**A - Authority (Autoridad):**
"¿Quién más participa en la decisión de compra?"
"¿Necesita consultar con alguien más antes de decidir?"

**N - Need (Necesidad):**
"¿Qué le motivó a buscar propiedad ahora?"
"¿Qué necesita que tenga la propiedad ideal?"

**T - Timing (Tiempo):**
"¿En qué tiempo le gustaría concretar la compra?"
"¿Qué pasa si no encuentra en los próximos 3 meses?"

**SCORE FINAL:**
• 8-10 puntos: Cliente HOT → Atención prioritaria
• 5-7 puntos: Cliente WARM → Seguimiento quincenal
• 0-4 puntos: Cliente COLD → Seguimiento mensual o descartar

**PREGUNTAS CLAVE PARA DETECTAR MENTIRAS:**

❓ "¿Cuánto tiene de enganche?"
→ Si duda o da respuestas vagas = NO tiene

❓ "¿Ya tiene pre-aprobación de crédito?"
→ Si dice "no pero voy a tramitar" = NO tiene financiamiento

❓ "¿Cuándo necesita mudarse?"
→ Si dice "sin prisa" = No es urgente

❓ "¿Quién más decide?"
→ Si menciona a muchas personas = No tiene autoridad

**PLANTILLA DE SEGUIMIENTO:**

Cliente: _________________
Fecha de contacto: _______
Score BANT: ___/10
Presupuesto: ______________
Financiamiento: ___________
Urgencia: ___/10
Decisor: _________________
Próximo contacto: ________
Notas: ___________________
''',
      'caso': '''
 **CASO DE ÉXITO - DE 50 LEADS A 8 VENTAS**

**Situación:** Asesor recibía 50 leads mensuales de portales, cerraba solo 1-2 ventas.

**Problema identificado:**
• Atendía a TODOS los leads por igual
• No calificaba antes de mostrar propiedades
• Hacía 30+ visitas al mes
• Tasa de cierre: 3%

**Solución implementada:**
1. Creó formulario de precalificación (10 preguntas)
2. Aplicó sistema BANT a cada lead
3. Clasificó en HOT/WARM/COLD
4. Solo mostró propiedades a clientes HOT (8-10)
5. Seguimiento quincenal a WARM (5-7)
6. Email automático mensual a COLD (0-4)

**Resultados en 6 meses:**
• Leads mensuales: 50 (igual)
• Clientes HOT atendidos: 12/mes (antes 50)
• Visitas realizadas: 18/mes (antes 30)
• Ventas cerradas: 4/mes (antes 1.5)
• Tasa de cierre: 33% (antes 3%)
• Ingresos: +167%

**Lección:** No se trata de atender más clientes, sino de atender MEJOR a los clientes correctos.
''',
    },
    'financiamiento': {
      'titulo': 'Financiamiento Hipotecario en México 2026',
      'contenido': '''
 **GUÍA COMPLETA DE FINANCIAMIENTO HIPOTECARIO 2026**

**A) CRÉDITOS DE VIVIENDA EN MÉXICO:**

**1. INFONAVIT:**
• **Para quién:** Trabajadores formales con salario registrado
• **Requisitos:** 1 año de cotización, cuenta individual activa
• **Tasas 2026:** Desde 4.5% anual (la más baja del mercado)
• **Plazo:** Hasta 30 años
• **Monto máximo:** \$1,050,000 MXN (crédito tradicional)
• **Monto máximo con Cofinavit:** \$2,500,000 MXN
• **Enganche:** Desde 10%
• **Ventajas:** Tasa baja, plazo largo, descuento de nómina
• **Desventajas:** Monto limitado, requisitos estrictos

**2. FOVISSSTE:**
• **Para quién:** Trabajadores del estado (ISSSTE)
• **Requisitos:** 1 año de cotización, subcuenta de vivienda
• **Tasas 2026:** Desde 5.5% anual
• **Plazo:** Hasta 30 años
• **Monto máximo:** \$1,200,000 MXN
• **Enganche:** Desde 10%

**3. CRÉDITOS BANCARIOS:**

**BBVA México:** Tasa desde 9.5% anual, enganche 10-20%, plazo 5-20 años, hasta \$10M MXN

**Santander:** Tasa desde 9.8% anual, enganche 10-20%, plazo 5-25 años, hasta \$8M MXN

**Banorte:** Tasa desde 9.9% anual, enganche 10-20%, plazo 5-20 años, hasta \$12M MXN

**HSBC:** Tasa desde 10.2% anual, enganche 15-20%, plazo 5-20 años, hasta \$15M MXN

**Scotiabank:** Tasa desde 10.5% anual, enganche 10-20%, plazo 5-20 años, hasta \$7M MXN

**4. COFINACAVIT (Infonavit + Banco):**
• Combina crédito Infonavit + crédito bancario
• **Monto máximo:** Hasta \$4,000,000 MXN
• **Ventaja:** Mayor poder de compra con tasa mixta

**B) DOCUMENTOS PARA PRECALIFICACIÓN BANCARIA:**

**Empleado asalariado:**
• 3 últimos recibos de nómina
• Estados de cuenta bancarios (3 meses)
• Identificación oficial (INE/Pasaporte)
• Comprobante de domicilio
• RFC y CURP
• Carta de antigüedad laboral
• Buró de crédito (el banco lo consulta)

**Empresario/Independiente:**
• Declaraciones fiscales (2 años)
• Estados de cuenta bancarios (6 meses)
• Identificación oficial
• Comprobante de domicilio
• RFC
• Estados financieros (si es persona moral)

**C) CÁLCULO DE CAPACIDAD DE PAGO:**

**Regla del 30%:**
La mensualidad no debe exceder el 30% de tus ingresos netos mensuales.

**Ejemplo:**
• Ingreso neto mensual: \$50,000
• Pago máximo mensual: \$15,000 (30%)
• Con tasa 9.5% a 20 años: Crédito de ~\$1,600,000

**D) COSTOS ADICIONALES DE LA COMPRA:**

**Gastos de escrituración (5-8% del valor):**
• Honorarios notariales: 1-2%
• Impuesto de Adquisición de Inmuebles (ISAI): 2-5% (varía por estado)
• Registro público: 0.5-1%
• Avalúo: \$3,000-\$8,000
• Gastos administrativos: \$5,000-\$15,000

**Ejemplo práctico:**
• Precio del inmueble: \$3,000,000
• Enganche 20%: \$600,000
• Crédito: \$2,400,000
• Gastos de escrituración (7%): \$210,000
• **Total necesario:** \$810,000

**E) SEGURO DE VIDA Y DAÑOS:**
• **Obligatorio** en créditos bancarios
• **Costo:** 0.3-0.5% anual del saldo insoluto
• **Cobertura:** Muerte, invalidez, daños al inmueble
''',
      'caso': '''
💼 **CASO DE ÉXITO - COFINACAVIT SALVÓ LA VENTA**

**Situación:** Familia joven quería casa de \$2.8M en Querétaro.

**Problema:**
• Crédito Infonavit individual: \$950,000 (insuficiente)
• Crédito bancario: Tasa 10.5% (muy cara para ellos)
• Enganche disponible: \$400,000 (14%)

**Solución encontrada:**
1. **Cofinacavit:** Infonavit (\$950K) + Banco (\$1.45M) = \$2.4M
2. **Tasa mixta:** 6.8% promedio (vs 10.5% bancario)
3. **Enganche:** \$400K (14%, aceptable)
4. **Mensualidad:** \$18,500 (30% de ingresos de \$62,000)

**Resultado:**
• Crédito aprobado en 21 días
• Compra realizada en 45 días
• Familia feliz en su casa nueva
• Asesor ganó comisión de \$168,000

**Lección:** Conoce TODAS las opciones de financiamiento. El Cofinacavit es la mejor opción cuando Infonavit solo no alcanza pero el banco es muy caro.
''',
    },
    'valuacion': {
      'titulo': 'Valuación Profesional de Inmuebles',
      'contenido': '''
📊 **VALUACIÓN PROFESIONAL DE INMUEBLES**

**A) MÉTODOS DE VALUACIÓN:**

**1. MÉTODO COMPARATIVO DE MERCADO (MCM) - MÁS USADO:**

**Paso 1: Selección de comparables**
• Busca 3-5 propiedades similares vendidas en los últimos 6 meses
• Mismo tipo de inmueble (casa, depto, terreno)
• Misma zona o zona comparable
• Características similares (tamaño, antigüedad, acabados)

**Paso 2: Ajustes por diferencias**

**Factor Ubicación:**
• Misma colonia: 0%
• Colonia similar: ±5%
• Colonia diferente: ±10-15%

**Factor Tamaño:**
• Por m² de terreno: valor proporcional
• Por m² de construcción: valor proporcional

**Factor Antigüedad:**
• Nueva (0-5 años): +10%
• Seminueva (5-15 años): 0%
• Antigua (15+ años): -10-20%

**Factor Acabados:**
• Lujo: +15-25%
• Medio: 0%
• Básico: -10-15%

**Factor Amenidades:**
• Alberca: +5-8%
• Jardín amplio: +3-5%
• Seguridad 24/7: +5-10%
• Estacionamiento extra: +2-3%

**Paso 3: Cálculo del valor**
• Promedia los valores ajustados de los comparables
• Considera condiciones actuales del mercado
• Ajusta por oferta y demanda local

**Ejemplo práctico:**
• Comparable 1: \$3.2M (ajustado +5% ubicación) = \$3.36M
• Comparable 2: \$3.5M (ajustado -10% antigüedad) = \$3.15M
• Comparable 3: \$3.1M (ajustado +8% acabados) = \$3.35M
• **Valor estimado:** (\$3.36M + \$3.15M + \$3.35M) / 3 = **\$3.29M**

**2. MÉTODO DE CAPITALIZACIÓN DE RENTAS (Para inversión):**

**Fórmula:**
Valor = Renta anual neta / Tasa de capitalización

**Ejemplo:**
• Renta mensual: \$25,000
• Renta anual: \$300,000
• Tasa de capitalización: 8% (0.08)
• **Valor:** \$300,000 / 0.08 = **\$3,750,000**

**Tasas de capitalización por tipo:**
• Residencial: 6-8%
• Comercial: 8-10%
• Industrial: 10-12%
• Terrenos: 4-6%

**3. MÉTODO DE COSTO (Para propiedades únicas):**

**Fórmula:**
Valor = Valor del terreno + Costo de construcción - Depreciación

**Ejemplo:**
• Terreno: \$1,500,000
• Construcción (200 m² × \$15,000/m²): \$3,000,000
• Depreciación (10 años × 2%): -\$600,000
• **Valor:** \$1,500,000 + \$3,000,000 - \$600,000 = **\$3,900,000**

**B) FACTORES QUE AFECTAN EL VALOR:**

**Factores POSITIVOS (+):**
✅ Ubicación en zona de plusvalía
✅ Cerca de escuelas, hospitales, centros comerciales
✅ Seguridad de la zona
✅ Vías de acceso y transporte público
✅ Servicios públicos (agua, luz, drenaje, gas)
✅ Acabados de calidad
✅ Diseño arquitectónico funcional
✅ Iluminación natural
✅ Ventilación cruzada
✅ Áreas verdes
✅ Seguridad privada
✅ Amenidades (alberca, gimnasio, salón de eventos)

**Factores NEGATIVOS (-):**
❌ Zona de riesgo (inundación, deslizamiento)
❌ Contaminación ambiental o sonora
❌ Falta de servicios públicos
❌ Mal estado de conservación
❌ Diseño obsoleto o poco funcional
❌ Problemas legales (gravámenes, litigios)
❌ Vecindario conflictivo
❌ Mala orientación (sol directo todo el día)

**C) HERRAMIENTAS DE VALUACIÓN:**

**Gratuitas:**
• Portal de la SHF (Sociedad Hipotecaria Federal): www.shf.gob.mx
• INEGI: Precios de vivienda por zona
• Comparadores online: Propiedades.com, Lamudi, Inmuebles24
• Registro Público de la Propiedad (RPP)

**De pago:**
• Avalúos certificados por valuador autorizado: \$3,000-\$8,000
• Software especializado: Valúo, InmueblesPro
• Consultoría de mercado: \$10,000-\$50,000

**D) TIPOS DE AVALÚO:**

**1. Avalúo Comercial:** Para determinar precio de venta/renta. Vigencia: 6 meses. Costo: \$3,000-\$8,000

**2. Avalúo Fiscal:** Para cálculo de impuestos (ISAI, ISR). Lo realiza el municipio o estado.

**3. Avalúo Bancario:** Para créditos hipotecarios. Lo realiza el banco o perito autorizado.

**4. Avalúo de Seguro:** Para pólizas de seguro. Considera costo de reconstrucción.

**E) ERRORES COMUNES EN VALUACIÓN:**

❌ **Valuar solo por precio de publicación** (no de venta real)
❌ **No considerar el tiempo en el mercado** (si lleva 6+ meses, está sobrevaluada)
❌ **Ignorar tendencias del mercado** (¿sube o baja la zona?)
❌ **No ajustar por diferencias reales** (no es lo mismo 200m² que 250m²)
❌ **Valuar por emoción** (el propietario "cree" que vale más)
❌ **Usar comparables de hace más de 6 meses** (el mercado cambia)
❌ **No considerar costos de mantenimiento** (inmuebles viejos valen menos)

**F) PRECIO DE LISTA vs. PRECIO DE VENTA:**

**Regla general:**
• Precio de lista: 5-10% arriba del valor de mercado
• Precio de venta real: 3-7% abajo del precio de lista
• Tiempo promedio de venta: 90-180 días

**Ejemplo:**
• Valor de mercado: \$3,000,000
• Precio de lista: \$3,150,000 (5% arriba)
• Precio de venta esperado: \$2,900,000 (8% abajo del lista)
• Negociación típica: 5-10%

**G) TENDENCIAS DE MERCADO 2026:**

**Nacional:**
• Plusvalía promedio: 6-8% anual
• Zonas de alta plusvalía: Querétaro, Mérida, Tulum, CDMX (zonas específicas)
• Tasas de interés: Bajando (9.5-10.5% bancario)
• Demanda: Alta en vivienda media y media-plus

**Por tipo:**
• Casas: +7% plusvalía anual
• Departamentos: +5% plusvalía anual
• Terrenos: +10% plusvalía anual (zonas de crecimiento)
• Locales comerciales: +4% plusvalía anual
• Oficinas: +3% plusvalía anual (home office redujo demanda)
''',
      'caso': '''
💼 **ERROR DE VALUACIÓN - 8 MESES SIN VENDER**

**Situación:** Casa en Coyoacán, CDMX. Propietario insistía en \$6.5M.

**Valuación del asesor (correcta):** \$5.8M basado en:
• 4 comparables vendidos en 6 meses
• Ajustes por antigüedad (25 años)
• Ajustes por acabados (necesita remodelación)
• Tendencia de la zona (estable)

**Lo que pasó:**
• Propietario no aceptó el AMV
• Publicó en \$6.5M por su cuenta
• 8 meses sin una sola visita seria
• 3 ofertas rechazadas (\$5.5M, \$5.7M, \$5.9M)
• Finalmente aceptó \$5.6M (8 meses después)

**Costo de esperar:**
• 8 meses de mantenimiento: \$40,000
• 8 meses de predial y agua: \$24,000
• Oportunidad de inversión perdida: \$180,000
• **Total perdido:** \$244,000

**Lección:** El mercado siempre tiene la razón. Un precio correcto vende en 60-90 días. Un precio inflado cuesta dinero cada mes que pasa.
''',
    },
    'marketing': {
      'titulo': 'Marketing Digital Inmobiliario 2026',
      'contenido': '''
📱 **MARKETING DIGITAL INMOBILIARIO 2026**

**A) ESTRATEGIA INTEGRADA DE MARKETING:**

**1. PORTALES INMOBILIARIOS (40% de leads):**

**Principales portales México:**
• Inmuebles24.com (mayor tráfico)
• Lamudi.com.mx (segundo lugar)
• Propiedades.com (tercero)
• Vivanuncios.com (cuarto)
• MercadoLibre Inmuebles (quinto)

**Costos mensuales:**
• Plan básico: \$1,500-\$3,000/mes (3-5 propiedades)
• Plan profesional: \$5,000-\$8,000/mes (10-15 propiedades)
• Plan enterprise: \$12,000-\$20,000/mes (ilimitadas)

**Mejores prácticas:**
• Mínimo 20 fotos profesionales por propiedad
• Título atractivo: "Casa 3 rec en [Colonia] con alberca"
• Descripción detallada (mínimo 300 palabras)
• Precio correcto (no inflado)
• Actualización semanal de publicaciones
• Respuesta a mensajes en menos de 2 horas

**2. REDES SOCIALES (35% de leads):**

**Facebook Ads:**
• **Presupuesto:** \$3,000-\$10,000/mes
• **Segmentación:** Zona geográfica + poder adquisitivo + intereses
• **Formatos:** Carrusel (5-10 fotos), Video (30-60 seg), Lead Ads
• **Métricas clave:** Costo por lead \$150-\$400, CTR 1-3%

**Instagram:**
• **Contenido:** Fotos profesionales, Reels de tours, Stories diarios
• **Hashtags:** #bienesraices #casasenventa #[ciudad] #inmuebles
• **Frecuencia:** 1 post diario + 3-5 stories
• **Colaboraciones:** Influencers locales de lifestyle

**TikTok:**
• **Contenido:** Tours virtuales cortos (15-30 seg), tips inmobiliarios
• **Formato:** Vertical, música trending, texto en pantalla
• **Frecuencia:** 3-5 videos por semana
• **Viralidad:** Alto potencial de alcance orgánico

**LinkedIn:**
• **Para:** Clientes corporativos, inversionistas, oficinas
• **Contenido:** Artículos de mercado, análisis de inversión
• **Frecuencia:** 2-3 posts por semana

**YouTube:**
• **Contenido:** Tours virtuales largos (5-10 min), videos educativos
• **SEO:** Títulos con palabras clave, descripciones detalladas
• **Frecuencia:** 1-2 videos por semana

**3. SITIO WEB PROPIO (15% de leads):**

**Elementos esenciales:**
• Dominio profesional: tunombre.com
• Diseño responsive (móvil y desktop)
• Catálogo de propiedades con filtros
• Formulario de contacto en cada propiedad
• Blog con contenido de valor (SEO)
• Testimonios de clientes
• Certificaciones y credenciales

**Costos:**
• Dominio: \$300-\$500/año
• Hosting: \$1,000-\$3,000/año
• Diseño: \$15,000-\$50,000 (una vez)
• Mantenimiento: \$2,000-\$5,000/mes

**4. EMAIL MARKETING (10% de leads):**

**Estrategia:**
• Base de datos segmentada (compradores, vendedores, inversionistas)
• Newsletter mensual con propiedades nuevas
• Automatización de seguimiento
• Campañas de reactivación de clientes inactivos

**Herramientas:**
• Mailchimp (gratis hasta 500 contactos)
• ActiveCampaign (\$500-\$2,000/mes)
• HubSpot (gratis hasta 1,000 contactos)

**Métricas:**
• Tasa de apertura: 20-30%
• Tasa de clics: 3-5%
• Tasa de conversión: 1-2%

**5. GOOGLE ADS Y SEO (5% de leads):**

**Google Ads:**
• **Presupuesto:** \$5,000-\$15,000/mes
• **Keywords:** "casas en venta en [zona]", "departamentos [ciudad]"
• **Costo por clic:** \$15-\$50
• **Conversión:** 2-5%

**SEO Local:**
• Google My Business optimizado
• Reseñas de clientes (mínimo 20)
• Palabras clave locales en sitio web
• Directorios inmobiliarios

**B) CONTENIDO DE VALOR:**

**Tipos de contenido que funcionan:**

**Educativo:**
• "Cómo comprar tu primera casa"
• "Guía de financiamiento hipotecario"
• "Documentos necesarios para vender"
• "Errores comunes al comprar propiedad"

**De mercado:**
• "Tendencias del mercado inmobiliario 2026"
• "Zonas con mayor plusvalía en [ciudad]"
• "Análisis de precios por colonia"

**De propiedades:**
• Tours virtuales
• Antes y después de remodelaciones
• "Casa del día"
• Comparativos de propiedades

**Testimoniales:**
• Historias de clientes satisfechos
• Casos de éxito
• Reseñas en video

**C) PRESUPUESTO RECOMENDADO:**

**Asesor independiente:**
• Portales: \$3,000/mes
• Facebook Ads: \$5,000/mes
• Fotografía: \$2,000/propiedad
• **Total:** \$10,000-\$15,000/mes

**Inmobiliaria pequeña (3-5 asesores):**
• Portales: \$8,000/mes
• Facebook Ads: \$15,000/mes
• Sitio web: \$5,000/mes
• Fotografía: \$5,000/mes
• **Total:** \$33,000-\$40,000/mes

**Inmobiliaria mediana (10-20 asesores):**
• Portales: \$20,000/mes
• Facebook Ads: \$40,000/mes
• Sitio web: \$10,000/mes
• Fotografía y video: \$15,000/mes
• Email marketing: \$3,000/mes
• **Total:** \$88,000-\$100,000/mes

**D) MÉTRICAS CLAVE (KPIs):**

**Leads:**
• Costo por lead (CPL): \$150-\$400
• Tasa de conversión lead a visita: 20-30%
• Tasa de conversión visita a oferta: 10-15%
• Tasa de conversión oferta a venta: 30-50%

**Redes sociales:**
• Alcance: 10,000-50,000/mes
• Engagement rate: 3-7%
• Seguidores nuevos: 100-500/mes
• Shares y saves: 50-200/mes

**ROI (Retorno de Inversión):**
• Inversión mensual: \$50,000
• Ventas generadas: 2/mes
• Comisión promedio: \$300,000
• Ingresos: \$600,000
• **ROI:** 1,100% (12x la inversión)
''',
      'caso': '''
📱 **CASO DE ÉXITO - DE 0 A 20 VENTAS EN 6 MESES**

**Situación:** Asesor recién independizado, sin base de clientes, presupuesto \$20,000/mes.

**Estrategia implementada:**

**Mes 1-2: Construcción de base**
• Inmuebles24: 5 propiedades (\$3,000/mes)
• Facebook Ads: \$10,000/mes (segmentación 10km a la redonda)
• Instagram: 1 post diario + stories
• Google My Business optimizado

**Mes 3-4: Optimización**
• Ajuste de segmentación en Facebook Ads
• Aumento de presupuesto a \$15,000/mes
• Inicio de TikTok (3 videos/semana)
• Email marketing a base de 200 contactos

**Mes 5-6: Escalamiento**
• Presupuesto Facebook: \$20,000/mes
• Sitio web propio lanzado
• Campaña de Google Ads: \$5,000/mes
• Referidos de clientes satisfechos

**Resultados:**
• Mes 1: 15 leads, 1 venta
• Mes 2: 25 leads, 1 venta
• Mes 3: 40 leads, 2 ventas
• Mes 4: 55 leads, 3 ventas
• Mes 5: 70 leads, 4 ventas
• Mes 6: 85 leads, 5 ventas

**Total 6 meses:** 290 leads, 16 ventas, \$4.8M en comisiones
**Inversión total:** \$120,000
**ROI:** 3,900% (40x la inversión)

**Lección:** El marketing digital funciona si eres constante, mides resultados y ajustas la estrategia. Los primeros 2 meses son de inversión, los siguientes de retorno.
''',
    },
    'cierre': {
      'titulo': 'Técnicas Profesionales de Cierre',
      'contenido': '''
🎯 **TÉCNICAS PROFESIONALES DE CIERRE DE VENTAS**

**A) SEÑALES DE QUE EL CLIENTE ESTÁ LISTO PARA CERRAR:**

**Señales verbales:**
✅ "¿Cuánto tiempo toma el proceso?"
✅ "¿Qué documentos necesito?"
✅ "¿Puedo ver la propiedad otra vez?"
✅ "¿El precio es negociable?"
✅ "¿Qué incluye el precio?"
✅ "¿Cuándo estaría disponible?"
✅ "¿Hay otras ofertas?"

**Señales no verbales:**
✅ Trae a familiares o amigos
✅ Pasa mucho tiempo en una propiedad
✅ Hace preguntas específicas sobre acabados
✅ Imagina sus muebles en los espacios
✅ Pide medir espacios
✅ Revisa tomas de agua, luz, gas

**B) TÉCNICAS DE CIERRE:**

**1. CIERRE DIRECTO:**
"¿Le gustaría hacer la oferta hoy?"
"¿Procedemos con la compra?"
"¿Firmamos el contrato?"

**Cuándo usarlo:** Cliente muy interesado, sin objeciones.

**2. CIERRE DE OPCIONES:**
"¿Prefiere entregar el próximo mes o en 60 días?"
"¿Le gustaría con todos los muebles o sin ellos?"
"¿Pago de contado o con crédito?"

**Cuándo usarlo:** Cliente indeciso entre dos opciones.

**3. CIERRE POR URGENCIA:**
"Tengo otra visita mañana con oferta en mano"
"El propietario viajará la próxima semana"
"Esta propiedad no durará mucho en el mercado"

**Cuándo usarlo:** Propiedad con alta demanda, cliente interesado pero indeciso.

**4. CIERRE POR BENEFICIO:**
"Si cerramos hoy, puedo negociar que el vendedor deje todos los muebles"
"Si hacemos la oferta esta semana, el propietario acepta \$100,000 menos"
"Si firma hoy, le incluyo el avalúo sin costo"

**Cuándo usarlo:** Cliente sensible al precio o beneficios adicionales.

**5. CIERRE POR RESUMEN:**
"Entonces tenemos: casa de 3 recámaras, jardín, excelente ubicación, dentro de su presupuesto, con financiamiento pre-aprobado. ¿Procedemos?"

**Cuándo usarlo:** Cliente que necesita recordar todos los beneficios.

**6. CIERRE POR PREGUNTA:**
"¿Qué le impide tomar la decisión hoy?"
"¿Qué necesitamos resolver para avanzar?"
"¿Hay algo más que necesite saber?"

**Cuándo usarlo:** Cliente con objeción oculta.

**7. CIERRE SILENCIOSO:**
Después de presentar la oferta, **calla**. El primero que hable, pierde.

**Cuándo usarlo:** Después de hacer la propuesta final.

**8. CIERRE POR ASUNCIÓN:**
"Perfecto, entonces agendamos la firma para el viernes. ¿Le parece bien a las 10am o a las 12pm?"

**Cuándo usarlo:** Cliente ya decidió, solo necesita que lo guíes.

**9. CIERRE POR TESTIMONIO:**
"El Sr. García compró una propiedad similar hace 2 meses y hoy vale 15% más. ¿Le gustaría tener el mismo resultado?"

**Cuándo usarlo:** Cliente necesita validación social.

**10. CIERRE POR GARANTÍA:**
"Si en 30 días no está satisfecho, le ayudo a revenderla sin costo adicional"

**Cuándo usarlo:** Cliente con miedo a tomar la decisión equivocada.

**C) MANEJO DE OBJECIONES EN EL CIERRE:**

**"Necesito pensarlo":**
"Entiendo. ¿Qué específicamente necesita pensar? ¿Es el precio, la ubicación, o algo más?"

**"Tengo que consultarlo":**
"Por supuesto. ¿Qué le parece si agendamos una llamada con [persona] para resolver todas sus dudas juntos?"

**"Es mucho dinero":**
"Entiendo. Pero considere esto: en 5 años esta propiedad valdrá 40% más. ¿Es mucho dinero o es una inversión inteligente?"

**"Hay otras opciones":**
"Excelente. Compare y verá que esta propiedad ofrece el mejor valor. ¿Qué tiene las otras que esta no?"

**"No estoy seguro":**
"¿Qué le genera inseguridad? Estoy aquí para resolver todas sus dudas."

**D) ERRORES AL CERRAR:**

❌ **Presionar demasiado:** El cliente se siente acorralado y huye
❌ **No escuchar objeciones reales:** No resuelves el problema real
❌ **No tener documentos listos:** Pierdes momentum
❌ **No hacer seguimiento post-visita:** El cliente se enfría
❌ **Hablar de más:** Después de hacer la propuesta, calla
❌ **Mostrar desesperación:** El cliente huele la necesidad y negocia más duro
❌ **No tener plan B:** Si no cierras hoy, ¿cuál es el siguiente paso?

**E) SEGUIMIENTO POST-VISITA:**

**24 horas después:**
• Mensaje de agradecimiento
• Preguntar qué le pareció la propiedad
• Ofrecer resolver dudas

**48 horas después:**
• Llamar para conocer decisión
• Si está interesado: agendar segunda visita o presentar oferta
• Si no está interesado: preguntar por qué y ofrecer alternativas

**7 días después:**
• Enviar propiedades similares
• Mantener contacto sin presionar

**14 días después:**
• Llamar para conocer si avanzó con otras propiedades
• Ofrecer ayuda si necesita algo

**30 días después:**
• Email con nuevas propiedades
• Mantener en base de datos para futuras oportunidades

**F) PSICOLOGÍA DEL CIERRE:**

**Principio de escasez:**
"Esta propiedad es única en la zona. No hay otra igual."

**Principio de autoridad:**
"Como asesor certificado con 10 años de experiencia, le recomiendo..."

**Principio de reciprocidad:**
"Le conseguí un precio especial. ¿Qué le parece si avanzamos?"

**Principio de consistencia:**
"Me dijo que esta propiedad cumplía todo lo que buscaba. ¿Qué cambió?"

**Principio de prueba social:**
"3 familias han hecho oferta esta semana. Es muy buscada."

**Principio de afinidad:**
"Entiendo perfectamente su situación. Yo también busqué casa hace 5 años."
''',
      'caso': '''
🎯 **CASO DE ÉXITO - CIERRE EN 2 HORAS CON CIERRE SILENCIOSO**

**Situación:** Pareja joven vio casa de \$4.2M. Tercera visita. Encantados pero "lo iban a pensar".

**Lo que hizo el asesor:**
1. **Resumió beneficios:** "Entonces: 3 recámaras para sus hijos, jardín para el perro, cerca del colegio, dentro de su presupuesto con crédito pre-aprobado"
2. **Hizo la propuesta:** "¿Qué les parece si hacemos una oferta de \$4.05M hoy? El propietario está motivado"
3. **Silencio total:** 45 segundos de silencio incómodo
4. **La esposa rompió el silencio:** "¿Cree que acepte \$4M?"
5. **Asesor:** "Déjeme llamarlo ahora mismo"
6. **Llamó al propietario en frente de ellos:** "Tengo una oferta de \$4M, ¿la considera?"
7. **Propietario:** "Diles que \$4.05M y es suya"
8. **Asesor a la pareja:** "¿Les parece?"
9. **Esposa al esposo:** "¿Qué dices?"
10. **Esposo:** "Trato hecho"

**Resultado:**
• Oferta de \$4.05M aceptada
• Apartado con \$100,000 ese mismo día
• Escrituración en 30 días
• Comisión: \$243,000

**Lección:** El silencio es tu mejor aliado en el cierre. Después de hacer la propuesta, CALLA. El cliente llenará el silencio con su decisión.
''',
    },
    'procedimientos': {
      'titulo': 'Procedimientos Operativos Estándar',
      'contenido': '''
📋 **PROCEDIMIENTOS OPERATIVOS ESTÁNDAR (POE)**

**A) PROCESO DE COMPRAVENTA COMPLETO:**

**FASE 1: CAPTACIÓN (Días 1-7)**
☐ Visita inicial al inmueble
☐ Análisis de documentación
☐ AMV (Análisis de Mercado de Valores)
 Fotografía profesional y tour virtual
☐ Firma de contrato de exclusividad
☐ Publicación en portales y redes

**FASE 2: PROMOCIÓN (Días 7-30)**
☐ Campaña de marketing digital
☐ Filtrado de prospectos
☐ Visitas guiadas (máximo 3 por día)
☐ Seguimiento post-visita (24-48 horas)
☐ Reportes semanales al propietario

**FASE 3: NEGOCIACIÓN (Días 30-60)**
☐ Recepción de ofertas
 Presentación al propietario
☐ Negociación de términos
☐ Aceptación de oferta
 Apartado con anticipo (5-10%)

**FASE 4: CIERRE LEGAL (Días 60-90)**
☐ Verificación documental completa
☐ Trámite de crédito (si aplica)
☐ Avalúo bancario
☐ Firma de contrato de compra-venta
 Pago de impuestos (ISAI)
☐ Firma ante notario
☐ Registro en RPP
 Entrega de llaves

**FASE 5: POST-VENTA (Días 90-120)**
☐ Seguimiento de satisfacción
 Solicitud de referidos
☐ Actualización de base de datos
☐ Celebración con cliente

**B) PROCESO DE ARRENDAMIENTO:**

**FASE 1: CAPTACIÓN (Días 1-5)**
☐ Visita al inmueble
 Verificación de documentación
☐ Definición de renta y condiciones
☐ Firma de contrato de exclusividad
☐ Fotografía y publicación

**FASE 2: FILTRADO DE INQUILINOS (Días 5-20)**
☐ Recepción de solicitudes
☐ Verificación de ingresos (3x la renta)
☐ Consulta de buró de crédito
☐ Verificación de referencias
☐ Visita guiada

**FASE 3: CIERRE (Días 20-30)**
☐ Selección de inquilino
☐ Firma de contrato de arrendamiento
 Cobro de depósito y primera renta
☐ Entrega de inmueble (inventario firmado)

**FASE 4: ADMINISTRACIÓN (Mensual)**
☐ Cobro de renta
☐ Atención de reparaciones
☐ Reportes al propietario
☐ Renovación de contrato (anual)

**C) CHECKLIST DE DOCUMENTOS POR OPERACIÓN:**

**COMPRAVENTA:**
☐ Identificaciones de ambas partes
☐ Escritura de propiedad
☐ Certificado de libertad de gravamen
☐ Predial y agua pagados
☐ Avalúo
 Contrato de compra-venta
☐ Factura de comisión
☐ Aviso UIF (si aplica)
 Póliza de seguro (si hay crédito)

**ARRENDAMIENTO:**
☐ Identificaciones de ambas partes
☐ Escritura de propiedad
 Contrato de arrendamiento
☐ Inventario del inmueble
☐ Comprobante de ingresos del inquilino
☐ Depósito en garantía
☐ Póliza jurídica (opcional)

**D) TIMELINE ESTÁNDAR:**

**Compra de contado:**
• Día 1: Oferta aceptada
• Día 2-5: Verificación documental
• Día 5-10: Pago de impuestos
• Día 10-15: Firma ante notario
• Día 15-20: Registro en RPP
• Día 20: Entrega de llaves

**Compra con crédito:**
• Día 1: Oferta aceptada
• Día 2-5: Verificación documental
• Día 5-10: Solicitud de crédito
• Día 10-25: Aprobación de crédito
• Día 25-30: Avalúo bancario
• Día 30-35: Pago de impuestos
• Día 35-40: Firma ante notario
• Día 40-45: Registro en RPP
• Día 45: Entrega de llaves

**Arrendamiento:**
• Día 1: Solicitud de inquilino
• Día 2-5: Verificación de ingresos y referencias
• Día 5-7: Aprobación
• Día 7-10: Firma de contrato
• Día 10: Entrega de inmueble

**E) PROTOCOLO DE ATENCIÓN AL CLIENTE:**

**Primera llamada (menos de 3 rings):**
"Hola, soy [nombre] de [inmobiliaria]. ¿En qué puedo ayudarte?"

**Primera visita:**
• Puntualidad (5 min antes)
• Presentación profesional
• Recorrido guiado (no dejar que el cliente explore solo)
• Responder todas las preguntas
• Entregar ficha técnica impresa
• Despedida cordial

**Seguimiento post-visita:**
• 24 horas: Mensaje de agradecimiento
• 48 horas: Llamada para conocer decisión
• 7 días: Envío de propiedades similares
• 14 días: Llamada de seguimiento
• 30 días: Email con nuevas opciones

**Quejas y reclamaciones:**
• Escuchar sin interrumpir
• Validar la emoción del cliente
• Ofrecer solución concreta
• Dar plazo de resolución
• Dar seguimiento hasta resolver
• Documentar todo por escrito
''',
      'caso': '''
📋 **CASO DE ÉXITO - PROCESO PERFECTO DE 45 DÍAS**

**Situación:** Venta de departamento de \$5.5M con crédito bancario.

**Timeline ejecutado:**
• Día 1: Captación con exclusividad
• Día 3: Publicación en 5 portales
• Día 7: 15 visitas agendadas
• Día 12: Oferta de \$5.3M aceptada
• Día 15: Apartado con \$530,000 (10%)
• Día 16-20: Verificación documental completa
• Día 21: Solicitud de crédito presentada
• Día 35: Crédito aprobado
• Día 38: Avalúo bancario (\$5.4M)
• Día 40: Pago de ISAI (\$275,000)
• Día 43: Firma ante notario
• Día 45: Registro en RPP y entrega de llaves

**Resultado:**
• Venta exitosa en 45 días (promedio es 90)
• Cliente satisfecho (3 referidos posteriores)
• Comisión: \$330,000
• Propietario feliz (vendió en 43 días)

**Lección:** Un proceso bien ejecutado reduce el tiempo de venta en 50% y aumenta la satisfacción del cliente.
''',
    },
  };

  // ============================================================
  // CONTENIDO COMPLETO PARA LA ACADEMIA
  // ============================================================
  static final List<Map<String, dynamic>> temasAcademia = [
    {
      'id': 'requisitos',
      'titulo': '🎯 Requisitos Básicos para Ser Asesor Inmobiliario',
      'nivel': 'Principiante',
      'duracion': '30 min',
      'icono': '🎓',
      'color': '0xFF10B981',
      'contenido': '''
# REQUISITOS BÁSICOS PARA SER ASESOR INMOBILIARIO EN MÉXICO

## 1. REQUISITOS LEGALES

### 1.1 Requisitos Generales
• Ser mayor de 18 años
• Identificación oficial vigente (INE/Pasaporte)
• CURP actualizada
• Comprobante de domicilio (no mayor a 3 meses)
• RFC activo (para facturar comisiones)
• Cuenta bancaria a tu nombre

### 1.2 Alta ante el SAT
**Opciones de régimen fiscal:**
• **Régimen Simplificado de Confianza (RESICO):** Tasas de ISR del 1-2.5% sobre ingresos. Ideal para iniciar.
• **Actividad Empresarial:** Tasas progresivas del 1.92% al 35%. Para ingresos altos.
• **Plataformas Tecnológicas:** Si operas mediante plataformas digitales.

**Pasos para darte de alta:**
1. Ingresa a www.sat.gob.mx
2. Tramita tu RFC (si no lo tienes)
3. Date de alta en el régimen elegido
4. Obtén tu e.firma (firma electrónica)
5. Configura tu buzón tributario

### 1.3 Registro Estatal (según tu estado)

**Ciudad de México:**
• Registro ante PROSOC (Procuraduría Social)
• Constancia de no antecedentes penales
• Certificación EC0110.02 (recomendada)

**Jalisco:**
• Registro ante la Dirección de Profesiones
• Cédula profesional (si tienes carrera afín)
• Certificación CONOCER

**Nuevo León:**
• Registro ante la Secretaría de Economía
• Certificación AMPI (recomendada)

**Quintana Roo:**
• Registro ante SEDETUS
• Constancia de no antecedentes penales
• Certificación EC0110.02 (obligatoria en algunos municipios)

### 1.4 Certificaciones Recomendadas

**EC0110.02 - Asesoría en Comercialización de Bienes Inmuebles:**
• Otorgada por CONOCER-SEP
• Válida en todo México
• Reconocida por AMPI
• Costo: \$3,000-\$5,000
• Vigencia: 3 años (requiere recertificación)

**Profesional Inmobiliario Certificado (PIC):**
• Otorgada por AMPI
• Reconocimiento profesional
• Requiere membresía AMPI activa
• Educación continua anual

## 2. FORMACIÓN RECOMENDADA

### 2.1 Cursos Básicos
• Introducción al mercado inmobiliario mexicano
• Tipos de inmuebles y sus características
• Proceso completo de compra-venta
• Proceso completo de arrendamiento
• Documentación básica
• Ética profesional

### 2.2 Cursos Intermedios
• Derecho inmobiliario
• Aspectos fiscales
• Financiamiento hipotecario
• Valuación básica
• Marketing digital inmobiliario
• Ley Antilavado

### 2.3 Cursos Avanzados
• Fideicomisos en zona restringida
• Desarrollo inmobiliario
• Administración de inmuebles
• Análisis de inversión
• PropTech y herramientas digitales

## 3. HERRAMIENTAS ESENCIALES

### 3.1 Herramientas Físicas
• Cinta métrica láser
• Brújula o app de orientación
• Cámara fotográfica o smartphone de buena calidad
• Tablet para presentaciones
• Carpeta profesional con documentos
• Tarjetas de presentación

### 3.2 Herramientas Digitales
• CRM inmobiliario (recomendado)
• Apps de fotografía y edición
• Apps de firma digital
• Apps de navegación y mapas
• Apps de cálculo hipotecario
• Apps de gestión de documentos

## 4. PRIMEROS PASOS PRÁCTICOS

### 4.1 Decide tu modelo de negocio
• **Independiente:** Mayor libertad, mayor responsabilidad
• **Inmobiliaria establecida:** Estructura, capacitación, leads
• **Franquicia:** Marca reconocida, procesos establecidos
• **Plataforma digital:** iad, Housfy, etc.

### 4.2 Define tu zona de trabajo
• Investiga el mercado local
• Conoce precios por m²
• Identifica zonas de plusvalía
• Establece tu área de especialización

### 4.3 Construye tu red de contactos
• Notarios públicos
• Abogados inmobiliarios
• Valuadores certificados
• Agentes de seguros
• Brókers hipotecarios
• Otros asesores (para referencias cruzadas)

### 4.4 Establece tus procesos
• Protocolo de atención al cliente
• Sistema de seguimiento
• Gestión de documentos
• Protocolo de cierre
• Post-venta y referidos

## 5. INVERSIÓN INICIAL ESTIMADA

| Concepto | Costo |
|----------|-------|
| Certificación EC0110.02 | \$3,000-\$5,000 |
| Membresía AMPI (anual) | \$3,000-\$5,000 |
| Herramientas físicas | \$5,000-\$10,000 |
| Marketing inicial | \$10,000-\$20,000 |
| Sitio web | \$15,000-\$30,000 |
| Capital de trabajo (3 meses) | \$30,000-\$50,000 |
| **TOTAL** | **\$66,000-\$120,000** |

## 6. EXPECTATIVAS REALISTAS

**Primeros 6 meses:**
• 1-2 ventas promedio
• Ingresos: \$100,000-\$300,000
• Enfoque: Construir base de clientes

**6-12 meses:**
• 2-4 ventas
• Ingresos: \$300,000-\$600,000
• Enfoque: Consolidar procesos

**1-2 años:**
• 4-8 ventas anuales
• Ingresos: \$600,000-\$1,500,000
• Enfoque: Especialización

**2+ años:**
• 8-15 ventas anuales
• Ingresos: \$1,500,000-\$3,000,000+
• Enfoque: Escalamiento y equipo

**Recuerda:** El éxito en bienes raíces requiere paciencia, persistencia y profesionalismo. Los primeros meses son de inversión en conocimiento y relaciones.
''',
    },
    {
      'id': 'marco_legal',
      'titulo': '⚖️ Marco Legal Inmobiliario Completo',
      'nivel': 'Intermedio',
      'duracion': '2 horas',
      'icono': '⚖️',
      'color': '0xFF3B82F6',
      'contenido': '''
# MARCO LEGAL INMOBILIARIO EN MÉXICO

## 1. LEYES FEDERALES APLICABLES

### 1.1 Código Civil Federal
**Artículos clave:**
• Art. 766-780: De la propiedad
• Art. 2248-2267: De la compra-venta
• Art. 2398-2418: Del arrendamiento
• Art. 2676-2691: De la hipoteca

**Conceptos fundamentales:**
• **Propiedad:** Derecho de usar, disfrutar y disponer de un bien
• **Posesión:** Tenencia de un bien como propio
• **Usufructo:** Derecho de usar y disfrutar bien ajeno
• **Servidumbre:** Gravamen sobre un inmueble en beneficio de otro

### 1.2 Ley de Vivienda
**Objetivos:**
• Regular el derecho a la vivienda digna
• Establecer programas de vivienda social
• Regular subsidios y créditos de vivienda

**Programas relevantes:**
• Mi Casa Ya
• Crédito Infonavit
• Crédito Fovissste
• Fondo de garantía

### 1.3 Ley Federal de Protección de Datos Personales
**Obligaciones del asesor:**
• Aviso de privacidad obligatorio
• Consentimiento expreso del cliente
• Uso limitado de datos personales
• Seguridad de la información
• Derechos ARCO (Acceso, Rectificación, Cancelación, Oposición)

**Sanciones:**
• Multas de 100 a 320,000 UMAs
• Prisión de 3 meses a 5 años (datos sensibles)

### 1.4 Ley Antilavado (LFPIORPI)
**Ver tema específico en el chatbot**

### 1.5 Ley de Inversión Extranjera
**Zona restringida:**
• 50 km de fronteras
• 100 km de costas
• Extranjeros requieren fideicomiso (FIBRA)
• Duración: 50 años (renovable)

## 2. LEYES ESTATALES Y MUNICIPALES

### 2.1 Códigos Civiles Estatales
Cada estado tiene su propio código civil con variaciones en:
• Formalidades de la compra-venta
• Requisitos de escritura
• Impuestos locales (ISAI)
• Regulación de arrendamiento

### 2.2 Leyes de Desarrollo Urbano
• Uso de suelo
• Zonificación
• Coeficientes de ocupación y utilización
• Estacionamientos requeridos
• Áreas verdes

### 2.3 Leyes de Protección al Consumidor
• NOM-247-SE-2021
• Información veraz y suficiente
• Prohibición de prácticas abusivas
• Derecho de retracto (en algunos casos)

## 3. NORMATIVIDAD ESPECÍFICA

### 3.1 NOM-247-SE-2021
**Información obligatoria en publicidad:**
• Precio total
• Superficie total y útil
• Número de habitaciones y baños
• Estacionamientos
• Año de construcción
• Estado de la propiedad

**Sanciones:**
• Multas de 50 a 5,000 UMAs
• Clausura temporal o definitiva

### 3.2 Regulación Notarial
**Funciones del notario:**
• Dar fe pública de los actos
• Verificar legalidad de la operación
• Calcular y retener impuestos
• Inscribir en el Registro Público

**Honorarios notariales:**
• Tabulador oficial por estado
• Generalmente 1-2% del valor de la operación
• Más IVA

### 3.3 Registro Público de la Propiedad
**Funciones:**
• Inscribir actos y contratos
• Dar publicidad a los derechos reales
• Proteger al adquirente de buena fe

**Trámites:**
• Inscripción de compra-venta
• Inscripción de hipoteca
• Cancelación de gravámenes
• Certificados y constancias

## 4. CONTRATOS INMOBILIARIOS

### 4.1 Contrato de Compra-Venta
**Elementos esenciales:**
• Identificación de las partes
• Descripción del inmueble
• Precio y forma de pago
• Fecha de entrega
• Cláusulas especiales
• Firmas de las partes

**Cláusulas recomendadas:**
• Cláusula penal (incumplimiento)
• Cláusula de no competencia
• Cláusula de confidencialidad
• Cláusula de jurisdicción

### 4.2 Contrato de Arrendamiento
**Elementos esenciales:**
• Identificación de las partes
• Descripción del inmueble
• Renta y forma de pago
• Duración del contrato
• Depósito en garantía
• Uso del inmueble

**Duración:**
• Mínimo: 1 año (recomendado)
• Máximo: 10 años (residencial)
• Comercial: hasta 20 años

### 4.3 Contrato de Exclusividad
**Elementos esenciales:**
• Identificación de las partes
• Descripción del inmueble
• Precio de venta/renta
• Duración de la exclusividad
• Comisión del asesor
• Obligaciones de las partes

**Duración recomendada:**
• Venta: 3-6 meses
• Renta: 1-3 meses

### 4.4 Contrato de Intermediación
**Cuando NO hay exclusividad:**
• Múltiples asesores pueden comercializar
• Comisión solo al que concrete la venta
• Menor compromiso del propietario
• Mayor competencia entre asesores

## 5. IMPUESTOS INMOBILIARIOS

### 5.1 Impuesto Sobre Adquisición de Inmuebles (ISAI)
• Varía por estado y municipio
• Generalmente 2-5% del valor de la operación
• Lo paga el comprador
• Se paga antes de la escrituración

### 5.2 Impuesto Sobre la Renta (ISR)
**Por enajenación de inmuebles:**
• Tasa: 20% sobre la ganancia
• Exención: Casa habitación (una vez cada 5 años, hasta \$750,000 UDIS)
• Deducciones: Costo de adquisición, mejoras, gastos notariales

**Por arrendamiento:**
• Tasa: 10% (RESICO) o progresiva (Actividad Empresarial)
• Deducciones: Depreciación, mantenimiento, intereses

### 5.3 Impuesto al Valor Agregado (IVA)
• Tasa: 16%
• Aplica en:
  - Arrendamiento de locales comerciales
  - Construcción de inmuebles nuevos
  - No aplica en venta de casa habitación usada

### 5.4 Impuesto Predial
• Pago anual obligatorio
• Varía por municipio
• Descuentos por pronto pago
• Recargos por pago extemporáneo

## 6. PROCESOS LEGALES ESPECIALES

### 6.1 Sucesiones
**Tipos:**
• Testamentaria (con testamento)
• Intestada (sin testamento)
• Judicial (con conflicto)

**Proceso:**
1. Declaratoria de herederos
2. Inventariado de bienes
3. Avalúo de bienes
4. Adjudicación
5. Inscripción en RPP

**Tiempo promedio:** 6-18 meses
**Costo:** 3-8% del valor de los bienes

### 6.2 Divorcio y Liquidación de Sociedad Conyugal
**Opciones:**
• Venta del inmueble y división del producto
• Adjudicación a uno de los cónyuges (con compensación)
• Copropiedad (no recomendado)

**Requisitos:**
• Convenio de liquidación
• Avalúo de bienes
• Firma ante notario
• Inscripción en RPP

### 6.3 Remates Judiciales
**Tipos:**
• Remate voluntario (deudor acepta)
• Remate forzoso (orden judicial)

**Consideraciones:**
• Precio generalmente 20-40% abajo del mercado
• Riesgos legales (cargas, ocupantes)
• Proceso largo (6-18 meses)
• Requiere asesoría legal especializada

### 6.4 Fideicomisos
**Tipos:**
• Fideicomiso de administración
• Fideicomiso de garantía
• Fideicomiso inmobiliario (FIBRA)
• Fideicomiso en zona restringida (extranjeros)

**Partes:**
• Fideicomitente (aporta el bien)
• Fiduciario (institución financiera)
• Fideicomisario (beneficiario)

**Duración:**
• Máximo 50 años (renovable)
• Zona restringida: 50 años

## 7. RESOLUCIÓN DE CONFLICTOS

### 7.1 Medios de Resolución
• **Negociación directa:** Entre las partes
• **Mediación:** Con mediador neutral
• **Arbitraje:** Con árbitro (laudo vinculante)
• **Juicio:** Ante tribunales

### 7.2 PROFECO (Procuraduría Federal del Consumidor)
• Protege al consumidor
• Mediación en conflictos
• Sanciones a proveedores
• Gratuita para el consumidor

### 7.3 CONDUSEF (Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros)
• Conflictos con bancos e instituciones financieras
• Créditos hipotecarios
• Seguros
• Gratuita para el usuario

## 8. ACTUALIZACIONES 2026

### 8.1 Reformas Recientes
• Aumento de umbral en Ley Antilavado
• Nuevas tasas de ISAI en algunos estados
• Reformas a la Ley de Vivienda
• Actualización de NOM-247-SE

### 8.2 Tendencias Legales
• Mayor regulación de plataformas digitales
• Protección de datos personales más estricta
• Sustentabilidad en construcción (NOM)
• Smart contracts y blockchain (en desarrollo)

### 8.3 Próximos Cambios
• Reforma fiscal 2027 (en discusión)
• Actualización de UMAs
• Nuevas regulaciones de PropTech
• Regulación de criptomonedas en inmuebles
''',
    },
    {
      'id': 'captacion',
      'titulo': '🏠 Captación Profesional de Inmuebles',
      'nivel': 'Intermedio',
      'duracion': '1.5 horas',
      'icono': '',
      'color': '0xFF10B981',
      'contenido': '''
# CAPTACIÓN PROFESIONAL DE INMUEBLES

## 1. PREPARACIÓN ANTES DE LA CAPTACIÓN

### 1.1 Investigación de Mercado
• Precios por m² en la zona (últimos 6 meses)
• Plusvalía histórica (5 años)
• Demanda actual (oferta vs. demanda)
• Tiempo promedio de venta en la zona
• Propiedades competidoras activas

### 1.2 Preparación de Materiales
• Tarjetas de presentación profesionales
• Carpeta con credenciales (AMPI, CONOCER)
• Tablet con presentaciones y AMVs
• Formatos de contrato de exclusividad
• Cámara fotográfica o smartphone de alta calidad
• Cinta métrica láser

### 1.3 AMV Pre-elaborado
Prepara un Análisis de Mercado de Valores preliminar con:
• 3-5 comparables de la zona
• Precio promedio por m²
• Tiempo promedio de venta
• Tendencias del mercado local

## 2. PRIMERA VISITA AL PROPIETARIO

### 2.1 Protocolo de Llegada
• Llegar 5 minutos antes
• Vestimenta formal (traje o camisa de manga larga)
• Saludo cordial y presentación de credenciales
• Agradecer el tiempo del propietario

### 2.2 Escucha Activa
• Deja que el propietario hable primero
• Identifica su motivación real (¿por qué vende?)
• Detecta urgencia (escala 1-10)
• Identifica expectativas de precio

### 2.3 Preguntas Clave
• ¿Por qué decide vender/rentar?
• ¿En qué tiempo necesita concretar?
• ¿Ha recibido ofertas anteriores?
• ¿Qué le gusta más de la propiedad?
• ¿Qué le gustaría mejorar?

## 3. ANÁLISIS TÉCNICO DEL INMUEBLE

### 3.1 Medidas y Características
• Medidas reales de todos los espacios
• Número de habitaciones, baños, estacionamientos
• Estado de conservación (estructura, instalaciones, acabados)
• Orientación (norte, sur, este, oeste)
• Iluminación natural
• Ventilación

### 3.2 Documentación Disponible
• Escrituras
• Predial pagado
• Agua pagada
• Certificado de libertad de gravamen
• Uso de suelo
• Licencia de construcción (si aplica)

### 3.3 Identificación de Plusvalías y Minusvalías

**Plusvalías (+):**
• Ubicación en zona de alta plusvalía
• Acabados de calidad
• Amenidades (alberca, jardín, seguridad)
• Cerca de servicios (escuelas, hospitales, centros comerciales)
• Buen estado de conservación

**Minusvalías (-):**
• Necesita remodelación
• Zona de riesgo
• Problemas legales
• Mal estado de conservación
• Mala orientación

### 3.4 Fotografía Profesional
• Mínimo 20 fotos de alta calidad
• Fotos de todos los espacios
• Fotos de exteriores y fachada
• Fotos de amenidades
• Video tour (opcional pero recomendado)
• Tour virtual 360° (ideal)

## 4. PRESENTACIÓN DEL AMV

### 4.1 Estructura de la Presentación
1. Introducción y agradecimiento
2. Análisis del mercado local
3. Presentación de comparables
4. Precio recomendado y justificación
5. Plan de marketing propuesto
6. Cierre y firma de exclusividad

### 4.2 Presentación de Comparables
Muestra 3-5 propiedades similares vendidas:
• Dirección (general, no específica)
• Precio de venta
• Tiempo en el mercado
• Características similares
• Ajustes por diferencias

### 4.3 Justificación del Precio
• Método comparativo de mercado
• Ajustes por ubicación, tamaño, antigüedad, acabados
• Precio de lista vs. precio de venta
• Tiempo estimado de venta

## 5. CIERRE DE LA EXCLUSIVA

### 5.1 Beneficios de la Exclusividad
• Mayor compromiso del asesor
• Marketing más agresivo
• Mejor precio de venta
• Menor tiempo en el mercado
• Un solo punto de contacto

### 5.2 Presentación del Contrato
• Duración: 3-6 meses (venta), 1-3 meses (renta)
• Comisión: 6% (venta), 1 mes de renta (arrendamiento)
• Obligaciones del asesor
• Obligaciones del propietario
• Cláusulas de terminación

### 5.3 Manejo de Objeciones Comunes

**"Prefiero abierta":**
"Entiendo. La exclusiva me permite invertir más en marketing porque tengo la seguridad de que mi esfuerzo será recompensado. Con abierta, ningún agente invierte realmente porque puede que otro cierre la venta."

**"La comisión es muy alta":**
"Mi comisión incluye marketing profesional (\$25,000), filtrado de clientes (40+ horas), asesoría legal y fiscal, y seguimiento hasta escrituración. Si vendes solo, ahorras el 6% pero asumes todos los riesgos y generalmente vendes más barato."

**"Necesito pensarlo":**
"Claro, es una decisión importante. ¿Qué específicamente necesitas pensar? ¿Es la comisión, la duración, o algo más?"

## 6. POST-CAPTACIÓN (Primeras 48 horas)

### 6.1 Contenido Profesional
• Fotografía profesional (mínimo 20 fotos)
• Video tour (2-3 minutos)
• Tour virtual 360°
• Ficha técnica detallada
• Descripción atractiva (mínimo 300 palabras)

### 6.2 Publicación Multicanal
• 5+ portales inmobiliarios
• Facebook Ads segmentados
• Instagram (posts y stories)
• TikTok (video corto)
• Email a base de datos
• WhatsApp a clientes calificados

### 6.3 Letrero Físico
• Colocación en el inmueble
• Información de contacto clara
• Código QR a la ficha online
• Mantenimiento semanal

## 7. SEGUIMIENTO AL PROPIETARIO

### 7.1 Reportes Semanales
• Número de visitas realizadas
• Perfil de los visitantes
• Feedback de las visitas
• Ajustes recomendados (precio, marketing)

### 7.2 Comunicación Constante
• WhatsApp semanal con resumen
• Llamada quincenal para revisar estrategia
• Reunión mensual para ajustar plan

### 7.3 Ajustes de Estrategia
Si no hay visitas en 2 semanas:
• Revisar precio
• Mejorar fotografías
• Ajustar descripción
• Cambiar estrategia de marketing
• Ampliar canales de difusión

## 8. MÉTRICAS DE ÉXITO

**Indicadores clave:**
• Tiempo de captación a primera visita: < 7 días
• Visitas por semana: 3-5
• Ofertas recibidas: 1-2 por mes
• Tiempo promedio de venta: 60-90 días
• Precio de venta vs. precio de lista: 95-98%

**Señales de éxito:**
• Propietario satisfecho con el servicio
• Visitas calificadas constantes
• Ofertas serias recibidas
• Venta cerrada en tiempo razonable
• Cliente refiere a otros propietarios
''',
    },
    {
      'id': 'documentos',
      'titulo': '📄 Documentación Legal Completa',
      'nivel': 'Intermedio',
      'duracion': '1.5 horas',
      'icono': '📄',
      'color': '0xFF3B82F6',
      'contenido': '''
# DOCUMENTACIÓN ESENCIAL PARA OPERACIONES INMOBILIARIAS

## A) PARA COMPRAVENTA DE INMUEBLES

### Del Vendedor:

1. **Escritura pública de propiedad** (original y copia)
   - Debe estar inscrita en el Registro Público de la Propiedad
   - Verificar que no tenga anotaciones marginales

2. **Identificación oficial vigente** (INE/Pasaporte)
   - Vigencia mínima de 6 meses
   - Copia por ambos lados

3. **CURP actualizada**
   - Consultar en www.gob.mx/curp
   - Debe coincidir con la escritura

4. **Comprobante de domicilio** (no mayor a 3 meses)
   - Recibo de luz, agua, teléfono o estado de cuenta bancario

5. **Estado de cuenta predial** (últimos 5 años pagados)
   - Sin adeudos
   - Si hay adeudo, debe liquidarse antes de la venta

6. **Estado de cuenta de agua** (últimos 5 años pagados)
   - Sin adeudos
   - Certificado de no adeudo

7. **Certificado de Libertad de Gravamen** (vigencia 30 días)
   - Emitido por el Registro Público de la Propiedad
   - **CRÍTICO:** Solicitar 48 horas antes de la firma

8. **Constancia de Situación Fiscal** (RFC activo)
   - Descargable del portal del SAT
   - Vigencia: 3 meses

9. **Acreditación de origen de recursos** (Ley Antilavado)
   - Declaración bajo protesta de decir verdad
   - Documentos que respalden el origen

10. **Acta de matrimonio** (si es casado bajo sociedad conyugal)
    - Necesaria para el consentimiento del cónyuge

11. **Consentimiento del cónyuge** (si aplica)
    - Firma ante notario o testigos

12. **Juicio sucesorio o escritura de adjudicación** (si es herencia)
    - Debe estar inscrito en el RPP

13. **Poder notarial** (si actúa representante legal)
    - Vigente y con facultades suficientes

### Del Comprador:

1. **Identificación oficial vigente**
2. **CURP**
3. **Comprobante de domicilio**
4. **Constancia de Situación Fiscal**
5. **Pre-aprobación de crédito o comprobantes de fondos**
6. **Acreditación de origen de recursos**

## B) PARA ARRENDAMIENTO

### Del Arrendador:
1. Escritura de propiedad
2. Identificación oficial
3. RFC (para emitir recibos de arrendamiento)
4. Contrato de arrendamiento firmado

### Del Arrendatario:
1. Identificación oficial
2. Comprobante de ingresos (3 meses)
3. Referencias personales (2)
4. Referencia laboral
5. Depósito en garantía (1-2 meses de renta)
6. Fiador o póliza jurídica

## C) DOCUMENTOS FISCALES

1. **Factura de la comisión** (CFDI)
   - Emitida por el asesor
   - Con desglose de IVA

2. **Contrato de intermediación**
   - Firmado por todas las partes
   - Con cláusulas claras

3. **Recibos de retención de ISR** (si aplica)
   - Cuando el vendedor es persona física

4. **Declaración anual del ejercicio**
   - Para el vendedor (si aplica)
   - Para el asesor

## D) DOCUMENTOS DE DEBIDA DILIGENCIA

1. **Uso de suelo** (certificado de la alcaldía/municipio)
   - Verifica que el uso sea compatible

2. **Licencia de construcción** (si aplica)
   - Para propiedades en construcción o remodeladas

3. **Manifestación de impacto ambiental** (si aplica)
   - Para propiedades en zonas protegidas

4. **Certificado de zonificación**
   - Uso de suelo específico

5. **Alineamiento y número oficial**
   - Para propiedades nuevas

## E) DOCUMENTOS ADICIONALES SEGÚN EL CASO

### Para propiedades en condominio:
• Reglamento de condominio
• Estado de cuenta de cuotas (sin adeudos)
• Acta de asamblea (si aplica)
• Certificado de no adeudo del condominio

### Para propiedades en fideicomiso:
• Contrato de fideicomiso
• Carta de instrucciones
• Autorización del fiduciario

### Para propiedades en zona restringida (extranjeros):
• Contrato de fideicomiso bancario
• Permiso de SRE
• Registro en el RPP

## F) VERIFICACIÓN DE DOCUMENTOS

### Checklist de verificación:
 Todos los documentos están vigentes
 Las firmas coinciden con las identificaciones
☐ Los datos personales son consistentes
☐ No hay tachaduras ni enmendaduras
☐ Las copias son legibles y completas
☐ Los documentos están en original (para firma)

### Señales de alerta:
⚠️ Documentos con más de 30 días de antigüedad
⚠️ Inconsistencias en nombres o datos
⚠️ Firmas que no coinciden
⚠️ Documentos tachados o enmendados
⚠️ Propietario se niega a proporcionar documentos
⚠️ Urgencia excesiva por cerrar

## G) PROTOCOLO DE MANEJO DE DOCUMENTOS

### Almacenamiento:
• Físico: Carpeta organizada por operación
• Digital: Escaneo en alta calidad (PDF)
• Respaldo: Nube segura con acceso restringido

### Conservación:
• Mínimo 5 años (Ley Antilavado)
• Recomendado: 10 años
• Acceso: Solo personal autorizado

### Confidencialidad:
• Aviso de privacidad firmado
• Uso limitado a la operación
• No compartir con terceros sin autorización
• Destrucción segura al finalizar período

## H) PLANTILLAS DE DOCUMENTOS

### Documentos que debes tener siempre:
1. Contrato de exclusividad
2. Contrato de intermediación
3. Ficha técnica del inmueble
4. Formato de precalificación de clientes
5. Formato de oferta de compra
6. Checklist de documentos
7. Aviso de privacidad
8. Declaración de origen de recursos
9. Formato de seguimiento de visitas
10. Reporte semanal al propietario

## I) ERRORES COMUNES

❌ **Aceptar documentos con más de 30 días**
❌ **No verificar original vs. copia**
❌ **No solicitar todos los documentos desde el inicio**
❌ **No verificar la vigencia de identificaciones**
❌ **No conservar copias de todo**
❌ **No tener aviso de privacidad firmado**
❌ **Compartir documentos sin autorización**
❌ **No verificar que el vendedor sea el propietario real**

## J) RECOMENDACIONES FINALES

1. **Siempre verifica documentos ANTES de cerrar**
2. **Solicita certificados actualizados 48 horas antes de la firma**
3. **Ten un abogado inmobiliario de confianza**
4. **Nunca confíes en "ya lo revisé"**
5. **Documenta todo por escrito**
6. **Cuando algo no cuadra, investiga más**
7. **Ante la duda, consulta con un especialista**
8. **Tu reputación vale más que una comisión**
''',
    },
    {
      'id': 'objeciones',
      'titulo': ' Manejo Profesional de Objeciones',
      'nivel': 'Intermedio',
      'duracion': '1 hora',
      'icono': '',
      'color': '0xFFF59E0B',
      'contenido': '''
# MANEJO PROFESIONAL DE OBJECIONES

## FÓRMULA MAESTRA: ESCUCHAR - VALIDAR - REENCUADRAR - CERRAR

## OBJECIÓN 1: "ES MUY CARO"

### ❌ NO digas:
"No es caro, es el precio de mercado"

### ✅ SÍ di:
"Entiendo tu preocupación por el precio. ¿Qué te hace sentir que está alto?"

### Técnica del comparativo:
"Te muestro 3 propiedades similares vendidas en los últimos 6 meses:
- Casa en Col. X: \$3.2M (vendida en 45 días)
- Casa en Col. Y: \$3.5M (vendida en 30 días)  
- Esta propiedad: \$3.4M (tiene 15% más de terreno)

El precio está alineado con el mercado. ¿Qué te parece si hacemos una oferta y negociamos?"

### Técnica del valor vs. precio:
"El precio es lo que pagas, el valor es lo que recibes. Esta propiedad tiene:
• 15% más de terreno que las comparables
• Acabados de lujo que costarían \$500,000 adicionales
• Ubicación en zona con 8% de plusvalía anual

En 5 años, esta propiedad valdrá \$4.5M. ¿Es caro o es una inversión inteligente?"

## OBJECIÓN 2: "LO VOY A PENSAR"

### ❌ NO digas:
"¿Qué hay que pensar? ¡Es una gran oportunidad!"

### ✅ SÍ di:
"Claro, es una decisión importante. Para ayudarte a pensar mejor, ¿qué información adicional necesitas?"

### Técnica de la objeción oculta:
"Normalmente cuando alguien me dice que lo va a pensar, es porque hay algo específico que le genera duda. ¿Es el precio, la ubicación, o algo más?"

### Técnica del costo de esperar:
"Entiendo. Pero déjame mostrarte el costo de esperar:
• Inflación inmobiliaria: 8% anual en esta zona
• Mantenimiento del inmueble: \$5,000/mes
• Impuestos prediales: \$15,000/año
• Oportunidad de inversión del capital

En 6 meses, 'no tener prisa' te cuesta aproximadamente \$180,000. ¿Vale la pena esperar?"

## OBJECIÓN 3: "LA COMISIÓN ES MUY ALTA"

### ❌ NO digas:
"Es lo que cobra todo el mundo"

### ✅ SÍ di:
"Entiendo. Te explico qué incluye mi comisión del 6%:"

### Desglose de valor:
• Marketing profesional: \$25,000 (fotos, video, portales, ads)
• Filtrado de clientes: 40+ horas de trabajo
• Asesoría legal y fiscal incluida
• Blindaje contra operaciones riesgosas
• Seguimiento hasta escrituración
• Garantía de satisfacción

"Si vendes solo, ahorras el 6% pero asumes todos los riesgos. Mi comisión se paga sola con el mejor precio de venta."

### Técnica del ROI:
"Mi comisión es \$300,000. Pero gracias a mi marketing y negociación, vendí tu propiedad en \$5.2M en lugar de \$4.8M. Esa diferencia de \$400,000 paga mi comisión y te deja \$100,000 extra. ¿Fue cara mi comisión?"

## OBJECIÓN 4: "CONOZCO A OTRO AGENTE"

### ✅ "Excelente, compara nuestros servicios. Yo ofrezco:
- Plan de marketing personalizado (no genérico)
- Reportes semanales de actividad
- Base de datos de 500+ clientes calificados
- Experiencia de X años en la zona
- Certificación AMPI y CONOCER

¿Qué te parece si hacemos una reunión sin compromiso para que compares?"

### Técnica del diferenciador:
"¿Qué te ofrece el otro agente? Porque yo ofrezco [lista tus diferenciadores únicos]. Si él ofrece lo mismo, perfecto, compara. Si no, ya sabes con quién trabajar."

## OBJECIÓN 5: "NO TENGO PRISA"

### ✅ "Perfecto, sin prisa. Pero déjame mostrarte el costo de esperar:"
• Inflación inmobiliaria: 8% anual en esta zona
• Mantenimiento del inmueble: \$5,000/mes
• Impuestos prediales: \$15,000/año
• Oportunidad de inversión del capital

"En 6 meses, 'no tener prisa' te cuesta aproximadamente \$180,000. ¿Vale la pena esperar?"

### Técnica de la oportunidad:
"Entiendo. Pero considera esto: las tasas de interés están bajando, lo que significa más compradores en el mercado. Este es el mejor momento para vender. En 6 meses, puede que haya más competencia de vendedores."

## OBJECIÓN 6: "NECESITO HABLARLO CON MI ESPOSA/ESPOSO"

### ✅ "Por supuesto, es una decisión en pareja. ¿Qué te parece si agendamos una visita juntos este fin de semana? Así ambos conocen la propiedad y pueden tomar la decisión con toda la información."

### Técnica de la decisión conjunta:
"Me parece perfecto. ¿Qué te parece si preparamos una presentación especial para ambos? Así los dos tienen la misma información y pueden decidir juntos."

## OBJECIÓN 7: "YA VIMOS OTRAS PROPIEDADES Y NO NOS GUSTARON"

### ✅ "¿Qué fue específicamente lo que no les gustó de las otras? Así puedo filtrar mejor y mostrarles solo lo que realmente les va a encantar."

### Técnica del aprendizaje:
"Perfecto, eso me ayuda a entender mejor lo que buscan. ¿Qué les gustó de las que visitaron? ¿Qué les faltó? Con esa información, puedo encontrar exactamente lo que necesitan."

## OBJECIÓN 8: "EL MERCADO ESTÁ MAL"

### ✅ "Es cierto que hay incertidumbre, pero precisamente por eso:"
• Las tasas de interés están bajando
• Hay menos competencia de compradores
• Los vendedores están más dispuestos a negociar
• Es el mejor momento para comprar a buen precio

"Los que compran en mercados 'malos' son los que más ganan cuando el mercado se recupera."

### Técnica del dato histórico:
"En 2008, cuando todos decían que el mercado estaba mal, los que compraron ganaron 80% en 5 años. En 2020, con la pandemia, los que compraron ganaron 60% en 3 años. El mercado siempre se recupera, y los que compran en 'crisis' son los que más ganan."

## TÉCNICAS AVANZADAS DE MANEJO DE OBJECIONES

### 1. Técnica del "Sí, y..."
En lugar de "pero", usa "y":
❌ "Sí, es caro, pero..."
✅ "Sí, es una inversión importante, y precisamente por eso..."

### 2. Técnica de la pregunta inversa
Cuando el cliente objeta, haz una pregunta:
"¿Qué te haría cambiar de opinión?"
"¿Qué necesitarías ver para tomar la decisión?"

### 3. Técnica del testimonio
"El Sr. García tenía la misma objeción. Después de [explicación], compró y hoy está muy satisfecho. ¿Te gustaría hablar con él?"

### 4. Técnica de la garantía
"Si en 30 días no estás satisfecho, te ayudo a revenderla sin costo adicional."

### 5. Técnica de la escasez real
"Tengo 3 familias interesadas en esta propiedad. Una de ellas hace oferta mañana. ¿Te gustaría tener la oportunidad de hacer tu oferta primero?"

## ERRORES COMUNES AL MANEJAR OBJECIONES

❌ **Ponerse a la defensiva:** "No, no es caro"
❌ **Minimizar la objeción:** "Eso no es importante"
❌ **Presionar demasiado:** "Tienes que decidir ahora"
❌ **No escuchar:** Interrumpir al cliente
❌ **Mentir:** Dar información falsa
❌ **Rendirse rápido:** "Bueno, si no quiere..."
❌ **Tomarlo personal:** "El cliente no me quiere"

## PSICOLOGÍA DETRÁS DE LAS OBJECIONES

### Las objeciones reales suelen ser:
1. **Miedo:** A tomar la decisión equivocada
2. **Dinero:** No tiene o no quiere gastar
3. **Confianza:** No confía en ti o en el producto
4. **Tiempo:** No es el momento adecuado
5. **Autoridad:** No tiene poder de decisión

### Identifica la objeción real:
"Entiendo tu preocupación. ¿Es el precio, el timing, o hay algo más que te genera duda?"

## PLAN DE ACCIÓN POR OBJECIÓN

### Para cada objeción común, ten preparado:
1. **Respuesta empática:** Valida la emoción
2. **Pregunta de indagación:** Descubre la objeción real
3. **Reencuadre:** Cambia la perspectiva
4. **Evidencia:** Datos, comparables, testimonios
5. **Cierre:** Propuesta concreta de avance

## RECUERDA

Las objeciones NO son rechazos. Son oportunidades para:
• Entender mejor al cliente
• Aclarar malentendidos
• Demostrar tu expertise
• Construir confianza
• Cerrar la venta

**Un cliente que objeta es un cliente interesado. Un cliente que no objeta es un cliente que ya se fue.**
''',
    },
    {
      'id': 'financiamiento',
      'titulo': ' Financiamiento Hipotecario en México 2026',
      'nivel': 'Intermedio',
      'duracion': '1.5 horas',
      'icono': '💰',
      'color': '0xFF10B981',
      'contenido': '''
# GUÍA COMPLETA DE FINANCIAMIENTO HIPOTECARIO 2026

## A) CRÉDITOS DE VIVIENDA EN MÉXICO

### 1. INFONAVIT
**Para quién:** Trabajadores formales con salario registrado
**Requisitos:** 1 año de cotización, cuenta individual activa
**Tasas 2026:** Desde 4.5% anual (la más baja del mercado)
**Plazo:** Hasta 30 años
**Monto máximo:** \$1,050,000 MXN (crédito tradicional)
**Monto máximo con Cofinavit:** \$2,500,000 MXN
**Enganche:** Desde 10%

**Ventajas:**
• Tasa más baja del mercado
• Plazo más largo (30 años)
• Descuento directo de nómina
• Seguro de vida incluido
• Posibilidad de pago anticipado sin penalización

**Desventajas:**
• Monto limitado
• Requisitos estrictos
• Solo para trabajadores formales
• Proceso puede ser lento

### 2. FOVISSSTE
**Para quién:** Trabajadores del estado (ISSSTE)
**Requisitos:** 1 año de cotización, subcuenta de vivienda
**Tasas 2026:** Desde 5.5% anual
**Plazo:** Hasta 30 años
**Monto máximo:** \$1,200,000 MXN
**Enganche:** Desde 10%

**Ventajas:**
• Tasa competitiva
• Ahorro previo en subcuenta
• Descuento de nómina
• Seguro de vida incluido

**Desventajas:**
• Solo para trabajadores ISSSTE
• Monto limitado
• Proceso burocrático

### 3. CRÉDITOS BANCARIOS

**BBVA México:**
• Tasa: Desde 9.5% anual
• Enganche: 10-20%
• Plazo: 5-20 años
• Monto: Hasta \$10M MXN
• Requisitos: Ingresos comprobables, buen buró

**Santander:**
• Tasa: Desde 9.8% anual
• Enganche: 10-20%
• Plazo: 5-25 años
• Monto: Hasta \$8M MXN
• Requisitos: Ingresos comprobables, buen buró

**Banorte:**
• Tasa: Desde 9.9% anual
• Enganche: 10-20%
• Plazo: 5-20 años
• Monto: Hasta \$12M MXN
• Requisitos: Ingresos comprobables, buen buró

**HSBC:**
• Tasa: Desde 10.2% anual
• Enganche: 15-20%
• Plazo: 5-20 años
• Monto: Hasta \$15M MXN
• Requisitos: Ingresos altos, excelente buró

**Scotiabank:**
• Tasa: Desde 10.5% anual
• Enganche: 10-20%
• Plazo: 5-20 años
• Monto: Hasta \$7M MXN
• Requisitos: Ingresos comprobables, buen buró

### 4. COFINACAVIT (Infonavit + Banco)
**Combina:** Crédito Infonavit + crédito bancario
**Monto máximo:** Hasta \$4,000,000 MXN
**Ventaja:** Mayor poder de compra con tasa mixta
**Requisito:** Cumplir requisitos de ambos

**Ejemplo:**
• Infonavit: \$950,000 al 4.5%
• Banco: \$1,450,000 al 10%
• Total: \$2,400,000
• Tasa promedio: 6.8%

### 5. CRÉDITO LIBRE INVERSIÓN
**Para qué:** Remodelaciones, enganche, gastos de escrituración
**Tasas:** 15-25% anual (más caras)
**Plazo:** 1-5 años
**No recomendado** para compra de inmueble

## B) DOCUMENTOS PARA PRECALIFICACIÓN BANCARIA

### Empleado asalariado:
• 3 últimos recibos de nómina
• Estados de cuenta bancarios (3 meses)
• Identificación oficial (INE/Pasaporte)
• Comprobante de domicilio
• RFC y CURP
• Carta de antigüedad laboral
• Buró de crédito (el banco lo consulta)

### Empresario/Independiente:
• Declaraciones fiscales (2 años)
• Estados de cuenta bancarios (6 meses)
• Identificación oficial
• Comprobante de domicilio
• RFC
• Estados financieros (si es persona moral)

## C) CÁLCULO DE CAPACIDAD DE PAGO

### Regla del 30%:
La mensualidad no debe exceder el 30% de tus ingresos netos mensuales.

**Ejemplo:**
• Ingreso neto mensual: \$50,000
• Pago máximo mensual: \$15,000 (30%)
• Con tasa 9.5% a 20 años: Crédito de ~\$1,600,000

### Fórmula de pago mensual:
P = [M × i × (1+i)^n] / [(1+i)^n - 1]

Donde:
• P = Pago mensual
• M = Monto del crédito
• i = Tasa de interés mensual (anual/12)
• n = Número de pagos (años × 12)

### Calculadora rápida:
• Crédito \$1,000,000 a 9.5% en 20 años = \$9,300/mes
• Crédito \$2,000,000 a 9.5% en 20 años = \$18,600/mes
• Crédito \$3,000,000 a 9.5% en 20 años = \$27,900/mes

## D) COSTOS ADICIONALES DE LA COMPRA

### Gastos de escrituración (5-8% del valor):
• Honorarios notariales: 1-2%
• Impuesto de Adquisición de Inmuebles (ISAI): 2-5% (varía por estado)
• Registro público: 0.5-1%
• Avalúo: \$3,000-\$8,000
• Gastos administrativos: \$5,000-\$15,000

### Ejemplo práctico:
• Precio del inmueble: \$3,000,000
• Enganche 20%: \$600,000
• Crédito: \$2,400,000
• Gastos de escrituración (7%): \$210,000
• **Total necesario:** \$810,000

## E) SEGURO DE VIDA Y DAÑOS

**Obligatorio** en créditos bancarios
**Costo:** 0.3-0.5% anual del saldo insoluto
**Cobertura:** Muerte, invalidez, daños al inmueble
**Beneficiario:** El banco (hasta liquidar el crédito)

## F) PROGRAMA MI CASA YA (2026)

• Subsidio del gobierno para compradores de bajos ingresos
• Monto: \$30,000 a \$120,000 MXN
• Requisitos: Ingresos familiares hasta \$10,500/mes
• Aplicable en créditos Infonavit y Fovissste

## G) COMPARATIVO DE CRÉDITOS 2026

| Institución | Tasa | Enganche | Plazo | Monto Máx |
|-------------|------|----------|-------|-----------|
| Infonavit | 4.5% | 10% | 30 años | \$1.05M |
| Fovissste | 5.5% | 10% | 30 años | \$1.2M |
| BBVA | 9.5% | 10% | 20 años | \$10M |
| Santander | 9.8% | 10% | 25 años | \$8M |
| Banorte | 9.9% | 10% | 20 años | \$12M |
| HSBC | 10.2% | 15% | 20 años | \$15M |
| Scotiabank | 10.5% | 10% | 20 años | \$7M |

## H) RECOMENDACIONES PARA EL ASESOR

1. **Conoce todas las opciones:** No te limites a un solo banco
2. **Ten aliados bancarios:** Relación con ejecutivos de varios bancos
3. **Precalifica antes de mostrar:** Evita visitas innecesarias
4. **Compara tasas:** Las tasas cambian semanalmente
5. **Considera Cofinavit:** Es la mejor opción cuando Infonavit no alcanza
6. **Calcula gastos totales:** No solo la mensualidad
7. **Asesora sobre enganche:** Más enganche = mejor tasa
8. **Revisa buró:** Antes de solicitar, revisa el buró del cliente
9. **Ten paciencia:** El proceso bancario toma 30-45 días
10. **Sé transparente:** Explica todos los costos al cliente
''',
    },
    {
      'id': 'valuacion',
      'titulo': ' Valuación Profesional de Inmuebles',
      'nivel': 'Avanzado',
      'duracion': '2 horas',
      'icono': '📊',
      'color': '0xFF8B5CF6',
      'contenido': '''
# VALUACIÓN PROFESIONAL DE INMUEBLES

## A) MÉTODOS DE VALUACIÓN

### 1. MÉTODO COMPARATIVO DE MERCADO (MCM) - MÁS USADO

**Paso 1: Selección de comparables**
• Busca 3-5 propiedades similares vendidas en los últimos 6 meses
• Mismo tipo de inmueble (casa, depto, terreno)
• Misma zona o zona comparable
• Características similares (tamaño, antigüedad, acabados)

**Paso 2: Ajustes por diferencias**

**Factor Ubicación:**
• Misma colonia: 0%
• Colonia similar: ±5%
• Colonia diferente: ±10-15%

**Factor Tamaño:**
• Por m² de terreno: valor proporcional
• Por m² de construcción: valor proporcional

**Factor Antigüedad:**
• Nueva (0-5 años): +10%
• Seminueva (5-15 años): 0%
• Antigua (15+ años): -10-20%

**Factor Acabados:**
• Lujo: +15-25%
• Medio: 0%
• Básico: -10-15%

**Factor Amenidades:**
• Alberca: +5-8%
• Jardín amplio: +3-5%
• Seguridad 24/7: +5-10%
• Estacionamiento extra: +2-3%

**Paso 3: Cálculo del valor**
• Promedia los valores ajustados de los comparables
• Considera condiciones actuales del mercado
• Ajusta por oferta y demanda local

**Ejemplo práctico:**
• Comparable 1: \$3.2M (ajustado +5% ubicación) = \$3.36M
• Comparable 2: \$3.5M (ajustado -10% antigüedad) = \$3.15M
• Comparable 3: \$3.1M (ajustado +8% acabados) = \$3.35M
• **Valor estimado:** (\$3.36M + \$3.15M + \$3.35M) / 3 = **\$3.29M**

### 2. MÉTODO DE CAPITALIZACIÓN DE RENTAS (Para inversión)

**Fórmula:**
Valor = Renta anual neta / Tasa de capitalización

**Ejemplo:**
• Renta mensual: \$25,000
• Renta anual: \$300,000
• Tasa de capitalización: 8% (0.08)
• **Valor:** \$300,000 / 0.08 = **\$3,750,000**

**Tasas de capitalización por tipo:**
• Residencial: 6-8%
• Comercial: 8-10%
• Industrial: 10-12%
• Terrenos: 4-6%

### 3. MÉTODO DE COSTO (Para propiedades únicas)

**Fórmula:**
Valor = Valor del terreno + Costo de construcción - Depreciación

**Ejemplo:**
• Terreno: \$1,500,000
• Construcción (200 m² × \$15,000/m²): \$3,000,000
• Depreciación (10 años × 2%): -\$600,000
• **Valor:** \$1,500,000 + \$3,000,000 - \$600,000 = **\$3,900,000**

## B) FACTORES QUE AFECTAN EL VALOR

### Factores POSITIVOS (+):
✅ Ubicación en zona de plusvalía
✅ Cerca de escuelas, hospitales, centros comerciales
✅ Seguridad de la zona
✅ Vías de acceso y transporte público
✅ Servicios públicos (agua, luz, drenaje, gas)
✅ Acabados de calidad
✅ Diseño arquitectónico funcional
✅ Iluminación natural
✅ Ventilación cruzada
✅ Áreas verdes
✅ Seguridad privada
✅ Amenidades (alberca, gimnasio, salón de eventos)

### Factores NEGATIVOS (-):
❌ Zona de riesgo (inundación, deslizamiento)
❌ Contaminación ambiental o sonora
❌ Falta de servicios públicos
❌ Mal estado de conservación
❌ Diseño obsoleto o poco funcional
❌ Problemas legales (gravámenes, litigios)
❌ Vecindario conflictivo
❌ Mala orientación (sol directo todo el día)

## C) HERRAMIENTAS DE VALUACIÓN

### Gratuitas:
• Portal de la SHF (Sociedad Hipotecaria Federal): www.shf.gob.mx
• INEGI: Precios de vivienda por zona
• Comparadores online: Propiedades.com, Lamudi, Inmuebles24
• Registro Público de la Propiedad (RPP)

### De pago:
• Avalúos certificados por valuador autorizado: \$3,000-\$8,000
• Software especializado: Valúo, InmueblesPro
• Consultoría de mercado: \$10,000-\$50,000

## D) TIPOS DE AVALÚO

### 1. Avalúo Comercial:
• Para determinar precio de venta/renta
• Vigencia: 6 meses
• Costo: \$3,000-\$8,000

### 2. Avalúo Fiscal:
• Para cálculo de impuestos (ISAI, ISR)
• Lo realiza el municipio o estado
• Generalmente menor al valor comercial

### 3. Avalúo Bancario:
• Para créditos hipotecarios
• Lo realiza el banco o perito autorizado
• Debe ser conservador (menor al comercial)

### 4. Avalúo de Seguro:
• Para pólizas de seguro
• Considera costo de reconstrucción
• No incluye valor del terreno

## E) ERRORES COMUNES EN VALUACIÓN

 **Valuar solo por precio de publicación** (no de venta real)
❌ **No considerar el tiempo en el mercado** (si lleva 6+ meses, está sobrevaluada)
❌ **Ignorar tendencias del mercado** (¿sube o baja la zona?)
❌ **No ajustar por diferencias reales** (no es lo mismo 200m² que 250m²)
❌ **Valuar por emoción** (el propietario "cree" que vale más)
❌ **Usar comparables de hace más de 6 meses** (el mercado cambia)
❌ **No considerar costos de mantenimiento** (inmuebles viejos valen menos)

## F) PRECIO DE LISTA vs. PRECIO DE VENTA

**Regla general:**
• Precio de lista: 5-10% arriba del valor de mercado
• Precio de venta real: 3-7% abajo del precio de lista
• Tiempo promedio de venta: 90-180 días

**Ejemplo:**
• Valor de mercado: \$3,000,000
• Precio de lista: \$3,150,000 (5% arriba)
• Precio de venta esperado: \$2,900,000 (8% abajo del lista)
• Negociación típica: 5-10%

## G) TENDENCIAS DE MERCADO 2026

### Nacional:
• Plusvalía promedio: 6-8% anual
• Zonas de alta plusvalía: Querétaro, Mérida, Tulum, CDMX (zonas específicas)
• Tasas de interés: Bajando (9.5-10.5% bancario)
• Demanda: Alta en vivienda media y media-plus

### Por tipo:
• Casas: +7% plusvalía anual
• Departamentos: +5% plusvalía anual
• Terrenos: +10% plusvalía anual (zonas de crecimiento)
• Locales comerciales: +4% plusvalía anual
• Oficinas: +3% plusvalía anual (home office redujo demanda)

## H) PRESENTACIÓN DEL AMV AL PROPIETARIO

### Estructura de la presentación:
1. **Introducción:** Agradecimiento y objetivo
2. **Análisis de mercado:** Datos de la zona
3. **Comparables:** 3-5 propiedades similares
4. **Ajustes:** Explicación de diferencias
5. **Precio recomendado:** Con justificación
6. **Plan de marketing:** Cómo lo venderás
7. **Timeline:** Tiempo estimado de venta
8. **Cierre:** Firma de exclusividad

### Tips para la presentación:
• Usa gráficos y tablas visuales
• Lleva copia impresa para el propietario
• Sé transparente con los datos
• Explica el método de forma sencilla
• Responde todas las preguntas
• No presiones, deja que los datos hablen

## I) HERRAMIENTAS DIGITALES PARA VALUACIÓN

### Apps recomendadas:
• **Valúo:** Valuación profesional certificada
• **InmueblesPro:** Comparables y análisis
• **Propiedades.com:** Datos de mercado
• **INEGI:** Estadísticas oficiales
• **SHF:** Indicadores hipotecarios

### Software de escritorio:
• **Excel:** Para cálculos personalizados
• **AutoCAD:** Para planos y medidas
• **Photoshop:** Para edición de fotos
• **Matterport:** Para tours virtuales 3D

## J) CERTIFICACIÓN EN VALUACIÓN

### Cursos recomendados:
• **EC0247.01:** Valuación de inmuebles urbanos (CONOCER)
• **Diplomado en Valuación:** UNAM, Tec de Monterrey
• **Curso de AMV:** AMPI centros de capacitación

### Requisitos para ser valuador certificado:
• Título universitario (arquitectura, ingeniería, administración)
• Experiencia mínima de 3 años
• Certificación CONOCER
• Membresía en organismo de valuadores
• Educación continua anual
''',
    },
    {
      'id': 'marketing',
      'titulo': '📱 Marketing Digital Inmobiliario 2026',
      'nivel': 'Intermedio',
      'duracion': '2 horas',
      'icono': '📱',
      'color': '0xFFEC4899',
      'contenido': '''
# MARKETING DIGITAL INMOBILIARIO 2026

## A) ESTRATEGIA INTEGRADA DE MARKETING

### 1. PORTALES INMOBILIARIOS (40% de leads)

**Principales portales México:**
• Inmuebles24.com (mayor tráfico)
• Lamudi.com.mx (segundo lugar)
• Propiedades.com (tercero)
• Vivanuncios.com (cuarto)
• MercadoLibre Inmuebles (quinto)

**Costos mensuales:**
• Plan básico: \$1,500-\$3,000/mes (3-5 propiedades)
• Plan profesional: \$5,000-\$8,000/mes (10-15 propiedades)
• Plan enterprise: \$12,000-\$20,000/mes (ilimitadas)

**Mejores prácticas:**
• Mínimo 20 fotos profesionales por propiedad
• Título atractivo: "Casa 3 rec en [Colonia] con alberca"
• Descripción detallada (mínimo 300 palabras)
• Precio correcto (no inflado)
• Actualización semanal de publicaciones
• Respuesta a mensajes en menos de 2 horas

### 2. REDES SOCIALES (35% de leads)

**Facebook Ads:**
• **Presupuesto:** \$3,000-\$10,000/mes
• **Segmentación:** Zona geográfica + poder adquisitivo + intereses
• **Formatos:** Carrusel (5-10 fotos), Video (30-60 seg), Lead Ads
• **Métricas clave:** Costo por lead \$150-\$400, CTR 1-3%

**Instagram:**
• **Contenido:** Fotos profesionales, Reels de tours, Stories diarios
• **Hashtags:** #bienesraices #casasenventa #[ciudad] #inmuebles
• **Frecuencia:** 1 post diario + 3-5 stories
• **Colaboraciones:** Influencers locales de lifestyle

**TikTok:**
• **Contenido:** Tours virtuales cortos (15-30 seg), tips inmobiliarios
• **Formato:** Vertical, música trending, texto en pantalla
• **Frecuencia:** 3-5 videos por semana
• **Viralidad:** Alto potencial de alcance orgánico

**LinkedIn:**
• **Para:** Clientes corporativos, inversionistas, oficinas
• **Contenido:** Artículos de mercado, análisis de inversión
• **Frecuencia:** 2-3 posts por semana

**YouTube:**
• **Contenido:** Tours virtuales largos (5-10 min), videos educativos
• **SEO:** Títulos con palabras clave, descripciones detalladas
• **Frecuencia:** 1-2 videos por semana

### 3. SITIO WEB PROPIO (15% de leads)

**Elementos esenciales:**
• Dominio profesional: tunombre.com
• Diseño responsive (móvil y desktop)
• Catálogo de propiedades con filtros
• Formulario de contacto en cada propiedad
• Blog con contenido de valor (SEO)
• Testimonios de clientes
• Certificaciones y credenciales

**Costos:**
• Dominio: \$300-\$500/año
• Hosting: \$1,000-\$3,000/año
• Diseño: \$15,000-\$50,000 (una vez)
• Mantenimiento: \$2,000-\$5,000/mes

### 4. EMAIL MARKETING (10% de leads)

**Estrategia:**
• Base de datos segmentada (compradores, vendedores, inversionistas)
• Newsletter mensual con propiedades nuevas
• Automatización de seguimiento
• Campañas de reactivación de clientes inactivos

**Herramientas:**
• Mailchimp (gratis hasta 500 contactos)
• ActiveCampaign (\$500-\$2,000/mes)
• HubSpot (gratis hasta 1,000 contactos)

**Métricas:**
• Tasa de apertura: 20-30%
• Tasa de clics: 3-5%
• Tasa de conversión: 1-2%

### 5. GOOGLE ADS Y SEO (5% de leads)

**Google Ads:**
• **Presupuesto:** \$5,000-\$15,000/mes
• **Keywords:** "casas en venta en [zona]", "departamentos [ciudad]"
• **Costo por clic:** \$15-\$50
• **Conversión:** 2-5%

**SEO Local:**
• Google My Business optimizado
• Reseñas de clientes (mínimo 20)
• Palabras clave locales en sitio web
• Directorios inmobiliarios

## B) CONTENIDO DE VALOR

### Tipos de contenido que funcionan:

**Educativo:**
• "Cómo comprar tu primera casa"
• "Guía de financiamiento hipotecario"
• "Documentos necesarios para vender"
• "Errores comunes al comprar propiedad"

**De mercado:**
• "Tendencias del mercado inmobiliario 2026"
• "Zonas con mayor plusvalía en [ciudad]"
• "Análisis de precios por colonia"

**De propiedades:**
• Tours virtuales
• Antes y después de remodelaciones
• "Casa del día"
• Comparativos de propiedades

**Testimoniales:**
• Historias de clientes satisfechos
• Casos de éxito
• Reseñas en video

## C) PRESUPUESTO RECOMENDADO

### Asesor independiente:
• Portales: \$3,000/mes
• Facebook Ads: \$5,000/mes
• Fotografía: \$2,000/propiedad
• **Total:** \$10,000-\$15,000/mes

### Inmobiliaria pequeña (3-5 asesores):
• Portales: \$8,000/mes
• Facebook Ads: \$15,000/mes
• Sitio web: \$5,000/mes
• Fotografía: \$5,000/mes
• **Total:** \$33,000-\$40,000/mes

### Inmobiliaria mediana (10-20 asesores):
• Portales: \$20,000/mes
• Facebook Ads: \$40,000/mes
• Sitio web: \$10,000/mes
• Fotografía y video: \$15,000/mes
• Email marketing: \$3,000/mes
• **Total:** \$88,000-\$100,000/mes

## D) MÉTRICAS CLAVE (KPIs)

### Leads:
• Costo por lead (CPL): \$150-\$400
• Tasa de conversión lead a visita: 20-30%
• Tasa de conversión visita a oferta: 10-15%
• Tasa de conversión oferta a venta: 30-50%

### Redes sociales:
• Alcance: 10,000-50,000/mes
• Engagement rate: 3-7%
• Seguidores nuevos: 100-500/mes
• Shares y saves: 50-200/mes

### ROI (Retorno de Inversión):
• Inversión mensual: \$50,000
• Ventas generadas: 2/mes
• Comisión promedio: \$300,000
• Ingresos: \$600,000
• **ROI:** 1,100% (12x la inversión)

## E) CALENDARIO DE CONTENIDO SEMANAL

### Lunes:
• Post educativo (tip, guía, consejo)
• Story: "Casa de la semana"

### Martes:
• Reel/TikTok de tour virtual
• Story: Behind the scenes

### Miércoles:
• Post de propiedad destacada
• Story: Testimonio de cliente

### Jueves:
• Post de mercado (datos, tendencias)
• Story: Encuesta o pregunta

### Viernes:
• Video largo (YouTube)
• Story: Fin de semana de visitas

### Sábado:
• Post de estilo de vida
• Story: Visita en vivo

### Domingo:
• Descanso o contenido ligero
• Story: Reflexión o motivación

## F) HERRAMIENTAS DE MARKETING

### Diseño:
• Canva Pro: \$200/mes
• Adobe Creative Suite: \$800/mes
• Remove.bg: \$100/mes

### Video:
• CapCut: Gratis
• Adobe Premiere: \$500/mes
• Final Cut Pro: \$5,000 (una vez)

### Programación:
• Meta Business Suite: Gratis
• Hootsuite: \$500/mes
• Buffer: \$300/mes

### Analytics:
• Google Analytics: Gratis
• Facebook Insights: Gratis
• Hotjar: \$500/mes

## G) TENDENCIAS 2026

### Realidad Virtual:
• Tours virtuales 3D
• Visitas remotas
• Staging virtual

### Inteligencia Artificial:
• Chatbots para atención 24/7
• Generación de descripciones
• Análisis de comportamiento

### Video:
• Contenido corto (Reels, TikTok)
• Lives de visitas
• Videos educativos

### Personalización:
• Email segmentado
• Ads hiper-segmentados
• Contenido personalizado

### Sustentabilidad:
• Propiedades eco-friendly
• Certificaciones LEED
• Marketing verde
''',
    },
    {
      'id': 'cierre',
      'titulo': ' Técnicas Profesionales de Cierre',
      'nivel': 'Avanzado',
      'duracion': '2 horas',
      'icono': '🎯',
      'color': '0xFFEF4444',
      'contenido': '''
# TÉCNICAS PROFESIONALES DE CIERRE DE VENTAS

## A) SEÑALES DE QUE EL CLIENTE ESTÁ LISTO PARA CERRAR

### Señales verbales:
✅ "¿Cuánto tiempo toma el proceso?"
✅ "¿Qué documentos necesito?"
✅ "¿Puedo ver la propiedad otra vez?"
✅ "¿El precio es negociable?"
✅ "¿Qué incluye el precio?"
✅ "¿Cuándo estaría disponible?"
✅ "¿Hay otras ofertas?"

### Señales no verbales:
✅ Trae a familiares o amigos
✅ Pasa mucho tiempo en una propiedad
✅ Hace preguntas específicas sobre acabados
✅ Imagina sus muebles en los espacios
✅ Pide medir espacios
✅ Revisa tomas de agua, luz, gas

## B) TÉCNICAS DE CIERRE

### 1. CIERRE DIRECTO
"¿Le gustaría hacer la oferta hoy?"
"¿Procedemos con la compra?"
"¿Firmamos el contrato?"

**Cuándo usarlo:** Cliente muy interesado, sin objeciones.

### 2. CIERRE DE OPCIONES
"¿Prefiere entregar el próximo mes o en 60 días?"
"¿Le gustaría con todos los muebles o sin ellos?"
"¿Pago de contado o con crédito?"

**Cuándo usarlo:** Cliente indeciso entre dos opciones.

### 3. CIERRE POR URGENCIA
"Tengo otra visita mañana con oferta en mano"
"El propietario viajará la próxima semana"
"Esta propiedad no durará mucho en el mercado"

**Cuándo usarlo:** Propiedad con alta demanda, cliente interesado pero indeciso.

### 4. CIERRE POR BENEFICIO
"Si cerramos hoy, puedo negociar que el vendedor deje todos los muebles"
"Si hacemos la oferta esta semana, el propietario acepta \$100,000 menos"
"Si firma hoy, le incluyo el avalúo sin costo"

**Cuándo usarlo:** Cliente sensible al precio o beneficios adicionales.

### 5. CIERRE POR RESUMEN
"Entonces tenemos: casa de 3 recámaras, jardín, excelente ubicación, dentro de su presupuesto, con financiamiento pre-aprobado. ¿Procedemos?"

**Cuándo usarlo:** Cliente que necesita recordar todos los beneficios.

### 6. CIERRE POR PREGUNTA
"¿Qué le impide tomar la decisión hoy?"
"¿Qué necesitamos resolver para avanzar?"
"¿Hay algo más que necesite saber?"

**Cuándo usarlo:** Cliente con objeción oculta.

### 7. CIERRE SILENCIOSO
Después de presentar la oferta, **calla**. El primero que hable, pierde.

**Cuándo usarlo:** Después de hacer la propuesta final.

### 8. CIERRE POR ASUNCIÓN
"Perfecto, entonces agendamos la firma para el viernes. ¿Le parece bien a las 10am o a las 12pm?"

**Cuándo usarlo:** Cliente ya decidió, solo necesita que lo guíes.

### 9. CIERRE POR TESTIMONIO
"El Sr. García compró una propiedad similar hace 2 meses y hoy vale 15% más. ¿Le gustaría tener el mismo resultado?"

**Cuándo usarlo:** Cliente necesita validación social.

### 10. CIERRE POR GARANTÍA
"Si en 30 días no está satisfecho, le ayudo a revenderla sin costo adicional"

**Cuándo usarlo:** Cliente con miedo a tomar la decisión equivocada.

## C) MANEJO DE OBJECIONES EN EL CIERRE

### "Necesito pensarlo":
"Entiendo. ¿Qué específicamente necesita pensar? ¿Es el precio, la ubicación, o algo más?"

### "Tengo que consultarlo":
"Por supuesto. ¿Qué le parece si agendamos una llamada con [persona] para resolver todas sus dudas juntos?"

### "Es mucho dinero":
"Entiendo. Pero considere esto: en 5 años esta propiedad valdrá 40% más. ¿Es mucho dinero o es una inversión inteligente?"

### "Hay otras opciones":
"Excelente. Compare y verá que esta propiedad ofrece el mejor valor. ¿Qué tiene las otras que esta no?"

### "No estoy seguro":
"¿Qué le genera inseguridad? Estoy aquí para resolver todas sus dudas."

## D) ERRORES AL CERRAR

❌ **Presionar demasiado:** El cliente se siente acorralado y huye
❌ **No escuchar objeciones reales:** No resuelves el problema real
❌ **No tener documentos listos:** Pierdes momentum
❌ **No hacer seguimiento post-visita:** El cliente se enfría
❌ **Hablar de más:** Después de hacer la propuesta, calla
❌ **Mostrar desesperación:** El cliente huele la necesidad y negocia más duro
❌ **No tener plan B:** Si no cierras hoy, ¿cuál es el siguiente paso?

## E) SEGUIMIENTO POST-VISITA

### 24 horas después:
• Mensaje de agradecimiento
• Preguntar qué le pareció la propiedad
• Ofrecer resolver dudas

### 48 horas después:
• Llamar para conocer decisión
• Si está interesado: agendar segunda visita o presentar oferta
• Si no está interesado: preguntar por qué y ofrecer alternativas

### 7 días después:
• Enviar propiedades similares
• Mantener contacto sin presionar

### 14 días después:
• Llamar para conocer si avanzó con otras propiedades
• Ofrecer ayuda si necesita algo

### 30 días después:
• Email con nuevas propiedades
• Mantener en base de datos para futuras oportunidades

## F) PSICOLOGÍA DEL CIERRE

### Principio de escasez:
"Esta propiedad es única en la zona. No hay otra igual."

### Principio de autoridad:
"Como asesor certificado con 10 años de experiencia, le recomiendo..."

### Principio de reciprocidad:
"Le conseguí un precio especial. ¿Qué le parece si avanzamos?"

### Principio de consistencia:
"Me dijo que esta propiedad cumplía todo lo que buscaba. ¿Qué cambió?"

### Principio de prueba social:
"3 familias han hecho oferta esta semana. Es muy buscada."

### Principio de afinidad:
"Entiendo perfectamente su situación. Yo también busqué casa hace 5 años."

## G) PLAN DE CIERRE POR ETAPA

### Etapa 1: Primera visita
**Objetivo:** Generar interés
**Acción:** Presentación completa, responder preguntas
**Cierre:** Agendar segunda visita

### Etapa 2: Segunda visita
**Objetivo:** Profundizar interés
**Acción:** Mostrar detalles, resolver dudas
**Cierre:** Presentar oferta preliminar

### Etapa 3: Negociación
**Objetivo:** Llegar a un acuerdo
**Acción:** Negociar precio y condiciones
**Cierre:** Aceptación de oferta

### Etapa 4: Apartado
**Objetivo:** Formalizar interés
**Acción:** Cobro de anticipo, firma de apartado
**Cierre:** Contrato de apartado firmado

### Etapa 5: Escrituración
**Objetivo:** Cerrar la operación
**Acción:** Firma ante notario, pago total
**Cierre:** Entrega de llaves

## H) MÉTRICAS DE CIERRE

### Tasa de cierre promedio:
• Principiante: 5-10%
• Intermedio: 15-25%
• Avanzado: 30-40%
• Experto: 40-50%

### Mejores prácticas:
• Califica bien a los clientes (BANT)
• Muestra solo propiedades que califiquen
• Haz seguimiento sistemático
• Usa técnicas de cierre apropiadas
• Aprende de cada venta (ganada o perdida)

## I) CELEBRACIÓN Y POST-VENTA

### Después del cierre:
• Felicita al cliente (llamada, mensaje, tarjeta)
• Entrega de llaves ceremonial
• Regalo de bienvenida (opcional)
• Solicitud de reseña y referido
• Actualización en base de datos
• Seguimiento a 30, 60, 90 días

### Beneficios del post-venta:
• Clientes satisfechos = Referidos
• Reseñas positivas = Más leads
• Relación a largo plazo = Futuras operaciones
• Reputación profesional = Más ventas

## J) DESARROLLO CONTINUO

### Para mejorar tu cierre:
• Practica con role-playing
• Estudia psicología de ventas
• Aprende de los mejores
• Analiza tus ventas (ganadas y perdidas)
• Capacitación continua
• Mentoría con asesores top

**Recuerda:** Cerrar no es manipular. Es ayudar al cliente a tomar la mejor decisión para él. Si crees genuinamente en el valor de la propiedad, el cierre será natural.
''',
    },
    {
      'id': 'procedimientos',
      'titulo': '📋 Procedimientos Operativos Estándar',
      'nivel': 'Intermedio',
      'duracion': '1.5 horas',
      'icono': '📋',
      'color': '0xFF64748B',
      'contenido': '''
# PROCEDIMIENTOS OPERATIVOS ESTÁNDAR (POE)

## A) PROCESO DE COMPRAVENTA COMPLETO

### FASE 1: CAPTACIÓN (Días 1-7)
☐ Visita inicial al inmueble
☐ Análisis de documentación
☐ AMV (Análisis de Mercado de Valores)
☐ Fotografía profesional y tour virtual
☐ Firma de contrato de exclusividad
☐ Publicación en portales y redes

### FASE 2: PROMOCIÓN (Días 7-30)
☐ Campaña de marketing digital
☐ Filtrado de prospectos
☐ Visitas guiadas (máximo 3 por día)
☐ Seguimiento post-visita (24-48 horas)
☐ Reportes semanales al propietario

### FASE 3: NEGOCIACIÓN (Días 30-60)
☐ Recepción de ofertas
☐ Presentación al propietario
☐ Negociación de términos
☐ Aceptación de oferta
☐ Apartado con anticipo (5-10%)

### FASE 4: CIERRE LEGAL (Días 60-90)
☐ Verificación documental completa
☐ Trámite de crédito (si aplica)
☐ Avalúo bancario
☐ Firma de contrato de compra-venta
☐ Pago de impuestos (ISAI)
 Firma ante notario
☐ Registro en RPP
☐ Entrega de llaves

### FASE 5: POST-VENTA (Días 90-120)
☐ Seguimiento de satisfacción
☐ Solicitud de referidos
☐ Actualización de base de datos
☐ Celebración con cliente

## B) PROCESO DE ARRENDAMIENTO

### FASE 1: CAPTACIÓN (Días 1-5)
☐ Visita al inmueble
☐ Verificación de documentación
☐ Definición de renta y condiciones
☐ Firma de contrato de exclusividad
☐ Fotografía y publicación

### FASE 2: FILTRADO DE INQUILINOS (Días 5-20)
☐ Recepción de solicitudes
☐ Verificación de ingresos (3x la renta)
☐ Consulta de buró de crédito
☐ Verificación de referencias
☐ Visita guiada

### FASE 3: CIERRE (Días 20-30)
☐ Selección de inquilino
☐ Firma de contrato de arrendamiento
☐ Cobro de depósito y primera renta
☐ Entrega de inmueble (inventario firmado)

### FASE 4: ADMINISTRACIÓN (Mensual)
☐ Cobro de renta
☐ Atención de reparaciones
☐ Reportes al propietario
☐ Renovación de contrato (anual)

## C) CHECKLIST DE DOCUMENTOS POR OPERACIÓN

### COMPRAVENTA:
☐ Identificaciones de ambas partes
☐ Escritura de propiedad
☐ Certificado de libertad de gravamen
☐ Predial y agua pagados
☐ Avalúo
☐ Contrato de compra-venta
☐ Factura de comisión
☐ Aviso UIF (si aplica)
☐ Póliza de seguro (si hay crédito)

### ARRENDAMIENTO:
 Identificaciones de ambas partes
☐ Escritura de propiedad
☐ Contrato de arrendamiento
 Inventario del inmueble
☐ Comprobante de ingresos del inquilino
☐ Depósito en garantía
☐ Póliza jurídica (opcional)

## D) TIMELINE ESTÁNDAR

### Compra de contado:
• Día 1: Oferta aceptada
• Día 2-5: Verificación documental
• Día 5-10: Pago de impuestos
• Día 10-15: Firma ante notario
• Día 15-20: Registro en RPP
• Día 20: Entrega de llaves

### Compra con crédito:
• Día 1: Oferta aceptada
• Día 2-5: Verificación documental
• Día 5-10: Solicitud de crédito
• Día 10-25: Aprobación de crédito
• Día 25-30: Avalúo bancario
• Día 30-35: Pago de impuestos
• Día 35-40: Firma ante notario
• Día 40-45: Registro en RPP
• Día 45: Entrega de llaves

### Arrendamiento:
• Día 1: Solicitud de inquilino
• Día 2-5: Verificación de ingresos y referencias
• Día 5-7: Aprobación
• Día 7-10: Firma de contrato
• Día 10: Entrega de inmueble

## E) PROTOCOLO DE ATENCIÓN AL CLIENTE

### Primera llamada (menos de 3 rings):
"Hola, soy [nombre] de [inmobiliaria]. ¿En qué puedo ayudarte?"

### Primera visita:
• Puntualidad (5 min antes)
• Presentación profesional
• Recorrido guiado (no dejar que el cliente explore solo)
• Responder todas las preguntas
• Entregar ficha técnica impresa
• Despedida cordial

### Seguimiento post-visita:
• 24 horas: Mensaje de agradecimiento
• 48 horas: Llamada para conocer decisión
• 7 días: Envío de propiedades similares
• 14 días: Llamada de seguimiento
• 30 días: Email con nuevas opciones

### Quejas y reclamaciones:
• Escuchar sin interrumpir
• Validar la emoción del cliente
• Ofrecer solución concreta
• Dar plazo de resolución
• Dar seguimiento hasta resolver
• Documentar todo por escrito

## F) ESTÁNDARES DE CALIDAD

### Comunicación:
• Responder mensajes en menos de 2 horas
• Llamar de vuelta en menos de 4 horas
• Emails respondidos en 24 horas
• Reportes semanales a propietarios

### Profesionalismo:
• Vestimenta formal en visitas
• Puntualidad (5 min antes)
• Lenguaje profesional
• Confidencialidad absoluta
• Honestidad en toda información

### Documentación:
• Todos los documentos en orden
• Copias digitales de respaldo
• Organización por operación
• Acceso rápido a información

### Seguimiento:
• CRM actualizado diariamente
• Seguimiento sistemático a clientes
• Recordatorios de actividades
• Reportes de actividad semanales

## G) INDICADORES DE DESEMPEÑO (KPIs)

### Para asesores:
• Visitas realizadas por semana: 10-15
• Ofertas presentadas por mes: 3-5
• Ventas cerradas por mes: 1-2
• Tasa de conversión: 20-30%
• Tiempo promedio de venta: 60-90 días
• Satisfacción del cliente: 9/10

### Para la inmobiliaria:
• Propiedades captadas por mes: 10-20
• Propiedades activas en cartera: 30-50
• Ventas cerradas por mes: 5-10
• Ingresos mensuales: Variables
• ROI de marketing: 10x+
• Retención de asesores: 80%+

## H) MEJORA CONTINUA

### Revisión mensual:
• Análisis de ventas cerradas
• Análisis de ventas perdidas
• Revisión de KPIs
• Ajuste de estrategias
• Capacitación del equipo

### Revisión trimestral:
• Análisis de mercado
• Ajuste de precios
• Revisión de marketing
• Evaluación de asesores
• Planificación siguiente trimestre

### Revisión anual:
• Resultados del año
• Metas para el siguiente año
• Inversión en tecnología
• Capacitación anual
• Actualización de procedimientos

## I) TECNOLOGÍA Y HERRAMIENTAS

### CRM recomendado:
• Salesforce (enterprise)
• HubSpot (PYME)
• Zoho CRM (económico)
• InmobiliaPro (especializado)

### Herramientas de marketing:
• Canva (diseño)
• Mailchimp (email)
• Hootsuite (redes sociales)
• Google Analytics (web)

### Herramientas de productividad:
• Google Workspace (documentos)
• Trello/Asana (proyectos)
• Zoom/Teams (reuniones)
• DocuSign (firmas digitales)

## J) CAPACITACIÓN CONTINUA

### Mensual:
• Actualización de mercado
• Nuevas técnicas de venta
• Cambios legales/fiscales
• Herramientas digitales

### Trimestral:
• Workshop de cierre
• Análisis de casos
• Role-playing
• Evaluación de desempeño

### Anual:
• Certificaciones
• Congresos y eventos
• Cursos especializados
• Plan de desarrollo individual

**Recuerda:** Los procedimientos no son restricciones, son guías que te ayudan a ser más eficiente y profesional. Úsalos como base, pero adáptalos a cada situación.
''',
    },
  ];
}