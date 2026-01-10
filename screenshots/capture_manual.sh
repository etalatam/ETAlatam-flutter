#!/bin/bash

DEVICE_ID="23370193-8246-4A7D-B5B0-A5F17B39D349"
OUTPUT_DIR="/Users/remote/workspace/eta/ETAlatam-flutter/screenshots/ios"

cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║   📸 CAPTURA MANUAL DE SCREENSHOTS PARA APP STORE         ║
║      ETA School Bus - iOS                                  ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

EOF

echo "📱 Simulador: iPhone 15 Pro"
echo "📁 Directorio: $OUTPUT_DIR"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Verificar que el simulador esté corriendo
if ! xcrun simctl list devices | grep -q "$DEVICE_ID.*Booted"; then
    echo "⚠️  El simulador no está corriendo"
    echo "Iniciando simulador..."
    xcrun simctl boot $DEVICE_ID
    sleep 5
    open -a Simulator
    sleep 3
fi

echo "✅ Simulador activo"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📋 INSTRUCCIONES:"
echo ""
echo "1. Abre el simulador (debe estar visible en pantalla)"
echo "2. Si no has iniciado sesión, usa estas credenciales:"
echo "   "
echo "   👤 Conductor:"
echo "      Email: conductor4@gmail.com"
echo "      Pass:  casa1234"
echo ""
echo "   👤 Representante:"
echo "      Email: etalatam+representante1@gmail.com"
echo "      Pass:  casa1234"
echo ""
echo "3. Navega a cada pantalla que quieras capturar"
echo "4. Presiona ENTER aquí para tomar el screenshot"
echo "5. Presiona Ctrl+C cuando termines"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Lista de pantallas sugeridas
declare -a screens=(
    "login:Pantalla de Login"
    "dashboard:Dashboard Principal"
    "map:Mapa con Bus en Tiempo Real"
    "routes:Lista de Rutas"
    "students:Lista de Estudiantes"
    "notifications:Notificaciones"
    "trip:Viaje Activo"
    "profile:Perfil de Usuario"
    "settings:Configuración"
    "history:Historial de Viajes"
)

counter=1
total=${#screens[@]}

for screen_info in "${screens[@]}"; do
    IFS=':' read -r screen_key screen_name <<< "$screen_info"

    echo "📸 Screenshot $counter/$total: $screen_name"
    echo "   Navega a esta pantalla en el simulador..."
    read -p "   Presiona ENTER cuando estés listo (o 's' para saltar): " response

    if [[ "$response" == "s" || "$response" == "S" ]]; then
        echo "   ⏭️  Saltado"
        echo ""
        continue
    fi

    filename="appstore_$(printf %02d $counter)_${screen_key}.png"

    xcrun simctl io $DEVICE_ID screenshot "$OUTPUT_DIR/$filename" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "   ✅ Guardado: $filename"
        size=$(ls -lh "$OUTPUT_DIR/$filename" | awk '{print $5}')
        echo "   📏 Tamaño: $size"
    else
        echo "   ❌ Error al capturar"
    fi

    echo ""
    counter=$((counter + 1))
done

echo "════════════════════════════════════════════════════════════"
echo ""
echo "✅ Captura completada!"
echo ""
echo "📊 Resumen de screenshots:"
ls -lh "$OUTPUT_DIR"/appstore_*.png 2>/dev/null | tail -10

echo ""
echo "🎯 Próximos pasos:"
echo "   1. Revisa los screenshots capturados"
echo "   2. Opcional: Añade marcos de dispositivo con 'fastlane frameit'"
echo "   3. Sube los screenshots a App Store Connect"
echo ""
echo "📝 Más información: screenshots/README_SCREENSHOTS.md"
echo ""
