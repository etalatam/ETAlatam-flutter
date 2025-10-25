#!/bin/bash
# Setup script para configurar el entorno Android con Java 8
# ETAlatam Flutter Project

echo "Configurando entorno Android para ETAlatam..."

# Configurar Java 8
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Configurar Android SDK
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

echo "Java version: $(java -version 2>&1 | head -n 1)"
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"

# Verificar herramientas disponibles
if command -v adb &> /dev/null; then
    echo "ADB disponible: $(adb version | head -n 1)"
else
    echo "ADB no encontrado"
fi

if command -v sdkmanager &> /dev/null; then
    echo "SDK Manager disponible"
else
    echo "SDK Manager no encontrado en PATH"
fi

echo ""
echo "Para usar este entorno, ejecuta: source setup_android_env.sh"
echo "Para construir la app: flutter build apk --debug"