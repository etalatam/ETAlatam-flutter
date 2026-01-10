# 📋 Plan de Implementación - Automatización de Screenshots

**Proyecto:** ETA School Bus
**Objetivo:** Automatizar captura de screenshots para App Store Connect
**Enfoque:** Fastlane Snapshot + Herramientas de Post-Procesamiento

---

## 🎯 Fase 1: Setup Inicial de Fastlane

### Tarea 1.1: Instalación de Fastlane
- [ ] Navegar a carpeta `ios/`
- [ ] Ejecutar `bundle init` si no existe Gemfile
- [ ] Agregar `gem 'fastlane'` al Gemfile
- [ ] Ejecutar `bundle install`
- [ ] Verificar instalación con `bundle exec fastlane --version`

### Tarea 1.2: Inicialización de Fastlane
- [ ] Ejecutar `bundle exec fastlane init` en carpeta ios/
- [ ] Seleccionar opción de "Manual setup"
- [ ] Verificar creación de carpeta `fastlane/`
- [ ] Verificar creación de archivos `Appfile` y `Fastfile`

### Tarea 1.3: Configuración de Dispositivos y Locales
- [ ] Crear archivo `ios/fastlane/Snapfile`
- [ ] Definir lista de dispositivos iOS (iPhone 15 Pro Max, iPhone 15 Pro, iPad Pro)
- [ ] Definir idiomas soportados (es-ES inicialmente)
- [ ] Configurar esquema de la app (`scheme: "Runner"`)
- [ ] Configurar workspace o project path

---

## 🧪 Fase 2: Creación de UI Tests para Screenshots

### Tarea 2.1: Setup del Target de UI Tests
- [ ] Abrir proyecto en Xcode (`ios/Runner.xcworkspace`)
- [ ] Crear nuevo UI Testing Target
  - File → New → Target → iOS UI Testing Bundle
  - Nombre: `RunnerUITests`
- [ ] Verificar que el target se agregó al esquema Runner
- [ ] Configurar Build Settings del target

### Tarea 2.2: Escribir Test de Login y Dashboard (Conductor)
- [ ] Crear archivo `ScreenshotsTestConductor.swift` en UI Tests
- [ ] Implementar setup del test (limpiar storage, permisos)
- [ ] Escribir navegación a pantalla de login
- [ ] Capturar screenshot #1: Pantalla de login
- [ ] Implementar ingreso de credenciales (conductor4@gmail.com)
- [ ] Capturar screenshot #2: Dashboard del conductor
- [ ] Implementar navegación a vista de ruta
- [ ] Capturar screenshot #3: Mapa con ruta activa
- [ ] Implementar navegación a lista de estudiantes
- [ ] Capturar screenshot #4: Lista de estudiantes
- [ ] Agregar llamadas a `snapshot("01Login")`, `snapshot("02Dashboard")`, etc.

### Tarea 2.3: Escribir Test de Vista de Representante
- [ ] Crear archivo `ScreenshotsTestGuardian.swift`
- [ ] Implementar login con credenciales de representante
- [ ] Capturar screenshot #5: Dashboard de representante
- [ ] Capturar screenshot #6: Seguimiento en tiempo real
- [ ] Capturar screenshot #7: Historial de viajes
- [ ] Capturar screenshot #8: Notificaciones

### Tarea 2.4: Configurar Esquema para UI Tests
- [ ] En Xcode, editar esquema Runner
- [ ] Agregar RunnerUITests al apartado "Test"
- [ ] Verificar que "Gather coverage data" está habilitado
- [ ] Guardar esquema compartido (shared scheme)

---

## ⚙️ Fase 3: Configuración de Fastlane Lanes

### Tarea 3.1: Crear Lane de Screenshots
- [ ] Abrir `ios/fastlane/Fastfile`
- [ ] Crear lane `screenshots` con configuración:
  - `clear_derived_data`
  - `snapshot`
  - Configurar parámetros (devices, languages, scheme)
- [ ] Probar ejecución: `bundle exec fastlane screenshots`

### Tarea 3.2: Configurar Limpieza de Status Bar
- [ ] En `Snapfile`, agregar `clear_previous_screenshots(true)`
- [ ] Configurar `override_status_bar(true)` para limpiar barra
- [ ] Definir hora fija: `override_status_bar_arguments("--time 9:41")`
- [ ] Configurar batería al 100%
- [ ] Verificar que carrier muestra correctamente

