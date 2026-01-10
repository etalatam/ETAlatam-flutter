# 📸 Guía de Screenshots para App Store

## Estado Actual

Se han capturado **9 screenshots** del simulador iPhone 15 Pro:
- Pantalla de login (múltiples capturas)
- Estados del app en diferentes momentos

**Ubicación:** `/Users/remote/workspace/eta/ETAlatam-flutter/screenshots/ios/`

## Screenshots Requeridos para App Store

Apple requiere screenshots de alta calidad que muestren las características principales del app:

### 1️⃣ Pantalla de Login ✅
- **Archivo:** `01_login_screen.png`
- **Estado:** Capturado
- **Descripción:** Pantalla de bienvenida con logo ETA y campos de login

### 2️⃣ Dashboard Principal (Pendiente)
- **Descripción:** Pantalla principal después de hacer login
- **Debe mostrar:** Rutas del día, botones de acción, menú de navegación

### 3️⃣ Mapa con Rastreo de Bus (Pendiente)
- **Descripción:** Vista del mapa mostrando ubicación del bus en tiempo real
- **Debe mostrar:** Marcadores, ruta, información del viaje

### 4️⃣ Lista de Rutas/Estudiantes (Pendiente)
- **Descripción:** Vista de rutas asignadas o lista de estudiantes
- **Debe mostrar:** Tarjetas con información de rutas/estudiantes

### 5️⃣ Vista de Notificaciones (Pendiente)
- **Descripción:** Pantalla de notificaciones o alertas
- **Debe mostrar:** Lista de notificaciones recientes

### 6️⃣ Perfil o Configuración (Opcional)
- **Descripción:** Pantalla de perfil de usuario o ajustes
- **Debe mostrar:** Información del usuario, opciones de configuración

## 🚀 Cómo Capturar Screenshots Manualmente

### Opción 1: Usando el Script Helper

```bash
# El app ya está corriendo en el simulador
# Ejecuta este comando en una terminal separada:

cd /Users/remote/workspace/eta/ETAlatam-flutter
bash screenshots/capture_manual.sh
```

Este script te guiará paso a paso:
1. Te pedirá que hagas login manualmente en el simulador
2. Navegarás por las diferentes pantallas
3. Presionarás ENTER en la terminal para capturar cada screenshot
4. Los screenshots se guardarán automáticamente con nombres descriptivos

### Opción 2: Captura Manual Directa

```bash
# 1. Navega a la pantalla deseada en el simulador
# 2. Ejecuta este comando para capturar:

xcrun simctl io 23370193-8246-4A7D-B5B0-A5F17B39D349 screenshot \
  "/Users/remote/workspace/eta/ETAlatam-flutter/screenshots/ios/nombre_descriptivo.png"
```

## 📋 Credenciales de Prueba

### Conductor
- **Email:** conductor4@gmail.com
- **Contraseña:** casa1234
- **Tipo de usuario:** Driver (Conductor)

### Representante/Guardian
- **Email:** etalatam+representante1@gmail.com
- **Contraseña:** casa1234
- **Tipo de usuario:** Guardian (Representante)

## 📏 Requisitos de Apple para Screenshots

### Tamaños Requeridos
- **iPhone 6.7"** (iPhone 15 Pro Max): 1290 x 2796 px
- **iPhone 6.5"** (iPhone 15 Pro): 1242 x 2688 px ✅ (actual)
- **iPhone 5.5"**: 1242 x 2208 px
- **iPad Pro 12.9"**: 2048 x 2732 px

### Mejores Prácticas
1. **Sin barra de estado** (ocultar hora, batería, señal)
2. **Contenido real** (no datos de prueba genéricos)
3. **Funcionalidades clave** destacadas
4. **Alta resolución** (sin pixelación)
5. **Idioma consistente** (español)
6. **Máximo 10 screenshots** por dispositivo

## 🎨 Post-Procesamiento (Opcional)

Puedes añadir marcos de dispositivo y texto descriptivo usando herramientas como:
- **Fastlane Frameit**: Añade marcos de iPhone automáticamente
- **Figma/Sketch**: Diseño profesional con overlays
- **App Store Screenshot Generator**: Online tools

### Usando Fastlane Frameit

```bash
# Instalar frameit
gem install fastlane

# Añadir marcos a los screenshots
fastlane frameit
```

## 📤 Subir Screenshots a App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Selecciona tu app **ETA School Bus** (ID: 6755067314)
3. Ve a la sección de **App Store**
4. Selecciona **Screenshots y vista previa de apps**
5. Arrastra y suelta los screenshots en el orden deseado
6. Añade subtítulos descriptivos para cada screenshot
7. Guarda los cambios

## 📝 Notas Adicionales

- Los screenshots actuales muestran principalmente la pantalla de login
- Se necesita completar el proceso de login para capturar pantallas internas
- El simulador iPhone 15 Pro está configurado y corriendo
- Device ID: `23370193-8246-4A7D-B5B0-A5F17B39D349`

## 🔧 Troubleshooting

### El simulador no responde
```bash
# Reiniciar el simulador
xcrun simctl shutdown 23370193-8246-4A7D-B5B0-A5F17B39D349
xcrun simctl boot 23370193-8246-4A7D-B5B0-A5F17B39D349
```

### El app no está corriendo
```bash
cd /Users/remote/workspace/eta/ETAlatam-flutter
flutter run -d 23370193-8246-4A7D-B5B0-A5F17B39D349
```

### Verificar screenshots capturados
```bash
ls -lh screenshots/ios/*.png
```

---

**Última actualización:** 2026-01-08
**Estado:** Screenshots de login completados, screenshots internos pendientes
