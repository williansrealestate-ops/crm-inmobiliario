#!/bin/bash
set -e

# Flutter ya está en el PATH por el install command de Vercel
flutter pub get
flutter build web --release

echo "✅ Build completado"
ls -la build/web/