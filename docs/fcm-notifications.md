# Sistema de Notificaciones FCM - ETAlatam

## Descripción General

El sistema de notificaciones de ETAlatam utiliza Firebase Cloud Messaging (FCM) para enviar notificaciones push en tiempo real a diferentes tipos de usuarios (conductores, estudiantes y tutores). El sistema está basado en tópicos (topics) que permiten segmentar las notificaciones según el rol del usuario y el contexto específico.

## Arquitectura

### Servicio Principal
- **Clase**: `NotificationService`
- **Ubicación**: `lib/shared/fcm/notification_service.dart`
- **Patrón**: Singleton
- **Responsabilidades**:
  - Configuración inicial de Firebase Messaging
  - Gestión de suscripciones a tópicos
  - Manejo de mensajes en primer plano y segundo plano
  - Visualización de notificaciones mediante SnackBar animados

## Tópicos de Notificación

### 1. Tópico de Usuario Base
```
Formato: user-{userId}
```
- **Propósito**: Notificaciones personalizadas para cada usuario
- **Suscripción**: Automática al iniciar sesión
- **Ubicación**: `lib/shared/fcm/notification_service.dart:75`

### 2. Tópicos para Conductores

#### Tópico de Ruta del Conductor
```
Formato: route-{route_id}-driver
```
- **Propósito**: Notificaciones sobre rutas asignadas al conductor
- **Suscripción**: Al cargar las rutas del día
- **Ubicación**: `lib/Pages/driver_home.dart:295`
- **Casos de uso**:
  - Nuevos estudiantes asignados a la ruta
  - Cambios en la ruta
  - Alertas de emergencia

### 3. Tópicos para Estudiantes

#### Tópico de Ruta del Estudiante
```
Formato: route-{route_id}-student
```
- **Propósito**: Notificaciones generales de la ruta del estudiante
- **Ubicación**: `lib/Pages/students_home.dart:299`

#### Tópico de Punto de Recogida
```
Formato: route-{route_id}-pickup_point-{pickup_id}
```
- **Propósito**: Notificaciones específicas del punto de recogida
- **Ubicación**: `lib/Pages/students_home.dart:304`
- **Casos de uso**:
  - Bus acercándose al punto de recogida
  - Retrasos en el punto específico
  - Cambios de ubicación del punto

### 4. Tópicos para Tutores/Guardianes

#### Tópico de Ruta del Tutor
```
Formato: route-{route_id}-guardian
```
- **Propósito**: Notificaciones generales para tutores sobre la ruta
- **Ubicación**: `lib/Pages/guardians_home.dart:310`

#### Tópico de Estudiante Específico
```
Formato: route-{route_id}-student-{student_id}
```
- **Propósito**: Notificaciones sobre un estudiante específico bajo tutela
- **Ubicación**: `lib/Pages/guardians_home.dart:314`
- **Casos de uso**:
  - Estudiante abordó el bus
  - Estudiante llegó a la escuela
  - Estudiante descendió del bus

#### Tópico de Punto de Recogida (Tutor)
```
Formato: route-{route_id}-pickup_point-{pickup_id}
```
- **Propósito**: Notificaciones del punto de recogida de sus estudiantes
- **Ubicación**: `lib/Pages/guardians_home.dart:317`

### 5. Tópicos de Viaje Activo

#### Tópico de Viaje
```
Formato: trip-{trip_id}
```
- **Propósito**: Notificaciones en tiempo real durante un viaje activo
- **Ubicación**: `lib/Pages/trip_page.dart:764`
- **Casos de uso**:
  - Inicio del viaje
  - Paradas realizadas
  - Eventos durante el viaje
  - Finalización del viaje

## Flujo de Suscripción

### 1. Inicio de Sesión
```dart
// Al iniciar sesión, automáticamente se suscribe al tópico del usuario
messaging.subscribeToTopic("user-$userId");
```

### 2. Carga de Contexto por Rol

#### Conductor
```dart
// Se suscribe a todas las rutas del día
for (var route in todateRoutes) {
    var routeDriverTopic = "route-${route.route_id}-driver";
    NotificationService.instance.subscribeToTopic(routeDriverTopic);
}
```

