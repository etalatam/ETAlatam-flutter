# Análisis Técnico: Ubicación en Background para Android e iOS

## Resumen Ejecutivo

Este documento analiza el problema de actualización de ubicación en segundo plano en la aplicación ETA School Transport, específicamente cuando el dispositivo Android se bloquea o la app pasa a background. Se identifican las causas técnicas, se evalúa el plugin actual y se proponen soluciones robustas.

---

## 1. Estado Actual de la Implementación

### 1.1 Arquitectura de Ubicación

```
┌─────────────────────────────────────────────────────────────┐
│                      LocationService                        │
│  (Singleton - ChangeNotifier)                               │
├─────────────────────────────────────────────────────────────┤
│  ↓                                                          │
│  background_locator_2 (Plugin principal)                    │
│  ├── IsolateHolderService (Android Foreground Service)      │
│  ├── LocationCallbackHandler (Dart callbacks)               │
│  └── LocationServiceRepository (IPC via SendPort)           │
├─────────────────────────────────────────────────────────────┤
│  Dependencias adicionales:                                  │
│  - location: ^5.0.3 (permisos y servicio)                   │
│  - geolocator: ^10.1.0 (no utilizado activamente)           │
│  - workmanager: ^0.5.2 (comentado/deshabilitado)            │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Plugins de Ubicación en pubspec.yaml

| Plugin | Versión | Uso Actual |
|--------|---------|------------|
| `background_locator_2` | ^2.0.6 | **Principal** - Tracking en background |
| `location` | ^5.0.3 | Permisos y verificación de servicio |
| `geolocator` | ^10.1.0 | Disponible pero **no utilizado** |
| `workmanager` | ^0.5.2 | **Comentado/deshabilitado** |

### 1.3 Permisos Configurados

**Android (AndroidManifest.xml):**
- ✅ `ACCESS_FINE_LOCATION`
- ✅ `ACCESS_COARSE_LOCATION`
- ✅ `ACCESS_BACKGROUND_LOCATION`
- ✅ `FOREGROUND_SERVICE`
- ✅ `FOREGROUND_SERVICE_LOCATION`
- ✅ `WAKE_LOCK`
- ✅ `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
- ✅ `RECEIVE_BOOT_COMPLETED`

**iOS (Info.plist):**
- ✅ `NSLocationWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysAndWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysUsageDescription`
- ✅ `UIBackgroundModes: location, background-processing, remote-notification`

---

## 2. Diagnóstico del Problema

### 2.1 Causa Raíz Identificada

El problema principal es que **`background_locator_2` no es compatible con las restricciones de Android 14+ (API 34+) y Android 15/16**.


### 2.2 Restricciones de Android por Versión

| Android | API | Restricciones Relevantes |
|---------|-----|--------------------------|
| 10 | 29 | Permiso `ACCESS_BACKGROUND_LOCATION` separado |
| 12 | 31 | Restricciones de Foreground Service desde background |
| 13 | 33 | Permiso de notificaciones requerido |
| 14 | 34 | `ForegroundServiceStartNotAllowedException` estricto |
| 15 | 35 | Restricciones adicionales de batería |
| 16 | 36 | Políticas más agresivas de ahorro de energía (Samsung) |

### 2.3 Por qué Funciona en Xiaomi pero No en Samsung

| Aspecto | Xiaomi 11 Lite (Android 14) | Samsung A56 (Android 16) |
|---------|----------------------------|--------------------------|
| Política de batería | MIUI menos agresivo | One UI muy agresivo |
| App Sleeping | Configurable | Automático |
| Foreground Service | Permitido con restricciones | Bloqueado agresivamente |
| Doze Mode | Estándar | Extendido |

**Samsung One UI** implementa restricciones adicionales:
- **Adaptive Battery** más agresivo
- **App Power Monitor** que suspende apps
- **Deep Sleep** para apps no usadas
- **Background restrictions** automáticas

---

## 3. Análisis Crítico del Plugin Actual

### 3.1 Problemas con `background_locator_2`

