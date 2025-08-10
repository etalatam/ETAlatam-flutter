# ETAlatam - Sistema de Seguimiento de Transporte Escolar

## Descripción General

ETAlatam es una aplicación Flutter multiplataforma (Android/iOS) que forma parte de un ecosistema integral de seguimiento de transporte escolar en tiempo real. La aplicación conecta a tres tipos de usuarios principales: **conductores**, **estudiantes** y **tutores/padres**, proporcionando visibilidad completa del proceso de transporte escolar.

### Características Principales

- **Seguimiento en Tiempo Real**: Localización GPS en vivo de los autobuses escolares
- **Notificaciones Push**: Sistema robusto de notificaciones basado en Firebase Cloud Messaging (FCM)
- **Comunicación Bidireccional**: Chat y mensajes entre conductores, estudiantes y padres
- **Gestión de Rutas**: Visualización y gestión de rutas escolares con puntos de recogida
- **Control de Asistencia**: Registro de abordaje y descenso de estudiantes
- **Alertas de Emergencia**: Sistema de mensajes de ayuda y emergencias
- **Multiidioma**: Soporte para múltiples idiomas

## Arquitectura de la Aplicación

### Estructura de Módulos

```
lib/
├── API/                    # Cliente HTTP y servicios de API
├── Models/                 # Modelos de datos
├── Pages/                  # Pantallas de la aplicación
│   ├── driver_home.dart   # Panel del conductor
│   ├── students_home.dart # Panel del estudiante
│   ├── guardians_home.dart# Panel de tutores
│   ├── trip_page.dart     # Seguimiento de viaje activo
│   └── map/               # Componentes de mapas
├── components/            # Widgets reutilizables
├── controllers/           # Lógica de negocio y helpers
├── domain/               # Capa de dominio (Clean Architecture)
├── infrastructure/       # Implementación de repositorios
└── shared/               # Servicios compartidos
    ├── fcm/             # Servicio de notificaciones
    ├── location/        # Servicio de ubicación
    └── emitterio/       # Cliente de mensajería en tiempo real
```

### Módulos Principales

#### 1. **Módulo de Autenticación**
- Login con email y contraseña
- Gestión de sesiones
- Recuperación de contraseña
- Almacenamiento seguro de tokens

#### 2. **Módulo de Conductores**
- Vista de rutas del día
- Inicio y fin de viajes
- Registro de estudiantes en cada parada
- Comunicación con la central

#### 3. **Módulo de Estudiantes**
- Visualización de la ubicación del bus
- Tiempo estimado de llegada
- Historial de viajes
- Botón de emergencia

#### 4. **Módulo de Tutores/Padres**
- Seguimiento de múltiples estudiantes
- Notificaciones de abordaje/descenso
- Historial de asistencia
- Comunicación con conductores

#### 5. **Módulo de Notificaciones FCM**
- Sistema basado en tópicos para segmentación
- Notificaciones en tiempo real
- Manejo en primer y segundo plano
- [Ver documentación completa](docs/fcm-notifications.md)

#### 6. **Módulo de Ubicación**
- Seguimiento GPS en segundo plano
- Actualización de posición en tiempo real
- Geofencing para puntos de recogida
- Optimización de batería

## Configuración del Proyecto

### Requisitos Previos

Antes de comenzar, asegúrate de cumplir con los siguientes requisitos:

