#!/bin/bash

# Script de build para la aplicación ETA School App
# Este script debe ejecutarse cuando Flutter esté instalado en el sistema

echo "===================================="
echo "ETA School App - Script de Build"
echo "===================================="

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no está instalado o no está en el PATH"
    echo "Por favor, instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter encontrado: $(flutter --version | head -n 1)"

# Limpiar proyecto
echo ""
echo "🧹 Limpiando el proyecto..."
flutter clean

# Obtener dependencias
echo ""
echo "📦 Obteniendo dependencias..."
flutter pub get

# Analizar código
echo ""
echo "🔍 Analizando el código..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "⚠️  Advertencia: Se encontraron problemas en el análisis del código"
    read -p "¿Deseas continuar con el build? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Seleccionar plataforma de build
echo ""
echo "📱 Selecciona la plataforma de build:"
echo "1) Android (APK)"
echo "2) Android (Bundle)"
echo "3) iOS"
echo "4) Web"
echo "5) Todas las plataformas"
read -p "Opción: " platform

case $platform in
    1)
        echo ""
        echo "🤖 Construyendo APK para Android..."
        flutter build apk --release
        if [ $? -eq 0 ]; then
            echo "✅ APK construido exitosamente"
            echo "📍 Ubicación: build/app/outputs/flutter-apk/app-release.apk"
        else
            echo "❌ Error al construir el APK"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo "🤖 Construyendo App Bundle para Android..."
        flutter build appbundle --release
        if [ $? -eq 0 ]; then
            echo "✅ App Bundle construido exitosamente"
            echo "📍 Ubicación: build/app/outputs/bundle/release/app-release.aab"
        else
            echo "❌ Error al construir el App Bundle"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "🍎 Construyendo para iOS..."
        flutter build ios --release
        if [ $? -eq 0 ]; then
            echo "✅ Build de iOS completado exitosamente"
            echo "📍 Ubicación: build/ios/iphoneos/"
        else
            echo "❌ Error al construir para iOS"
            exit 1
        fi
        ;;
    4)
        echo ""
        echo "🌐 Construyendo para Web..."
        flutter build web --release
        if [ $? -eq 0 ]; then
            echo "✅ Build de Web completado exitosamente"
            echo "📍 Ubicación: build/web/"
        else
            echo "❌ Error al construir para Web"
            exit 1
        fi
        ;;
    5)
        echo ""
        echo "📱 Construyendo para todas las plataformas..."
        
        echo "🤖 Construyendo APK..."
        flutter build apk --release
        
        echo "🤖 Construyendo App Bundle..."
        flutter build appbundle --release
        
        echo "🌐 Construyendo Web..."
        flutter build web --release
        
        echo "✅ Builds completados"
        ;;
    *)
        echo "❌ Opción no válida"
        exit 1
        ;;
esac

echo ""
echo "===================================="
echo "✅ Proceso de build completado"
echo "===================================="