| Problema | Impacto | Severidad |
|----------|---------|-----------|
| Última actualización: Dic 2022 | No soporta Android 14+ | 🔴 Crítico |
| Usa `IsolateHolderService` legacy | Incompatible con nuevas APIs | 🔴 Crítico |
| `stopWithTask="true"` en Manifest | Se detiene al cerrar app | 🟡 Alto |
| No implementa `WorkManager` correctamente | Sin recuperación automática | 🟡 Alto |
| Dependencia de `IsolateNameServer` | Comunicación frágil entre isolates | 🟠 Medio |

### 3.2 Configuración Problemática Actual

```xml
<!-- AndroidManifest.xml línea 58 -->
<service
    android:name="yukams.app.background_locator_2.IsolateHolderService"
    android:foregroundServiceType="location"
    android:stopWithTask="true"  <!-- ⚠️ PROBLEMA: debería ser false -->
    ...
```

### 3.3 Timer de Reinicio Inefectivo

```dart
// location_service.dart líneas 516-528
_timer = Timer.periodic(Duration(seconds: 5), (timer) {
  final difference = now.difference(_lastPositionDate!);
  final max = relationNameLocal.contains('eta.drivers') ? 20 : 30;
  if (difference.inSeconds >= max) {
    stopLocationService();
    startLocationService(calculateDistance: currentCalculateDistance);
  }
});
```

**Problema:** Si el servicio fue detenido por restricciones de Android 14+, reiniciarlo fallará de nuevo con el mismo error.

---

## 4. Causas Comunes de Detención de Ubicación en Background

### 4.1 Causas a Nivel de Sistema Operativo

1. **Doze Mode (Android 6+)**
   - Suspende actividad de red y CPU cuando el dispositivo está inactivo
   - Afecta a todas las apps excepto las whitelisted

2. **App Standby Buckets (Android 9+)**
   - Clasifica apps por uso: Active, Working Set, Frequent, Rare, Restricted
   - Apps en buckets bajos tienen acceso limitado a jobs y alarmas

3. **Background Execution Limits (Android 8+)**
   - Servicios en background se detienen después de ~1 minuto
   - Requiere Foreground Service con notificación visible

4. **Foreground Service Restrictions (Android 12+)**
   - No se puede iniciar Foreground Service desde background
   - Excepciones limitadas (geofencing, high-priority FCM)

5. **ForegroundServiceStartNotAllowedException (Android 14+)**
   - Lanzada cuando se intenta iniciar FGS sin cumplir requisitos
   - Requiere que la app esté en estado "visible" o tenga excepción

### 4.2 Causas a Nivel de Fabricante (OEM)

| Fabricante | Sistema | Comportamiento |
|------------|---------|----------------|
| Samsung | One UI | Adaptive Battery agresivo, App Sleeping |
| Xiaomi | MIUI | Battery Saver, AutoStart restrictions |
| Huawei | EMUI | PowerGenie mata apps agresivamente |
| Oppo/Vivo | ColorOS/FuntouchOS | Restricciones similares a Xiaomi |
| OnePlus | OxygenOS | Battery Optimization agresivo |

### 4.3 Causas a Nivel de Aplicación

1. **Plugin desactualizado** - No implementa APIs modernas
2. **Permisos incompletos** - Falta solicitar `ACCESS_BACKGROUND_LOCATION` correctamente
3. **Notificación no persistente** - Android puede matar el servicio
4. **No solicitar exclusión de batería** - App sujeta a optimizaciones
5. **`stopWithTask="true"`** - Servicio muere con la app

---

## 5. Solución Recomendada

### 5.1 Estrategia de Migración

