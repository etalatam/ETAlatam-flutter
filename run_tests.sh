#!/bin/bash

# Script de ejecución de pruebas funcionales E2E
# ETAlatam Flutter App - Login Tests

echo "=========================================="
echo "   ETAlatam - Pruebas Funcionales E2E    "
echo "=========================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar dependencias
echo -e "${YELLOW}[1/5] Verificando dependencias...${NC}"
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: No se pudieron obtener las dependencias${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dependencias verificadas${NC}"

# Limpiar caché si es necesario
echo -e "${YELLOW}[2/5] Limpiando caché...${NC}"
flutter clean
flutter pub get
echo -e "${GREEN}✓ Caché limpiado${NC}"

# Verificar dispositivos disponibles
echo -e "${YELLOW}[3/5] Verificando dispositivos...${NC}"
flutter devices

# Preguntar al usuario qué tipo de prueba ejecutar
echo ""
echo "Seleccione el tipo de prueba a ejecutar:"
echo "1) Pruebas básicas de login (rápido)"
echo "2) Pruebas detalladas de login (completo)"
echo "3) Todas las pruebas"
echo "4) Ejecutar en modo headless (sin UI)"
read -p "Opción (1-4): " option

# Configurar el comando según la opción
case $option in
    1)
        TEST_FILE="integration_test/app_test.dart"
        TEST_NAME="Pruebas básicas de login"
        ;;
    2)
        TEST_FILE="integration_test/detailed_login_test.dart"
        TEST_NAME="Pruebas detalladas de login"
        ;;
    3)
        TEST_FILE="integration_test/"
        TEST_NAME="Todas las pruebas"
        ;;
    4)
        TEST_FILE="integration_test/"
        TEST_NAME="Pruebas en modo headless"
        HEADLESS=true
        ;;
    *)
        echo -e "${RED}Opción inválida${NC}"
        exit 1
        ;;
esac

# Ejecutar pruebas
echo ""
echo -e "${YELLOW}[4/5] Ejecutando: ${TEST_NAME}${NC}"
echo "Credenciales de prueba: etalatam+representante1@gmail.com / casa1234"
echo ""

# Crear directorio para resultados si no existe
mkdir -p test_results

# Ejecutar las pruebas con manejo de errores
if [ "$HEADLESS" = true ]; then
    # Modo headless para CI/CD
    flutter test $TEST_FILE --reporter expanded 2>&1 | tee test_results/test_output.log
else
    # Modo interactivo con dispositivo
    flutter test $TEST_FILE --reporter expanded 2>&1 | tee test_results/test_output.log
fi

TEST_RESULT=$?

# Analizar resultados
echo ""
echo -e "${YELLOW}[5/5] Analizando resultados...${NC}"

if [ $TEST_RESULT -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo -e "✓ TODAS LAS PRUEBAS PASARON EXITOSAMENTE"
    echo -e "==========================================${NC}"

    # Contar pruebas exitosas
    PASSED=$(grep -c "✓" test_results/test_output.log 2>/dev/null || echo "0")
    echo -e "${GREEN}Pruebas exitosas: $PASSED${NC}"
else
    echo -e "${RED}=========================================="
    echo -e "✗ ALGUNAS PRUEBAS FALLARON"
    echo -e "==========================================${NC}"

    # Mostrar resumen de errores
    echo -e "${RED}Errores encontrados:${NC}"
    grep -E "(Error|Failed|✗)" test_results/test_output.log | head -10

    echo ""
    echo -e "${YELLOW}Ver detalles completos en: test_results/test_output.log${NC}"
fi

# Generar reporte de tiempo
echo ""
echo "Generando reporte de rendimiento..."
echo "-----------------------------------"
grep -E "Tiempo de respuesta:|rendimiento" test_results/test_output.log 2>/dev/null || echo "No se encontraron métricas de rendimiento"

# Timestamp del reporte
echo ""
echo "Reporte generado: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Archivo de log: test_results/test_output.log"

# Preguntar si se quiere ejecutar pruebas manuales
echo ""
read -p "¿Desea ejecutar la aplicación para pruebas manuales? (s/n): " manual

if [ "$manual" = "s" ] || [ "$manual" = "S" ]; then
    echo -e "${YELLOW}Iniciando aplicación...${NC}"
    echo "Credenciales de prueba:"
    echo "  Email: etalatam+representante1@gmail.com"
    echo "  Contraseña: casa1234"
    flutter run
fi

exit $TEST_RESULT