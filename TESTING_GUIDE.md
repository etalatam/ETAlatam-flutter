# Guía de Pruebas Funcionales - ETAlatam Flutter App

## Resumen de Cambios Realizados

### 1. Actualización de Versión
- **Versión actualizada**: 1.12.34 → 1.12.35
- **Archivo**: `pubspec.yaml`

### 2. Compilación Exitosa
- ✅ APK Debug compilado exitosamente
- **Ubicación**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Tiempo de compilación**: 72.3 segundos

### 3. Configuración de Pruebas E2E

Se han implementado pruebas funcionales end-to-end nativas de Flutter:

#### Archivos Creados:
1. **`integration_test/app_test.dart`** - Suite de pruebas básicas de login
2. **`integration_test/detailed_login_test.dart`** - Suite de pruebas detalladas con métricas
3. **`run_tests.sh`** - Script automatizado para ejecutar las pruebas

## Credenciales de Prueba

```
Email: etalatam+representante1@gmail.com
Contraseña: casa1234
```

## Casos de Prueba Implementados

### Suite Básica (`app_test.dart`)
- **TC001**: Login exitoso con usuario representante
- **TC002**: Login con credenciales incorrectas
- **TC003**: Validación de campos vacíos
- **TC004**: Navegación después de login exitoso
- **TC005**: Acceso a recuperación de contraseña

### Suite Detallada (`detailed_login_test.dart`)
- **TC001**: Login exitoso con validación de navegación
- **TC002**: Manejo de credenciales incorrectas
- **TC003**: Validación de campos requeridos
- **TC004**: Verificación de elementos UI
- **TC005**: Medición de tiempo de respuesta (métricas de rendimiento)

## Cómo Ejecutar las Pruebas

### Opción 1: Script Automatizado (Recomendado)
```bash
# Dar permisos de ejecución
chmod +x run_tests.sh

# Ejecutar el script
./run_tests.sh
```

El script ofrece las siguientes opciones:
1. Pruebas básicas de login (rápido)
2. Pruebas detalladas de login (completo)
3. Todas las pruebas
4. Modo headless (sin UI)

### Opción 2: Comandos Manuales

#### Ejecutar pruebas básicas:
```bash
flutter test integration_test/app_test.dart
```

#### Ejecutar pruebas detalladas:
```bash
flutter test integration_test/detailed_login_test.dart
```

#### Ejecutar todas las pruebas:
```bash
flutter test integration_test/
```

### Opción 3: Con Dispositivo Específico

#### En un emulador Android:
```bash
flutter test integration_test/detailed_login_test.dart -d emulator-5554
```

#### En Chrome (Web):
```bash
flutter test integration_test/app_test.dart -d chrome
```

## Métricas de Rendimiento

Las pruebas incluyen medición de tiempos de respuesta:
- **Excelente**: < 2 segundos
- **Bueno**: < 4 segundos
- **Mejorable**: > 4 segundos

## Resultados de las Pruebas

Los resultados se guardan automáticamente en:
- **Archivo de log**: `test_results/test_output.log`
- **Formato**: Incluye timestamps y métricas de rendimiento

## Verificación Manual de la Aplicación

### Instalar el APK en un dispositivo Android:
```bash
# Conectar dispositivo Android con USB debugging habilitado
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Ejecutar en modo desarrollo:
```bash
flutter run
```

## Frameworks de Pruebas Alternativos

Si deseas explorar otras opciones de pruebas E2E, considera:

### 1. **Maestro** (Recomendado para sintaxis simple)
- Instalación: https://maestro.mobile.dev/
- Ventajas: Sintaxis YAML simple, fácil de aprender

### 2. **Appium** (Para pruebas más complejas)
- Instalación: https://appium.io/
- Ventajas: Soporte multiplataforma, gran ecosistema

### 3. **Patrol** (Específico para Flutter)
- Instalación: https://patrol.leancode.co/
- Ventajas: Integración nativa con Flutter, soporte para pruebas nativas

## Estado Actual del Login

### Funcionalidades Verificadas:
- ✅ Compilación exitosa de la aplicación
- ✅ APK debug generado correctamente
- ✅ Pruebas E2E configuradas y listas para ejecutar
- ✅ Script de automatización creado

### Próximos Pasos Recomendados:
1. Ejecutar las pruebas en un dispositivo real o emulador
2. Verificar que el login funciona con las credenciales proporcionadas
3. Revisar los logs de las pruebas para identificar posibles problemas
4. Si hay errores, revisar los archivos de log en `test_results/`

## Solución de Problemas

### Error: "No devices found"
```bash
# Verificar dispositivos disponibles
flutter devices

# Iniciar un emulador Android
flutter emulators --launch <emulator_id>
```

### Error: "Test timeout"
- Aumentar el timeout en las pruebas
- Verificar la conectividad con el servidor API
- Revisar que las credenciales sean correctas

### Error: "Widget not found"
- Verificar que los selectores de widgets coincidan con la UI actual
- Usar `flutter inspector` para identificar los widgets correctos

## Notas Importantes

1. **Versión de Flutter**: La aplicación requiere Flutter 3.19.0
2. **Dependencias**: Se mantuvieron las versiones originales para evitar conflictos
3. **Pruebas Web**: Hay problemas con la compilación web debido a los IDs de Isar, se recomienda usar Android/iOS

## Contacto y Soporte

Para reportar problemas o mejoras en las pruebas:
1. Revisar los logs en `test_results/test_output.log`
2. Ejecutar las pruebas con el flag `--verbose` para más detalles
3. Verificar la conectividad con el servidor API: https://api.etalatam.com

---

**Última actualización**: 27 de Octubre de 2025
**Versión de la app**: 1.12.35