### Tarea 3.3: Organización de Output
- [ ] Configurar `output_directory` en Snapfile
- [ ] Crear estructura de carpetas: `screenshots/ios/raw/`
- [ ] Verificar que screenshots se guardan con nombres correctos
- [ ] Crear lane para copiar screenshots a carpeta final

---

## 🎨 Fase 4: Post-Procesamiento (Opcional)

### Opción A: Fastlane FrameIt

#### Tarea 4A.1: Setup de FrameIt
- [ ] Ejecutar `fastlane frameit setup` en carpeta ios/
- [ ] Descargar assets de marcos de dispositivos
- [ ] Crear carpeta `screenshots/frames/`

#### Tarea 4A.2: Configuración de Framefile
- [ ] Crear `ios/fastlane/Framefile.json`
- [ ] Definir configuración global (padding, background)
- [ ] Configurar títulos por screenshot:
  - 01Login: "Acceso Seguro y Rápido"
  - 02Dashboard: "Panel de Control en Tiempo Real"
  - 03Map: "Seguimiento de Rutas"
  - 04Students: "Gestión de Estudiantes"
  - etc.
- [ ] Configurar fuentes, tamaños y colores
- [ ] Probar generación: `fastlane frameit`

#### Tarea 4A.3: Integrar FrameIt en Lane
- [ ] Agregar `frameit` al final del lane `screenshots`
- [ ] Configurar path de screenshots
- [ ] Configurar output para versión con marcos

### Opción B: Previewed.app / AppLaunchpad

#### Tarea 4B.1: Cuenta y Setup
- [ ] Crear cuenta en Previewed.app o AppLaunchpad
- [ ] Familiarizarse con la interfaz
- [ ] Explorar templates disponibles

#### Tarea 4B.2: Diseño de Screenshots
- [ ] Subir screenshots crudos a la plataforma
- [ ] Seleccionar template profesional
- [ ] Personalizar textos descriptivos por pantalla
- [ ] Ajustar colores al branding de ETA
- [ ] Generar preview de todas las variantes

#### Tarea 4B.3: Export Final
- [ ] Descargar versiones para todos los tamaños de dispositivo
- [ ] Organizar en carpeta `screenshots/ios/final/`
- [ ] Verificar que cumplen con requisitos de App Store
  - Formato: PNG o JPEG
  - Resoluciones correctas
  - Sin contenido prohibido

---

## 🔄 Fase 5: Integración en CI/CD

### Tarea 5.1: Configurar GitHub Actions

#### Setup del Workflow
- [ ] Crear archivo `.github/workflows/screenshots.yml`
- [ ] Configurar trigger (manual con `workflow_dispatch`)
- [ ] Definir job con runner `macos-latest`

#### Pasos del Workflow
- [ ] Checkout del repositorio
- [ ] Setup de Flutter (versión 3.19.0)
- [ ] Instalación de dependencias: `flutter pub get`
- [ ] Pod install: `cd ios && pod install`
- [ ] Instalación de Fastlane: `bundle install`
- [ ] Ejecución de screenshots: `bundle exec fastlane screenshots`
- [ ] (Opcional) Ejecución de FrameIt
- [ ] Upload de artefactos con screenshots generados

### Tarea 5.2: Configurar Secrets
- [ ] Agregar `MATCH_PASSWORD` si se usa Fastlane Match
- [ ] Configurar acceso al repositorio de certificados
- [ ] Verificar permisos de GitHub Actions

### Tarea 5.3: Testing del Pipeline
- [ ] Ejecutar workflow manualmente
- [ ] Verificar logs de cada paso
- [ ] Descargar y revisar artefactos generados
- [ ] Validar que screenshots son correctos
- [ ] Documentar tiempo de ejecución del pipeline

---

## 📱 Fase 6: Generación para Múltiples Dispositivos