```
┌─────────────────────────────────────────────────────────────┐
│              ARQUITECTURA PROPUESTA                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           flutter_foreground_task                    │   │
│  │  (Foreground Service moderno - Android 14+ ready)   │    │
│  └─────────────────────────────────────────────────────┘    │
│                          ↓                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   geolocator                        │    │
│  │  (Location stream - Cross-platform)                 │    │
│  └─────────────────────────────────────────────────────┘    │
│                          ↓                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              RobustLocationTracker                  │    │
│  │  (Wrapper con reintentos y manejo de errores)       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Plugins Recomendados

| Plugin | Versión | Propósito | Mantenimiento |
|--------|---------|-----------|---------------|
| `flutter_foreground_task` | ^8.10.0+ | Foreground Service moderno | ✅ Activo (2024) |
| `geolocator` | ^12.0.0+ | Location stream | ✅ Activo (2024) |
| `permission_handler` | ^11.3.1 | Permisos unificados | ✅ Activo |

### 5.3 Implementación Propuesta

#### Paso 1: Actualizar pubspec.yaml

```yaml
dependencies:
  # Remover o comentar:
  # background_locator_2: ^2.0.6  # DEPRECATED
  # workmanager: ^0.5.2  # No necesario
  
  # Agregar:
  flutter_foreground_task: ^8.10.0
  geolocator: ^12.0.0
  permission_handler: ^11.3.1
```

#### Paso 2: Actualizar AndroidManifest.xml

```xml
<!-- Reemplazar el servicio de background_locator_2 -->
<service
    android:name="com.pravera.flutter_foreground_task.service.ForegroundService"
    android:foregroundServiceType="location"
    android:stopWithTask="false"
    android:exported="false" />

<receiver 
    android:name="com.pravera.flutter_foreground_task.receiver.RebootBroadcastReceiver"
    android:enabled="true"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
    </intent-filter>
</receiver>
```

#### Paso 3: Crear RobustLocationTracker

```dart
// lib/shared/location/robust_location_tracker.dart
import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RobustLocationTracker {
  static final RobustLocationTracker _instance = RobustLocationTracker._();
  static RobustLocationTracker get instance => _instance;
  RobustLocationTracker._();

  StreamSubscription<Position>? _positionSubscription;
  Function(Position)? _onPositionUpdate;
  bool _isTracking = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  Future<bool> requestPermissions() async {
    // Solicitar permisos en orden
    var locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted) return false;

    // Background location (Android 10+)
    var backgroundStatus = await Permission.locationAlways.request();
    if (!backgroundStatus.isGranted) {
      print('[RobustLocationTracker] Background location denied - continuing with foreground only');
    }

    // Ignorar optimización de batería
    await Permission.ignoreBatteryOptimizations.request();

    return true;
  }

  Future<void> startTracking({
    required Function(Position) onPositionUpdate,
    int distanceFilter = 10,
  }) async {
    if (_isTracking) {
      print('[RobustLocationTracker] Already tracking');
      return;
    }

    _onPositionUpdate = onPositionUpdate;

    // Iniciar Foreground Service
    await _startForegroundService();

    // Iniciar stream de ubicación
    await _startLocationStream(distanceFilter);

    _isTracking = true;
    _retryCount = 0;
  }

  Future<void> _startForegroundService() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'eta_location_channel',
        channelName: 'Seguimiento de ubicación',
        channelDescription: 'Notificación para el seguimiento de ubicación en segundo plano',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    await FlutterForegroundTask.startService(
      notificationTitle: 'ETA - Seguimiento activo',
      notificationText: 'Compartiendo ubicación en tiempo real',
    );
  }

  Future<void> _startLocationStream(int distanceFilter) async {
    try {
      final locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'ETA - Ubicación activa',
          notificationText: 'Seguimiento en segundo plano',
          enableWakeLock: true,
        ),
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _retryCount = 0; // Reset en éxito
          _onPositionUpdate?.call(position);
        },
        onError: (error) {
          print('[RobustLocationTracker] Stream error: $error');
          _handleStreamError();
        },
      );
    } catch (e) {
      print('[RobustLocationTracker] Error starting stream: $e');
      _handleStreamError();
    }
  }

  void _handleStreamError() async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: 5 * _retryCount);
      print('[RobustLocationTracker] Retry $retryCount/$_maxRetries in ${delay.inSeconds}s');
      
      await Future.delayed(delay);
      await _positionSubscription?.cancel();
      await _startLocationStream(10);
    } else {
      print('[RobustLocationTracker] Max retries reached');
    }
  }

  Future<void> restartStream() async {
    await _positionSubscription?.cancel();
    _retryCount = 0;
    await _startLocationStream(10);
  }

  Future<void> stopTracking() async {
    _isTracking = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    await FlutterForegroundTask.stopService();
  }

  bool get isTracking => _isTracking;
}
```

---

## 6. Buenas Prácticas para Ubicación en Background

### 6.1 Android

1. **Usar Foreground Service con notificación visible**
   - Obligatorio desde Android 8 (Oreo)
   - La notificación debe ser informativa y no intrusiva

2. **Declarar `foregroundServiceType="location"`**
   - Obligatorio desde Android 10
   - Permite acceso a ubicación en Foreground Service

3. **Solicitar permisos en el momento correcto**
   ```dart
   // Primero: ubicación en uso
   await Permission.location.request();
   // Después (en contexto apropiado): ubicación siempre
   await Permission.locationAlways.request();
   ```

4. **Solicitar exclusión de optimización de batería**
   ```dart
   await Permission.ignoreBatteryOptimizations.request();
   ```

5. **Configurar `stopWithTask="false"`**
   - Permite que el servicio sobreviva al cierre de la app

6. **Implementar `BOOT_COMPLETED` receiver**
   - Reinicia el servicio después de reinicio del dispositivo

7. **Usar `WorkManager` como respaldo**
   - Para tareas periódicas que sobreviven restricciones

### 6.2 iOS

1. **Configurar `UIBackgroundModes`**
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>location</string>
   </array>
   ```

