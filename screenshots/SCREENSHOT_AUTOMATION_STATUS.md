# 📸 Estado de Automatización de Screenshots - ETA School Bus

**Fecha:** 2026-01-08
**Objetivo:** Automatizar captura de screenshots para App Store Connect
**Requisito:** Proceso 100% automatizado, integrable en CI/CD

## 🔄 Enfoque Actual: Flutter Integration Tests

###  Progreso Realizado

#### ✅ Lo que Funciona
1. **Framework de pruebas configurado**
   - ✅ `integration_test` package agregado a `pubspec.yaml`
   - ✅ Driver creado en `test_driver/integration_test.dart`
   - ✅ Test automatizado en `integration_test/automated_screenshots_test.dart`
   - ✅ Storage service limpiado antes de cada test

2. **Mejoras en el código**
   - ✅ Keys agregados a widgets de login (`email_field`, `password_field`, `login_button`)
   - ✅ Fix de animaciones infinitas (`pump()` en lugar de `pumpAndSettle()`)
   - ✅ Modo de test agregado a `login_page.dart` (aún no funcional)

#### ❌ Bloqueador Actual

**Problema:** La página de login nunca muestra el formulario en el entorno de test

**Evidencia:**
```
flutter: ⏳ Esperando a que desaparezca el loader...
flutter: 🔍 Debug - Buscando TextFormField en iteración 5:
flutter:    Encontrados 0 TextFormField widgets
flutter:    Widgets con keys: 17
flutter:    CircularProgressIndicator: 0
flutter: 🔍 Debug - Buscando TextFormField en iteración 10:
flutter:    Encontrados 0 TextFormField widgets
flutter: ⚠️ Timeout esperando login page, continuando...
flutter: Expected: exactly one matching candidate
flutter:   Actual: _KeyWidgetFinder:<Found 0 widgets with key [<'email_field'>]: []>
```

**Causa Raíz:**
- La página de login tiene lógica compleja de inicialización:
  - Delay de 500ms antes de verificar sesión
  - Llamada async a `_cleanupResourcesIfNoSession()`
  - Navegación automática con `goHome()`
  - Estado `showLoader` que controla visibilidad del formulario

**Intentos de Solución:**
1. ❌ Esperar con `pumpAndSettle()` → Bloqueado por animaciones infinitas en Loader
2. ❌ Usar `pump()` con delays → Formulario nunca aparece
3. ❌ Agregar flag `INTEGRATION_TEST` → No se propaga correctamente en `flutter drive`

---

## 🎯 Recomendación: Cambiar a Fastlane Snapshot

### ¿Por qué Fastlane?

Según las mejores prácticas de la industria y la guía proporcionada:

1. **Estándar Industrial**
   - Usado por equipos profesionales de iOS/Flutter
   - Altamente confiable en CI/CD
   - Mantenimiento activo y documentación extensa

2. **Manejo Robusto de iOS**
   - Limpieza automática de status bar (batería, hora)
   - Soporte nativo para múltiples dispositivos y locales
   - Integración perfecta con Xcode y simuladores

3. **Automatización Completa**
   - Se ejecuta completamente vía comandos
   - Compatible con GitHub Actions, GitLab CI, Bitrise, Codemagic
   - Genera reportes HTML de las capturas

### Arquitectura Recomendada

```
┌─────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                      │
│                   (GitHub Actions)                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
           ┌─────────────────────┐
           │  Fastlane Snapshot  │ ← Captura técnica
           │  (iOS UI Tests)     │
           └─────────┬───────────┘
                     │
                     ▼
           📸 Screenshots Crudos
           (Status bar limpio,
            múltiples devices)
                     │
                     ▼
           ┌─────────────────────┐
           │   Post-Procesamiento │
           │   (Opcional)          │
           ├─────────────────────┤
           │ • Fastlane FrameIt  │ ← Marcos básicos
           │ • Previewed.app     │ ← Diseño profesional
           │ • AppLaunchpad      │ ← Marketing
           └─────────┬───────────┘
                     │
                     ▼
           📱 Screenshots Finales
           (Listos para App Store)
```

