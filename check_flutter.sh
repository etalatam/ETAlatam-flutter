#!/bin/bash

echo "Verificando estado de Flutter..."

# Intentar ejecutar flutter version con timeout
if timeout 2 /home/rbruno/fvm/versions/3.19.0/bin/flutter --version &>/dev/null; then
    echo "✅ Flutter está listo!"
    echo ""
    /home/rbruno/fvm/versions/3.19.0/bin/flutter --version
    exit 0
else
    echo "⏳ Flutter aún se está descargando/configurando..."

    # Mostrar tamaño actual del directorio
    SIZE=$(du -sh /home/rbruno/fvm/versions/3.19.0/ 2>/dev/null | cut -f1)
    echo "   Tamaño actual del directorio: $SIZE"
    echo "   (El tamaño completo es aproximadamente 800MB-1GB)"

    # Ver si hay procesos activos
    if ps aux | grep -E "flutter|dart" | grep -v grep | grep -v check_flutter > /dev/null; then
        echo "   Proceso de descarga activo detectado"
    fi

    echo ""
    echo "Ejecuta este script nuevamente en unos momentos para verificar."
    exit 1
fi