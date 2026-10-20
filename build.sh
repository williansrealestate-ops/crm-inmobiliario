#!/bin/bash
set -e  # Detener el script si hay errores

echo " Iniciando build de Flutter Web..."

# Instalar Flutter si no existe
if [ ! -d "/tmp/flutter" ]; then
  echo " Instalando Flutter desde GitHub..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
fi

# Agregar Flutter al PATH
export PATH="/tmp/flutter/bin:$PATH"

# Esperar a que Flutter se inicialice
echo "⏳ Inicializando Flutter..."
flutter doctor -v || true

# Verificar versión
echo "✅ Flutter instalado:"
flutter --version

# Precache artefactos para web
echo " Preparando Flutter para web..."
flutter precache --web

# Instalar dependencias del proyecto
echo "📦 Instalando dependencias del proyecto..."
flutter pub get

# Compilar para web
echo "🔨 Compilando para web..."
flutter build web --release --web-renderer html

# Verificar archivos generados
echo ""
echo "📂 Archivos generados en build/web:"
ls -lh build/web/
echo ""

# Verificar que main.dart.js existe
if [ -f "build/web/main.dart.js" ]; then
  echo "✅ main.dart.js generado correctamente"
  echo "📊 Tamaño: $(ls -lh build/web/main.dart.js | awk '{print $5}')"
else
  echo "❌ ERROR: main.dart.js no se generó"
  exit 1
fi

echo ""
echo "✅ Build completado exitosamente!"