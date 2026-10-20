#!/bin/bash

# Agregar Flutter al PATH
export PATH="/tmp/flutter/bin:$PATH"

# Instalar dependencias del proyecto
flutter pub get

# Compilar para web
flutter build web --release

echo "Build completado"