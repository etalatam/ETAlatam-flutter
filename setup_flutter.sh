#!/bin/bash

echo "==================================="
echo "Configuración de Flutter y FVM"
echo "==================================="

# Verificar si FVM está instalado
if ! command -v ~/.fvm_flutter/bin/fvm &> /dev/null; then
    echo "❌ FVM no está instalado. Instalando..."
    curl -fsSL https://fvm.app/install.sh | bash
fi

echo "✅ FVM instalado en: ~/.fvm_flutter/bin/fvm"

# Instalar Flutter 3.19.0
echo ""
echo "Instalando Flutter 3.19.0..."
~/.fvm_flutter/bin/fvm install 3.19.0

# Configurar Flutter para el proyecto
echo ""
echo "Configurando Flutter 3.19.0 para el proyecto..."
~/.fvm_flutter/bin/fvm use 3.19.0 --force

# Verificar instalación
echo ""
echo "==================================="
echo "Verificando instalación:"
echo "==================================="
~/.fvm_flutter/bin/fvm flutter --version

echo ""
echo "==================================="
echo "Configuración completada!"
echo "==================================="
echo ""
echo "Para usar Flutter en este proyecto, ejecuta:"
echo "  fvm flutter <comando>"
echo ""
echo "O usa los aliases (requiere reiniciar terminal):"
echo "  flutter <comando>"
echo "  dart <comando>"
echo ""
echo "Ejemplo:"
echo "  fvm flutter pub get"
echo "  fvm flutter run"