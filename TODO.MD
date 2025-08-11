# Lista de Tareas Pendientes - ETAlatam Flutter

## 🚨 Prioridad Alta

### 1. 📍 Revisar reporte de posición del estudiante
**Descripción**: Verificar y corregir el sistema de reporte de ubicación de estudiantes  
**Módulo**: Location Service / Student Tracking  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Verificar la precisión del GPS
- Revisar frecuencia de actualización
- Validar envío de coordenadas al servidor

### 2. 📏 Revisar cálculo de distancias
**Descripción**: Corregir el algoritmo de cálculo de distancias en rutas  
**Módulo**: Location Service / Utils  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Revisar implementación de la fórmula Haversine
- Verificar acumulación de distancia en viajes
- Validar unidades (metros/kilómetros)

### 3. 🗺️ Perfil del conductor - Problemas de mapa
**Descripción**: El mapa pierde el centrado y no permite desplazamiento manual del usuario  
**Módulo**: Driver Home / Trip Page  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Revisar controles de cámara en Mapbox
- Implementar modo de seguimiento vs modo libre
- Permitir interacción del usuario con el mapa

## 🔧 Prioridad Media

### 4. 🔄 Actualización de posición del conductor
**Descripción**: Cambiar la actualización de posición del conductor para que sea como la del representante (actualizar cuando llega nueva posición)  
**Módulo**: Trip Page / Emitter Service  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Sincronizar con eventos de Emitter
- Actualizar solo cuando hay cambios de posición
- Evitar actualizaciones innecesarias del mapa

### 5. 🏷️ Duplicación de etiquetas en icono del bus
**Descripción**: Se duplican las etiquetas de hora en el marcador del bus en el mapa  
**Módulo**: Trip Page / Map Annotations  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Revisar método `_updateIcon` en trip_page.dart
- Limpiar anotaciones anteriores antes de crear nuevas
- Implementar verificación de anotaciones existentes

## 🐛 Bugs

### 6. 🔐 Recuperación de contraseña no funciona
**Descripción**: El botón/link para solicitar recuperación de contraseña no responde  
**Módulo**: Login Page / Auth Service  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Verificar endpoint de API
- Revisar validación de email
- Implementar feedback visual al usuario

### 7. 🌙 Revisar modo oscuro
**Descripción**: Problemas de visualización con el tema oscuro  
**Módulo**: Theme / UI Components  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Revisar contraste de colores
- Verificar visibilidad de textos
- Actualizar componentes que no respetan el tema

### 8. 🔔 Revisar opciones de notificaciones
**Descripción**: Verificar funcionamiento de configuración de notificaciones  
**Módulo**: Settings / FCM Service  
**Estado**: ⏳ Pendiente  
**Asignado a**: Robert Bruno  
**Detalles técnicos**:
- Revisar permisos de notificaciones
- Verificar suscripción/desuscripción a tópicos
- Implementar persistencia de preferencias

## 📋 Tareas Adicionales Identificadas

### 9. 🔄 Optimización de rendimiento en mapas
**Descripción**: Mejorar el rendimiento del mapa con múltiples marcadores  
**Módulo**: Map Components  
**Estado**: 📝 Por definir  
**Prioridad**: Media

### 10. 💾 Manejo de estado offline
**Descripción**: Implementar caché local para funcionamiento sin conexión  
**Módulo**: Local Storage / API Client  
**Estado**: 📝 Por definir  
**Prioridad**: Baja

### 11. 🧪 Pruebas unitarias
**Descripción**: Agregar tests para funcionalidades críticas  
**Módulo**: Todo el proyecto  
**Estado**: 📝 Por definir  
**Prioridad**: Media

## 📊 Resumen de Estado

| Estado | Cantidad | Porcentaje |
|--------|----------|------------|
| ⏳ Pendiente | 8 | 73% |
| 🚧 En progreso | 0 | 0% |
| ✅ Completado | 0 | 0% |
| 📝 Por definir | 3 | 27% |

## 🎯 Orden de Implementación Sugerido

1. **Fase 1 - Crítico** (Semana 1)
   - Tarea #6: Recuperación de contraseña
   - Tarea #1: Reporte de posición del estudiante
   - Tarea #2: Cálculo de distancias

2. **Fase 2 - Experiencia de Usuario** (Semana 2)
   - Tarea #3: Problemas del mapa del conductor
   - Tarea #5: Duplicación de etiquetas
   - Tarea #4: Actualización de posición

3. **Fase 3 - Mejoras** (Semana 3)
   - Tarea #7: Modo oscuro
   - Tarea #8: Opciones de notificaciones
   - Tarea #9: Optimización de rendimiento

## 🛠️ Notas Técnicas

- **Rama de trabajo**: `tareas-pendientes`
- **Convención de commits**: `fix: [#numero] descripción breve`
- **Pull Request**: Crear PR individual por cada tarea completada
- **Testing**: Probar en dispositivos Android e iOS antes de marcar como completado

---

*Última actualización: Enero 2025*  
*Responsable: Robert Bruno*