- **Flutter SDK**: Debes tener instalado el SDK de Flutter. Puedes descargarlo desde [aquí](https://docs.flutter.dev/get-started/install).
  - **Versión de Flutter**: La versión de Flutter debe ser **exclusivamente la 3.19.0**
  - **Versión de Dart SDK**: La versión del SDK de Dart debe ser **exclusivamente la 3.2.0**
- **IDE compatible**: Necesitas un IDE compatible con Flutter, como Android Studio o Visual Studio Code
- **Dispositivo físico o emulador**: Puedes usar un dispositivo Android/iOS físico o un emulador para ejecutar la aplicación
- **Verificación del entorno**: Ejecuta el comando `flutter doctor` para verificar que tu entorno de desarrollo esté configurado correctamente
- **Firebase**: Proyecto configurado con FCM
- **Mapbox**: Token de acceso para mapas

### Instalación

1. **Clonar el repositorio**:
```bash
git clone https://github.com/etalatam/ETAlatam-flutter.git
cd ETAlatam-flutter
```

2. **Instalar dependencias**:
```bash
flutter pub get
```

3. **Configurar Firebase**:
   - Android: Colocar `google-services.json` en `android/app/`
   - iOS: Colocar `GoogleService-Info.plist` en `ios/Runner/`

4. **Configurar variables de entorno**:
   - Crear archivo `.env` con las credenciales necesarias
   - Configurar URL del servidor API
   - Agregar token de Mapbox

### Construcción de la Aplicación

#### Construcción para Android

1. **Abre tu proyecto en tu IDE** (Android Studio o Visual Studio Code)
2. **Selecciona la plataforma para la que deseas construir**:
   - **Android**:
     - En Android Studio, selecciona `Build > Build APK`
     - En Visual Studio Code, ejecuta el comando `flutter build apk`
3. **Espera a que la construcción finalice**
4. **Si la construcción es exitosa**, encontrarás el archivo APK en la carpeta `build/app/outputs`

Comandos disponibles:
```bash
# Desarrollo
flutter run

# Producción (APK)
flutter build apk --release

# Producción (App Bundle)
flutter build appbundle --release
```

#### Construcción para iOS

1. **Abre tu proyecto en Xcode**
2. **Selecciona el dispositivo o simulador** en el que deseas ejecutar la aplicación
3. **Ejecuta el comando `flutter build ios`** para construir la aplicación
4. **Espera a que la construcción finalice**
5. **Si la construcción es exitosa**, puedes ejecutar la aplicación en el simulador o en un dispositivo físico

Comandos disponibles:
```bash
# Desarrollo
flutter run

# Producción
flutter build ios --release
```

## Servicios y Configuración

### Firebase Cloud Messaging (FCM)

El sistema de notificaciones utiliza tópicos específicos para cada tipo de usuario:

- **Conductores**: `route-{route_id}-driver`
- **Estudiantes**: `route-{route_id}-student`, `route-{route_id}-pickup_point-{pickup_id}`
- **Tutores**: `route-{route_id}-guardian`, `route-{route_id}-student-{student_id}`

[📖 Ver documentación completa de notificaciones FCM](docs/fcm-notifications.md)

### Servicio de Ubicación

Configuración del servicio de ubicación en segundo plano:

```dart
// Configuración básica en location_service.dart
LocationService.instance.startLocationService();
```

### API REST

La aplicación se conecta a un backend REST API para:
- Autenticación de usuarios
- Gestión de rutas
- Sincronización de datos
- Registro de eventos

### Emitter.io

Sistema de mensajería en tiempo real para:
- Actualizaciones de posición del bus
- Chat entre usuarios
- Eventos del viaje

## Ejecución y Depuración

### Ejecutar la Aplicación

Puedes ejecutar la aplicación en un dispositivo físico o en un emulador utilizando el siguiente comando:

```bash
flutter run
```

### Depuración

- **Depuración en Android**: Conecta tu dispositivo Android y ejecuta `flutter run`. Asegúrate de que el dispositivo esté en modo de depuración
- **Depuración en iOS**: Conecta tu dispositivo iOS y ejecuta `flutter run`. Asegúrate de que el dispositivo esté configurado para desarrollo

### Solución de Problemas de Desarrollo

- **Problemas con Dart**: Si encuentras problemas relacionados con Dart, puedes usar el comando `dart fix` para encontrar y corregir problemas comunes
- **Linting**: Asegúrate de que tu código cumpla con las reglas de linting ejecutando `flutter analyze`

## Desarrollo

### Estructura de Código

```dart
// Ejemplo de pantalla típica
class StudentHomePage extends StatefulWidget {
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    _loadResources();
    _subscribeToNotifications();
  }
  
  // Implementación...
}
```

### Comandos Útiles

```bash
# Análisis de código
flutter analyze

# Ejecutar tests
flutter test

# Generar código
flutter pub run build_runner build

# Limpiar proyecto
flutter clean

# Corregir problemas comunes de Dart
dart fix
```

### Estado y Gestión de Datos

- **Provider**: Para gestión de estado global
- **Singleton Pattern**: Para servicios compartidos
- **Repository Pattern**: Para acceso a datos
- **Clean Architecture**: Separación de capas

## Testing

### Tests Unitarios
```bash
flutter test
```

### Tests de Integración
```bash
flutter test integration_test
```

## Problemas Comunes y Soluciones

- **Versión de Flutter/Dart**: Asegúrate de que estás utilizando **Flutter 3.19.0** y **Dart SDK 3.2.0**. Si no, puedes cambiar la versión ejecutando `flutter downgrade` o `flutter upgrade` según sea necesario
- **Dependencias no resueltas**: Si encuentras problemas con las dependencias, ejecuta `flutter pub get` nuevamente
- **Errores de Linting**: Si tu código no pasa el análisis de linting, revisa los mensajes de error y corrige los problemas indicados

### Solución de Problemas Específicos

1. **Versión de Flutter/Dart incorrecta**:
   ```bash
   flutter downgrade 3.19.0
   ```

2. **Dependencias no resueltas**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Problemas con Firebase**:
   - Verificar archivos de configuración
   - Revisar SHA1/SHA256 en Firebase Console

4. **Notificaciones no funcionan**:
   - Verificar permisos de la app
   - Revisar suscripción a tópicos
   - [Ver guía de solución de problemas FCM](docs/fcm-notifications.md#solución-de-problemas)

## Documentación Adicional

- [📱 Sistema de Notificaciones FCM](docs/fcm-notifications.md)
- [🗺️ Integración con Mapbox](docs/mapbox-integration.md) *(próximamente)*
- [🔐 Seguridad y Autenticación](docs/security.md) *(próximamente)*
- [📊 Gestión de Estado](docs/state-management.md) *(próximamente)*

## Ocultar Archivos Generados

### Android Studio
1. Navegar a `Preferences` -> `Editor` -> `File Types`
2. Agregar en `Ignore files and folders`:
```
*.inject.summary;*.inject.dart;*.g.dart;
```

### Visual Studio Code
1. Navegar a `Settings`
2. Buscar `Files:Exclude` y agregar:
```json
{
  "**/*.inject.summary": true,
  "**/*.inject.dart": true,
  "**/*.g.dart": true
}
```

## Consejos Adicionales

- **Emparejamiento de Dispositivos**: Puedes emparejar un dispositivo usando `adb pair ipaddr:port`, donde `ipaddr:port` se obtiene del menú que aparece después de hacer clic en `Developer options > Wireless debugging > Pair device with pairing code`. Más información en [Android Debug Bridge (adb)](https://developer.android.com/tools/adb)
- **Documentación Oficial**: Puedes encontrar más información sobre cómo construir aplicaciones Flutter en la [documentación oficial de Flutter](https://flutter.dev/)

## Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## Licencia

Este proyecto es propiedad de ETAlatam. Todos los derechos reservados.

## Contacto

Para soporte técnico o consultas sobre el proyecto, contactar al equipo de desarrollo de ETAlatam.

---

**Última actualización**: Enero 2025  
**Versión de la aplicación**: Ver `pubspec.yaml`