### Flujo de Implementación

#### Fase 1: Setup Básico (30 min)
```bash
cd ios
bundle init
# Agregar a Gemfile: gem 'fastlane'
bundle install
bundle exec fastlane init
```

#### Fase 2: Configurar Snapshot (1 hora)
1. Crear `Snapfile` con dispositivos y locales
2. Escribir UI Tests en Swift (navegación y capturas)
3. Crear lane en `Fastfile`

#### Fase 3: CI/CD (1 hora)
1. Configurar GitHub Actions con runner macOS
2. Ejecutar `bundle exec fastlane screenshots`
3. Subir artefactos

#### Fase 4: Post-Procesamiento (Opcional)
- **Opción A (Gratis):** FrameIt para marcos básicos
- **Opción B (Pro):** Previewed.app/AppLaunchpad para diseño avanzado

---

## 📊 Comparación de Enfoques

| Característica | Flutter Integration Test | Fastlane Snapshot |
|---|---|---|
| **Automatización completa** | ⚠️ Parcial (bloqueado) | ✅ Completa |
| **CI/CD friendly** | ✅ Sí | ✅ Sí |
| **Setup inicial** | Simple | Medio |
| **Mantenimiento** | Alto (bugs de framework) | Bajo (maduro) |
| **Control de UI nativa** | ❌ Limitado | ✅ Total |
| **Status bar limpio** | ❌ Manual | ✅ Automático |
| **Múltiples locales** | ⚠️ Complejo | ✅ Built-in |
| **Comunidad** | Pequeña (Flutter-only) | Grande (iOS general) |

---

## 🚀 Próximos Pasos Propuestos

### Opción A: Continuar con Flutter Tests
**Esfuerzo:** 4-8 horas
**Riesgo:** Alto (puede no resolverse)

1. Investigar por qué `--dart-define` no funciona con `flutter drive`
2. Modificar lógica de `login_page.dart` para detectar modo test en runtime
3. Posible refactor significativo de la inicialización

### Opción B: Implementar Fastlane Snapshot ⭐ **RECOMENDADO**
**Esfuerzo:** 2-3 horas
**Riesgo:** Bajo (solución probada)

1. Configurar Fastlane en `ios/`
2. Escribir 1-2 UI Tests simples en Swift
3. Crear lane para ejecutar tests y capturar screenshots
4. Integrar en GitHub Actions

### Opción C: Solución Híbrida
**Esfuerzo:** 1 hora
**Riesgo:** Muy bajo

1. Tomar screenshots manualmente (5-10 pantallas)
2. Usar Previewed.app o AppLaunchpad para diseño
3. Mantener flujo semi-automatizado hasta Phase 2

---

## 📝 Notas Técnicas

### Archivos Modificados
- `pubspec.yaml` - Agregado `integration_test`
- `test_driver/integration_test.dart` - Driver con soporte de screenshots
- `integration_test/automated_screenshots_test.dart` - Test E2E
- `lib/Pages/login_page.dart` - Keys y modo test (líneas 223, 340, 460, 708-720)

### Credenciales de Test
- **Conductor:** conductor4@gmail.com / casa1234
- **Representante:** etalatam+representante1@gmail.com / casa1234

### Device ID (iPhone 15 Pro)
```
23370193-8246-4A7D-B5B0-A5F17B39D349
```

---

## 🔗 Referencias

- [Fastlane Screenshot Guide](https://docs.fastlane.tools/getting-started/ios/screenshots/)
- [Previewed.app](https://previewed.app/) - Diseño profesional
- [AppLaunchpad](https://theapplaunchpad.com/) - Marketing
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

**Decisión Requerida:** ¿Proceder con Opción A (continuar debug) u Opción B (Fastlane)?