2. **Usar `allowsBackgroundLocationUpdates`**
   ```dart
   // En geolocator, esto se maneja automáticamente
   ```

3. **Proporcionar descripciones claras de uso**
   - `NSLocationAlwaysAndWhenInUseUsageDescription`
   - Explicar claramente por qué se necesita

4. **Usar `pausesLocationUpdatesAutomatically = false`**
   - Evita que iOS pause actualizaciones

5. **Considerar `showsBackgroundLocationIndicator`**
   - Muestra indicador azul en la barra de estado

### 6.3 Cross-Platform

1. **Implementar reintentos con backoff exponencial**
2. **Guardar estado en almacenamiento persistente**
3. **Monitorear salud del servicio con heartbeat**
4. **Proporcionar feedback visual al usuario**
5. **Permitir al usuario controlar el tracking**

---

## 7. Comparativa de Plugins de Ubicación

### 7.1 Tabla Comparativa

| Característica | background_locator_2 | flutter_foreground_task + geolocator | flutter_background_geolocation |
|----------------|---------------------|-------------------------------------|-------------------------------|
| Última actualización | Dic 2022 | 2024 | 2024 |
| Android 14+ | ❌ No | ✅ Sí | ✅ Sí |
| Android 15/16 | ❌ No | ✅ Sí | ✅ Sí |
| iOS support | ✅ Básico | ✅ Completo | ✅ Completo |
| Foreground Service | ✅ Legacy | ✅ Moderno | ✅ Moderno |
| Geofencing | ❌ No | ❌ No (separado) | ✅ Sí |
| Motion detection | ❌ No | ❌ No | ✅ Sí |
| Licencia | MIT | MIT | MIT (básico) / Comercial (pro) |
| Complejidad | Media | Media | Alta |
| Documentación | Básica | Buena | Excelente |

### 7.2 Recomendación

**Para este proyecto:** `flutter_foreground_task` + `geolocator`

**Razones:**
- Mantenimiento activo
- Compatibilidad con Android 14+
- Menor complejidad que alternativas comerciales
- Sin costo de licencia
- Suficiente para el caso de uso (tracking simple)

---

## 8. Monitoreo y Diagnóstico en Producción

### 8.1 Métricas a Monitorear

```dart
class LocationMetrics {
  int positionsSent = 0;
  int positionsFailed = 0;
  DateTime? lastSuccessfulPosition;
  int serviceRestarts = 0;
  List<String> errors = [];
  
  Map<String, dynamic> toJson() => {
    'positions_sent': positionsSent,
    'positions_failed': positionsFailed,
    'last_success': lastSuccessfulPosition?.toIso8601String(),
    'service_restarts': serviceRestarts,
    'error_count': errors.length,
  };
}
```

