#!/bin/bash

echo "============================================"
echo "  Pruebas de Integración - Login Flow"
echo "============================================"
echo ""
echo "Credenciales de prueba:"
echo "Email: etalatam+representante1@gmail.com"
echo "Password: casa1234"
echo ""

# Configurar variables de entorno
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANDROID_HOME=/opt/android-sdk
export PATH=$JAVA_HOME/bin:$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Verificar si hay un dispositivo conectado
echo "Verificando dispositivos disponibles..."
DEVICES=$(adb devices | grep -E "device$|emulator" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo "❌ No se encontraron dispositivos Android conectados o emuladores activos"
    echo ""
    echo "Por favor, conecta un dispositivo o inicia un emulador:"
    echo "  - Conectar dispositivo físico con USB debugging habilitado"
    echo "  - O iniciar un emulador Android"
    exit 1
fi

echo "✓ Dispositivo(s) encontrado(s)"
adb devices
echo ""

# Ejecutar pruebas de integración
echo "Ejecutando pruebas de integración..."
echo "Esto puede tomar varios minutos..."
echo ""

fvm flutter test integration_test/login_test.dart

echo ""
echo "============================================"
echo "  Pruebas completadas"
echo "============================================"