### Tarea 6.1: Configurar Tamaños Adicionales
- [ ] Agregar iPhone 14 Pro Max (6.7")
- [ ] Agregar iPhone SE (4.7") si es requerido
- [ ] Agregar iPad Pro 12.9" si hay versión iPad
- [ ] Actualizar `Snapfile` con nuevos devices

### Tarea 6.2: Localización (Fase Futura)
- [ ] Preparar strings localizables en la app
- [ ] Agregar locale "en-US" a Snapfile
- [ ] Crear UI Tests multiidioma
- [ ] Generar screenshots en inglés y español

---

## 🧪 Fase 7: Testing y Validación

### Tarea 7.1: Validación de Screenshots
- [ ] Verificar que todas las pantallas clave están capturadas
- [ ] Revisar que status bar está limpio
- [ ] Confirmar que no hay datos sensibles visibles
- [ ] Validar resoluciones y aspectos
- [ ] Verificar que textos están completos y legibles

### Tarea 7.2: Test en App Store Connect
- [ ] Subir screenshots de prueba a App Store Connect
- [ ] Verificar que se visualizan correctamente
- [ ] Confirmar cumplimiento de guidelines de Apple
- [ ] Solicitar feedback del equipo

### Tarea 7.3: Documentación del Proceso
- [ ] Crear README en `screenshots/` con instrucciones
- [ ] Documentar comando para ejecutar localmente
- [ ] Documentar proceso de CI/CD
- [ ] Crear troubleshooting guide

---

## 🔧 Fase 8: Mantenimiento y Mejoras

### Tarea 8.1: Script de Generación Local
- [ ] Crear script `generate_screenshots.sh`
- [ ] Agregar validación de prerrequisitos
- [ ] Incluir limpieza de screenshots anteriores
- [ ] Agregar logging de progreso

### Tarea 8.2: Optimizaciones
- [ ] Reducir tiempo de ejecución de UI Tests
- [ ] Implementar caché de builds en CI
- [ ] Paralelizar tests si es posible
- [ ] Configurar notificaciones de fallos

### Tarea 8.3: Expansión Futura
- [ ] Agregar screenshots para Google Play (Android)
- [ ] Crear variantes para diferentes campañas de marketing
- [ ] Implementar A/B testing de screenshots
- [ ] Integrar con herramientas de analytics

---

## 📊 Checklist de Completitud

### Requisitos Mínimos para Lanzamiento
- [ ] Al menos 3 screenshots de iPhone 15 Pro Max
- [ ] Al menos 3 screenshots de iPhone 6.7"
- [ ] Screenshots en español (locale es-ES)
- [ ] Sin información sensible visible
- [ ] Status bar limpio (9:41, 100% batería)
- [ ] Textos descriptivos añadidos (FrameIt o manual)

### Requisitos Deseables
- [ ] 6-10 screenshots por dispositivo
- [ ] Screenshots de iPad
- [ ] Versión en inglés (en-US)
- [ ] Diseño profesional con marcos/backgrounds
- [ ] Pipeline de CI/CD funcional
- [ ] Documentación completa

### Nice to Have
- [ ] Videos de demostración (App Previews)
- [ ] Screenshots para diferentes segmentos de usuarios
- [ ] Integración con herramientas de marketing
- [ ] Generación automática en cada release

---

## 🔗 Referencias Técnicas

### Comandos Útiles
```bash
# Ejecutar screenshots localmente
cd ios
bundle exec fastlane screenshots

# Ejecutar solo FrameIt
bundle exec fastlane frameit

# Limpiar simuladores antes de ejecutar
xcrun simctl shutdown all
xcrun simctl erase all

# Ver dispositivos disponibles
xcrun simctl list devices

# Ejecutar UI Tests manualmente en Xcode
# Product → Test (Cmd+U)
```

### Archivos Clave
- `ios/fastlane/Snapfile` - Configuración de dispositivos y locales
- `ios/fastlane/Fastfile` - Lanes de Fastlane
- `ios/fastlane/Framefile.json` - Configuración de marcos y textos
- `ios/RunnerUITests/*.swift` - UI Tests para capturas
- `.github/workflows/screenshots.yml` - Pipeline de CI/CD

### Links de Documentación
- [Fastlane Snapshot](https://docs.fastlane.tools/actions/snapshot/)
- [Fastlane FrameIt](https://docs.fastlane.tools/actions/frameit/)
- [Apple Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [Previewed.app Docs](https://previewed.app/docs)

---

**Última actualización:** 2026-01-08
**Estado:** Plan inicial - Pendiente de aprobación e inicio