### 8.2 Logging Estructurado

```dart
void logLocationEvent(String event, Map<String, dynamic> data) {
  final logEntry = {
    'timestamp': DateTime.now().toIso8601String(),
    'event': event,
    'device': Platform.isAndroid ? 'android' : 'ios',
    'os_version': Platform.operatingSystemVersion,
    ...data,
  };
  // Enviar a sistema de analytics/logging
}
```

### 8.3 Health Check Periódico

```dart
Timer.periodic(Duration(minutes: 5), (timer) {
  final timeSinceLastPosition = DateTime.now()
      .difference(lastPositionTime ?? DateTime.now());
  
  if (timeSinceLastPosition.inMinutes > 10) {
    logLocationEvent('health_check_failed', {
      'minutes_since_last': timeSinceLastPosition.inMinutes,
    });
    // Intentar reiniciar servicio
    restartLocationService();
  }
});
```

### 8.4 Herramientas de Diagnóstico

1. **Firebase Crashlytics** - Captura errores y ANRs
2. **Firebase Analytics** - Eventos personalizados de ubicación
3. **Sentry** - Monitoreo de errores con contexto
4. **Custom Dashboard** - Métricas específicas de ubicación

---

## 9. Referencias y Recursos

### 9.1 Documentación Oficial

- [Android Background Location Limits](https://developer.android.com/develop/sensors-and-location/location/background)
- [Android Foreground Services](https://developer.android.com/develop/background-work/services/foreground-services)
- [Android 14 Foreground Service Changes](https://developer.android.com/about/versions/14/changes/fgs-types-required)
- [iOS Background Execution](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/about_the_background_execution_sequence)
- [Apple Location Best Practices](https://developer.apple.com/documentation/corelocation/getting_the_user_s_location)

### 9.2 Artículos Técnicos

- [Don't Kill My App!](https://dontkillmyapp.com/) - Guía de restricciones por fabricante
- [Android Background Location Access](https://developer.android.com/training/location/background)
- [Flutter Geolocator Documentation](https://pub.dev/packages/geolocator)
- [Flutter Foreground Task Documentation](https://pub.dev/packages/flutter_foreground_task)

### 9.3 Issues Relevantes

- [background_locator_2 Android 14 Issue](https://github.com/AliYar-Khan/background_locator_2/issues)
- [Geolocator Background Location](https://github.com/Baseflow/flutter-geolocator/wiki/Background-Location-Updates)

---

## 10. Plan de Implementación

### Fase 1: Preparación (1-2 días)
- [ ] Crear branch de desarrollo
- [ ] Agregar nuevas dependencias
- [ ] Crear `RobustLocationTracker`

### Fase 2: Migración (2-3 días)
- [ ] Actualizar `AndroidManifest.xml`
- [ ] Modificar `LocationService` para usar nuevo tracker
- [ ] Actualizar flujo de permisos

### Fase 3: Testing (2-3 días)
- [ ] Probar en dispositivos Android 14+
- [ ] Probar en Samsung con One UI
- [ ] Probar en iOS
- [ ] Verificar que no afecta flujo existente

### Fase 4: Monitoreo (Continuo)
- [ ] Implementar métricas
- [ ] Configurar alertas
- [ ] Documentar resultados

---

## 11. Conclusiones

### Problema Principal
El plugin `background_locator_2` está desactualizado y no es compatible con las restricciones de Android 14+ y las políticas agresivas de ahorro de batería de Samsung One UI.

### Solución Recomendada
Migrar a `flutter_foreground_task` + `geolocator`, que ofrecen:
- Compatibilidad con Android 14/15/16
- Mantenimiento activo
- Mejor manejo de Foreground Services
- Cross-platform consistente

### Impacto en iOS
El problema es **principalmente de Android**. iOS tiene un sistema más predecible para ubicación en background, y la configuración actual en `Info.plist` es correcta.

### Riesgo de No Actuar
Si no se migra, el problema empeorará con cada nueva versión de Android y cada actualización de One UI de Samsung, afectando a un porcentaje creciente de usuarios.

