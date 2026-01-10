# 🛠️ Herramientas de Automatización para Screenshots

Este documento lista herramientas para automatizar la captura y post-procesamiento de screenshots para App Store.

## 🤖 Solución Implementada

### ✅ Flutter Integration Test + Screenshots Automáticos

**Ubicación:** `integration_test/automated_screenshots_test.dart`

**Características:**
- ✅ Login automático (sin intervención manual)
- ✅ Navegación automatizada por la app
- ✅ Captura automática de screenshots
- ✅ Interacción con componentes (botones, campos, tabs)
- ✅ 100% code-based, reproducible

**Ejecución:**
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/automated_screenshots_test.dart \
  -d <device_id>
```

**Los screenshots se guardan en:** `build/app/outputs/`

---

## 🎨 Herramientas de Post-Procesamiento

### 1. AppScreens.com 🌐
**URL:** https://appscreens.com
**Tipo:** Herramienta web gratuita
**Características:**
- Diseño responsivo único se adapta a múltiples dispositivos
- Genera screenshots para iOS y Android simultáneamente
- Templates profesionales con overlays de texto
- Más de 3 millones de screenshots generados
- Ideal para desarrolladores independientes

**Flujo de trabajo:**
1. Captura screenshots básicos del app (con nuestro test automatizado)
2. Sube los screenshots a AppScreens.com
3. Añade textos, títulos y diseños
4. Descarga versiones optimizadas para todos los tamaños de dispositivo

**Limitaciones:**
- Requiere trabajo manual en el sitio web
- No se puede automatizar completamente

---

### 2. Fastlane Frameit 🚀
**Repositorio:** https://docs.fastlane.tools/actions/frameit/
**Tipo:** Herramienta CLI (Ruby)
**Características:**
- ✅ Añade marcos de dispositivos a screenshots
- ✅ Overlays de texto personalizables
- ✅ Completamente automatizable via script
- ✅ Soporta múltiples idiomas
- ✅ Integración con Fastlane para CI/CD

**Instalación:**
```bash
gem install fastlane
```

**Configuración:**
```bash
cd screenshots/ios
fastlane frameit setup
```

**Uso:**
```bash
# Añadir marcos a todos los screenshots
fastlane frameit

# Con configuración personalizada
fastlane frameit --config frameit.json
```

**Ejemplo de configuración (`Framefile.json`):**
```json
{
  "device_frame_version": "latest",
  "default": {
    "padding": 50,
    "background": "#F5F5F5",
    "title": {
      "font": "Helvetica",
      "color": "#000000",
      "font_size": 60
    }
  },
  "data": [
    {
      "filter": "login",
      "title": {
        "text": "Inicia Sesión Fácilmente"
      }
    },
    {
      "filter": "dashboard",
      "title": {
        "text": "Monitoreo en Tiempo Real"
      }
    }
  ]
}
```

---

### 3. Fastlane Snapshot 📸
**Repositorio:** https://docs.fastlane.tools/actions/snapshot/
**Tipo:** Herramienta CLI (Ruby) - iOS específico
**Características:**
- Captura screenshots automáticamente usando UI Tests
- Soporte para múltiples idiomas
- Integración con Fastlane
- Genera screenshots para todos los tamaños de iPhone/iPad

**Nota:** Requiere escribir UI Tests nativos en Swift/Objective-C

---

### 4. Screenly 💎
**URL:** https://www.screenly.io
**Tipo:** Servicio web premium
**Características:**
- Templates profesionales prediseñados
- Múltiples idiomas
- Localización automática
- Integración con CI/CD via API
- Pricing por proyecto

**Limitaciones:**
- Servicio de pago
- Dependencia de terceros

---

### 5. AppLaunchpad 🚀
**URL:** https://theapplaunchpad.com
**Tipo:** Servicio web
**Características:**
- Screenshots con marcos de dispositivos
- Backgrounds personalizados
- Texto overlay
- Export para múltiples tamaños

---

### 6. MockUPhone 📱
**URL:** https://mockuphone.com
**Tipo:** Herramienta web gratuita
**Características:**
- Marcos de dispositivos realistas
- Múltiples modelos de iPhone/Android
- Simple drag & drop
- Descarga PNG de alta resolución

**Limitaciones:**
- Un screenshot a la vez
- No hay automatización
- Sin overlays de texto

---

### 7. Figma/Sketch + Plugins 🎨
**Tipo:** Herramienta de diseño
**Características:**
- Control total del diseño
- Templates compartibles
- Plugins como "Mockup" o "Artboard Studio"
- Exportación batch

**Desventajas:**
- Requiere conocimiento de diseño
- Proceso más manual
- Software de pago (Sketch)

---

## 🎯 Recomendación para ETA School Bus

### Flujo Automatizado Completo:

```bash
#!/bin/bash
# Script de generación completa automatizada

# 1. Ejecutar tests E2E y capturar screenshots
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/automated_screenshots_test.dart \
  -d "23370193-8246-4A7D-B5B0-A5F17B39D349"

# 2. Copiar screenshots a carpeta de trabajo
mkdir -p screenshots/ios/raw
cp build/app/outputs/screenshots/*.png screenshots/ios/raw/

# 3. Post-procesar con Fastlane Frameit
cd screenshots/ios
fastlane frameit

# 4. Resultados listos en screenshots/ios/framed/
```

### Configuración Recomendada:

**Para automatización completa (CI/CD):**
1. ✅ Flutter Integration Test (captura)
2. ✅ Fastlane Frameit (marcos y overlay)
3. ✅ Script bash para orquestar ambos

**Para diseño más elaborado:**
1. ✅ Flutter Integration Test (captura)
2. ⚡ AppScreens.com (diseño manual una vez)
3. 📤 Subir a App Store Connect

---

## 📋 Checklist de Implementación

- [x] Test E2E automatizado creado
- [x] Driver de integration_test configurado
- [x] Credenciales de prueba documentadas
- [ ] Fastlane Frameit instalado
- [ ] Framefile.json configurado con textos
- [ ] Script de generación completo
- [ ] CI/CD pipeline configurado (opcional)

---

## 🚨 Notas Importantes

1. **Los screenshots deben ser reales** - No uses maquetas o diseños ficticios
2. **Apple requiere contenido real** - Usar datos de prueba realistas
3. **Consistencia de idioma** - Todos los screenshots en español
4. **Sin información sensible** - No mostrar datos de usuarios reales
5. **Máximo 10 screenshots** por tamaño de dispositivo

---

## 📚 Referencias

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Fastlane Screenshot Guide](https://docs.fastlane.tools/getting-started/ios/screenshots/)
- [Apple Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [AppScreens.com Tutorial](https://appscreens.com/docs)

---

**Última actualización:** 2026-01-08
**Estado:** Test automatizado en ejecución ✅
