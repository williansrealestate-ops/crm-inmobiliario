#!/bin/bash

# Instalar Flutter si no existe
if [ ! -d "/tmp/flutter" ]; then
  echo "Instalando Flutter..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /tmp/flutter
fi

# Agregar Flutter al PATH
export PATH="/tmp/flutter/bin:$PATH"

# Verificar instalación
flutter --version

# Habilitar web
flutter config --enable-web

# Instalar dependencias
echo "Instalando dependencias..."
flutter pub get

# Compilar para web
echo "Compilando para web..."
flutter build web --release

echo "✅ Build completado exitosamente"