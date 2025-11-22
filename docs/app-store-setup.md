# Configuración de App Store Connect para ETA School Transport

Esta guía te ayudará a configurar y subir tu aplicación iOS a App Store Connect.

## 📋 Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Configuración Inicial](#configuración-inicial)
3. [Obtener Credenciales](#obtener-credenciales)
4. [Instalación de Herramientas](#instalación-de-herramientas)
5. [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
6. [Uso de Fastlane](#uso-de-fastlane)
7. [Comandos Disponibles](#comandos-disponibles)
8. [Solución de Problemas](#solución-de-problemas)

---

## 🔑 Requisitos Previos

Antes de comenzar, asegúrate de tener:

- ✅ **Cuenta de Apple Developer** activa ($99 USD/año)
- ✅ **macOS** con Xcode instalado (versión 13.0 o superior)
- ✅ **Flutter 3.19.0** instalado
- ✅ **Ruby** instalado (viene preinstalado en macOS)
- ✅ Acceso a **App Store Connect** con permisos de administrador
- ✅ Tu aplicación debe estar registrada en App Store Connect

---

## 🚀 Configuración Inicial

### 1. Registrar la Aplicación en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Inicia sesión con tu Apple ID
3. Haz clic en **"My Apps"** (Mis Apps)
4. Haz clic en el botón **"+"** y selecciona **"New App"** (Nueva App)
5. Completa la información:
   - **Platform**: iOS
   - **Name**: ETA School Transport
   - **Primary Language**: Spanish (Spain) - Español
   - **Bundle ID**: Selecciona `com.etalatam.schoolapp`
   - **SKU**: Un identificador único (ej: `eta-school-transport-001`)
   - **User Access**: Full Access

### 2. Configurar Información Básica

En App Store Connect, ve a la sección de tu app y configura:

- **Category**: Education (Educación)
- **Secondary Category** (opcional): Utilities (Utilidades)
- **Content Rights**: Selecciona si contiene contenido de terceros
- **Age Rating**: Completa el cuestionario (generalmente será 4+)

---

## 🔐 Obtener Credenciales

### Paso 1: Obtener tu Team ID

**Opción A - Desde Apple Developer:**
1. Ve a: https://developer.apple.com/account
2. Inicia sesión
3. En la sección **"Membership"**, encontrarás tu **Team ID** (10 caracteres)

**Opción B - Desde App Store Connect:**
1. Ve a: https://appstoreconnect.apple.com
2. **Users and Access** > **Keys**
3. El Team ID aparece en la parte superior

### Paso 2: Obtener API Key de App Store Connect

Ya tienes el archivo `AuthKey_2A6UCBGW5Z.p8` en tu proyecto. Ahora necesitas el **Issuer ID**:

1. Ve a: https://appstoreconnect.apple.com
2. Ve a **Users and Access** (Usuarios y Acceso)
3. Selecciona la pestaña **Keys** (Claves)
4. Copia el **Issuer ID** (formato UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

**Información de tu API Key:**
- **Key ID**: `2A6UCBGW5Z` ✅ (ya tienes el archivo)
- **Key File**: `AuthKey_2A6UCBGW5Z.p8` ✅
- **Issuer ID**: ⏳ (debes obtenerlo del paso anterior)

---

## 🛠️ Instalación de Herramientas

### 1. Instalar Bundler y Fastlane

Desde el directorio del proyecto:

```bash
# Instalar Bundler
sudo gem install bundler

# Navegar al directorio iOS
cd ios

# Instalar dependencias (Fastlane y CocoaPods)
bundle install

# Verificar instalación de Fastlane
bundle exec fastlane --version
```

### 2. Instalar Dependencias de CocoaPods

```bash
# Desde el directorio ios/
pod install
```

---

## ⚙️ Configuración de Variables de Entorno

### 1. Crear archivo de configuración

Desde la raíz del proyecto:

```bash
# Copiar el archivo de ejemplo
cp .env.appstore.example .env.appstore
```

### 2. Editar `.env.appstore`

Abre el archivo `.env.appstore` y completa con tus datos:

```bash
# Your Apple ID email
APPLE_ID=tu-email@ejemplo.com

# Your Team ID (10 caracteres que obtuviste anteriormente)
TEAM_ID=ABC1234567

# iTunes Connect Team ID (normalmente es el mismo que TEAM_ID)
ITC_TEAM_ID=ABC1234567

# App Store Connect API Key ID (ya configurado)
APP_STORE_CONNECT_API_KEY_ID=2A6UCBGW5Z

# Issuer ID (UUID que obtuviste de App Store Connect)
APP_STORE_CONNECT_API_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Ruta al archivo .p8 (ya está configurada)
APP_STORE_CONNECT_API_KEY_PATH=../AuthKey_2A6UCBGW5Z.p8
```

### 3. Cargar variables de entorno

```bash
# Desde el directorio ios/
export $(cat ../.env.appstore | xargs)
```

O agrega esto a tu `~/.zshrc` o `~/.bash_profile`:

```bash
# Cargar automáticamente variables de App Store
if [ -f ~/workspace/eta/ETAlatam-flutter/.env.appstore ]; then
    export $(cat ~/workspace/eta/ETAlatam-flutter/.env.appstore | xargs)
fi
```

---

## 🚀 Uso de Fastlane

### Información de la App

Ver información actual de la aplicación:

```bash
cd ios
bundle exec fastlane app_info
```

### Subir Solo Metadatos

Para subir las descripciones en español e inglés sin subir un build:

```bash
cd ios
bundle exec fastlane upload_metadata
```

Esto subirá:
- ✅ Nombre de la app
- ✅ Subtítulo
- ✅ Descripción (español e inglés)
- ✅ Palabras clave
- ✅ URLs (marketing, soporte, privacidad)
- ✅ Notas de la versión

### Subir Screenshots

Primero, coloca tus screenshots en las carpetas correspondientes:

```
ios/fastlane/screenshots/
├── es-ES/
│   ├── iPhone 6.5 inch/     # iPhone 14 Pro Max, 15 Pro Max
│   ├── iPhone 5.5 inch/     # iPhone 8 Plus
│   └── iPad Pro (12.9 inch)/
└── en-US/
    ├── iPhone 6.5 inch/
    ├── iPhone 5.5 inch/
    └── iPad Pro (12.9 inch)/
```

Luego ejecuta:

```bash
cd ios
bundle exec fastlane upload_screenshots
```

### Construir y Subir a TestFlight

Para enviar una versión beta a TestFlight:

```bash
cd ios
bundle exec fastlane upload_testflight
```

### Construir y Subir a App Store

Para enviar a revisión en App Store:

```bash
cd ios
bundle exec fastlane upload_appstore
```

### Proceso Completo de Release

Para hacer todo en un solo comando (build + metadata + upload):

```bash
cd ios
bundle exec fastlane release
```

Para enviar directamente a revisión:

```bash
cd ios
bundle exec fastlane release submit_for_review:true
```

---

## 📝 Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `fastlane app_info` | Ver información de la app (versión, build, bundle ID) |
| `fastlane build` | Construir la app iOS con Flutter |
| `fastlane build_archive` | Crear archivo IPA para distribución |
| `fastlane upload_metadata` | Subir solo metadatos (descripciones, URLs, etc.) |
| `fastlane upload_screenshots` | Subir solo capturas de pantalla |
| `fastlane upload_testflight` | Construir y subir a TestFlight |
| `fastlane upload_appstore` | Construir y subir a App Store |
| `fastlane release` | Proceso completo: build + metadata + upload |
| `fastlane increment_build` | Incrementar número de build |
| `fastlane increment_version type:patch` | Incrementar versión (patch/minor/major) |

### Gestión de Versiones

```bash
# Incrementar versión patch (1.12.38 → 1.12.39)
bundle exec fastlane increment_version type:patch

# Incrementar versión minor (1.12.38 → 1.13.0)
bundle exec fastlane increment_version type:minor

# Incrementar versión major (1.12.38 → 2.0.0)
bundle exec fastlane increment_version type:major

# Solo incrementar build number (38 → 39)
bundle exec fastlane increment_build
```

---

## 🔍 Solución de Problemas

### Error: "No API token found"

**Problema**: Fastlane no encuentra tus credenciales de API.

**Solución**:
```bash
# Verifica que las variables estén cargadas
echo $APP_STORE_CONNECT_API_KEY_ID
echo $APP_STORE_CONNECT_API_ISSUER_ID

# Si están vacías, carga el archivo .env.appstore
export $(cat .env.appstore | xargs)
```

### Error: "Could not find provisionating profile"

**Problema**: No tienes perfiles de aprovisionamiento configurados.

**Solución**:
1. Ve a Xcode
2. Selecciona el proyecto Runner
3. Ve a **Signing & Capabilities**
4. Marca **"Automatically manage signing"**
5. Selecciona tu Team

### Error: "Build failed"

**Problema**: Flutter no compiló correctamente.

**Solución**:
```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

### Error: "Invalid bundle identifier"

**Problema**: El Bundle ID no coincide.

**Solución**:
1. Verifica en `ios/Runner.xcodeproj/project.pbxproj` que `PRODUCT_BUNDLE_IDENTIFIER = com.etalatam.schoolapp;`
2. Verifica en App Store Connect que el Bundle ID sea exactamente `com.etalatam.schoolapp`

### Error: "Version already exists"

**Problema**: Ya existe una versión con ese número.

**Solución**:
```bash
# Incrementar versión o build
cd ios
bundle exec fastlane increment_version type:patch
# O solo el build
bundle exec fastlane increment_build
```

### Screenshots no aparecen en App Store Connect

**Solución**:
- Verifica que los screenshots estén en el tamaño correcto:
  - iPhone 6.5": 1242 x 2688 px o 1284 x 2778 px
  - iPhone 5.5": 1242 x 2208 px
  - iPad Pro 12.9": 2048 x 2732 px
- Los archivos deben ser PNG o JPG
- Nombra los archivos en orden: `01_screenshot.png`, `02_screenshot.png`, etc.

---

## 📱 Información de Metadatos Configurados

### Idiomas Soportados
- ✅ **Español (España)** - es-ES (idioma principal)
- ✅ **English (US)** - en-US

### Archivos de Metadatos Creados

```
ios/fastlane/metadata/
├── es-ES/
│   ├── name.txt              # ETA School Transport
│   ├── subtitle.txt          # Seguimiento de Transporte Escolar
│   ├── description.txt       # Descripción completa en español
│   ├── keywords.txt          # Palabras clave para búsqueda
│   ├── marketing_url.txt     # URL de marketing
│   ├── support_url.txt       # URL de soporte
│   ├── privacy_url.txt       # URL de política de privacidad
│   └── release_notes.txt     # Notas de la versión
└── en-US/
    ├── name.txt              # ETA School Transport
    ├── subtitle.txt          # School Bus Tracking System
    ├── description.txt       # Full description in English
    ├── keywords.txt          # Search keywords
    ├── marketing_url.txt     # Marketing URL
    ├── support_url.txt       # Support URL
    ├── privacy_url.txt       # Privacy policy URL
    └── release_notes.txt     # Version release notes
```

### Configuración Actual

- **Bundle ID**: `com.etalatam.schoolapp`
- **Nombre**: ETA School Transport
- **Versión**: 1.12.38
- **Build**: 38
- **Categoría sugerida**: Education
- **Clasificación por edad**: 4+

---

## 🔐 Seguridad

### ⚠️ IMPORTANTE: Archivos que NUNCA debes commitear a Git

Los siguientes archivos ya están protegidos en `.gitignore`:

- ✅ `.env.appstore` - Contiene tus credenciales
- ✅ `*.p8` - Claves de API privadas
- ✅ `AuthKey_*.p8` - Tu clave de autenticación
- ✅ `*.cer`, `*.p12` - Certificados
- ✅ `*.mobileprovision` - Perfiles de aprovisionamiento

### Verificar antes de hacer commit

```bash
# Asegúrate de que estos archivos NO aparezcan
git status

# Si aparecen, agrégalos al .gitignore inmediatamente
echo ".env.appstore" >> .gitignore
```

---

## 📚 Recursos Adicionales

- [Documentación de Fastlane](https://docs.fastlane.tools)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Guía de revisión de App Store](https://developer.apple.com/app-store/review/guidelines/)
- [Requisitos de screenshots](https://help.apple.com/app-store-connect/#/devd274dd925)

---

## ✅ Checklist Final antes de Enviar a Revisión

- [ ] Metadatos en español e inglés completados
- [ ] Screenshots en todos los tamaños requeridos
- [ ] URLs de privacidad, soporte y marketing funcionando
- [ ] App probada en dispositivos físicos
- [ ] Versión de TestFlight probada por beta testers
- [ ] Cumplimiento de las [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [ ] Permisos de ubicación justificados en la app
- [ ] Íconos de la app en todos los tamaños
- [ ] Launch screen configurada
- [ ] Información de contacto actualizada en App Store Connect

---

## 🆘 Soporte

Si tienes problemas con la configuración:

1. Revisa la sección de [Solución de Problemas](#solución-de-problemas)
2. Consulta los logs de Fastlane: `ios/fastlane/report.xml`
3. Verifica la [documentación de Fastlane](https://docs.fastlane.tools)
4. Contacta al equipo de desarrollo de ETAlatam

---

**Última actualización**: 2025-01-08
**Versión de la app**: 1.12.38
**Mantenido por**: Robert Bruno