#### Estudiante
```dart
// Se suscribe a sus rutas y puntos de recogida
for (var route in routes) {
    String routeTopic = "route-${route.route_id}-student";
    NotificationService.instance.subscribeToTopic(routeTopic);
    
    for (var pickupPoint in student.pickup_points) {
        var pickupPointTopic = "route-${route.route_id}-pickup_point-${pickupPoint.pickup_id}";
        NotificationService.instance.subscribeToTopic(pickupPointTopic);
    }
}
```

#### Tutor
```dart
// Se suscribe a las rutas de todos sus estudiantes
for (var route in routes) {
    var routeTopicGuardian = "route-${route.route_id}-guardian";
    NotificationService.instance.subscribeToTopic(routeTopicGuardian);
    
    for (var student in parentModel.students) {
        var topic = "route-${route.route_id}-student-${student.student_id}";
        NotificationService.instance.subscribeToTopic(topic);
    }
}
```

### 3. Durante un Viaje Activo
```dart
// Suscripción adicional al viaje específico
_notificationService.subscribeToTopic("trip-${trip.trip_id}");
```

## Gestión de Suscripciones

### Prevención de Duplicados
El servicio mantiene una lista interna (`topicsList`) para evitar suscripciones duplicadas:

```dart
if (!topicsList.contains(topic)) {
    topicsList.add(topic);
    messaging.subscribeToTopic(topic);
}
```

### Limpieza al Cerrar Sesión
Al cerrar sesión, se ejecuta el método `close()` que desuscribe de todos los tópicos:

```dart
for (var topic in topicsList) {
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}
```

## Manejo de Mensajes

### Mensajes en Primer Plano
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Procesa y muestra la notificación
    _handleIncomingMessage(LastMessage(message, 'foreground'));
});
```

### Mensajes en Segundo Plano
```dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

### Visualización de Notificaciones
Las notificaciones se muestran mediante un SnackBar animado personalizado:
- Duración: 5 segundos
- Estilo: Flotante con bordes redondeados
- Animación: Contenido animado personalizado

## Configuración Requerida

### 1. Permisos (iOS)
```dart
messaging.requestPermission();
```

### 2. Token FCM
```dart
messaging.getToken().then((token) {
    print("[FCM] Token: $token");
});
```

### 3. Archivos de Configuración
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

## Debugging y Monitoreo

### Logs de Suscripción
```dart
print("notificationService.subscribeToTopic: $topic");
```

### Logs de Mensajes
```dart
print('[FCM] Message data: ${message.data}');
print('[FCM] Notification: ${message.notification}');
```

### Logs de Desuscripción
```dart
print("unsubscribeFromTopic: $topic");
```

## Mejores Prácticas

1. **Segmentación por Rol**: Usar tópicos específicos para cada tipo de usuario
2. **Jerarquía de Tópicos**: Estructurar tópicos de lo general a lo específico
3. **Limpieza de Suscripciones**: Siempre desuscribir al cerrar sesión
4. **Prevención de Duplicados**: Verificar antes de suscribir
5. **Manejo de Errores**: Envolver suscripciones en try-catch
6. **Logs Apropiados**: Registrar suscripciones y mensajes para debugging

## Casos de Uso por Rol

### Conductor
- Recibe notificaciones de nuevos estudiantes en su ruta
- Alertas de cambios en la ruta
- Mensajes de emergencia de la administración

### Estudiante
- Notificación cuando el bus está cerca
- Alertas de retrasos
- Confirmación de abordaje

### Tutor
- Notificación cuando su hijo aborda el bus
- Alerta cuando llega a la escuela
- Notificación cuando desciende del bus
- Alertas de emergencia o retrasos

## Solución de Problemas

### Notificaciones no llegan
1. Verificar token FCM válido
2. Confirmar suscripción a tópicos correctos
3. Revisar permisos de notificación
4. Verificar configuración de Firebase

### Notificaciones duplicadas
1. Revisar múltiples suscripciones al mismo tópico
2. Verificar limpieza de suscripciones antiguas
3. Confirmar uso correcto del singleton

### Notificaciones en segundo plano no funcionan
1. Verificar handler de background configurado
2. Revisar permisos de la aplicación
3. Confirmar configuración específica de la plataforma