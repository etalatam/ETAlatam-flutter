# 🚀 Cómo Subir Metadatos a App Store Connect

**Configuración**: ✅ COMPLETA
**Credenciales**: ✅ CONFIGURADAS
**Metadatos**: ✅ LISTOS (Español + Inglés)

---

## ⚡ OPCIÓN 1: Script Python (Linux/Mac) - RECOMENDADO

### Requisitos:
```bash
# Instalar dependencias Python
sudo apt install python3-pip python3-jwt python3-cryptography python3-requests
# O en Mac:
pip3 install PyJWT cryptography requests
```

### Ejecutar:
```bash
python3 upload_metadata_api.py
```

Este script:
- ✅ Autentica con App Store Connect API
- ✅ Encuentra tu app automáticamente
- ✅ Sube metadatos en Español
- ✅ Sube metadatos en Inglés
- ✅ Muestra confirmación

**Tiempo estimado**: 30 segundos

---

## ⚡ OPCIÓN 2: Fastlane desde Mac (Más completo)

Si tienes una Mac disponible:

```bash
# 1. Clonar o actualizar repositorio
git pull

# 2. Instalar Fastlane
./setup_appstore.sh

# 3. Subir metadatos
cd ios
bundle exec fastlane upload_metadata
```

Fastlane sube:
- ✅ Nombre, subtítulo, descripción
- ✅ Palabras clave
- ✅ URLs (marketing, soporte, privacidad)
- ✅ Notas de la versión (What's New)
- ✅ Categorías y configuración

**Tiempo estimado**: 2-3 minutos

---

## ⚡ OPCIÓN 3: Subida Manual (Sin scripts)

### Paso 1: Ir a App Store Connect

Ve a: https://appstoreconnect.apple.com

### Paso 2: Seleccionar tu App

1. **My Apps** → **ETA School Transport**
2. En el sidebar izquierdo, ve a **App Information**

### Paso 3: Agregar Idioma Español

1. Scroll hasta **Localizable Information**
2. Haz clic en el **+** junto a "Primary Language"
3. Selecciona **Spanish (Spain)** → Add

### Paso 4: Copiar Metadatos en Español

Abre estos archivos y copia/pega en App Store Connect:

#### 📝 Nombre (Name):
```
ios/fastlane/metadata/es-ES/name.txt
```
**Valor**: ETA School Transport

#### 📝 Subtítulo (Subtitle):
```
ios/fastlane/metadata/es-ES/subtitle.txt
```
**Valor**: Seguimiento de Transporte Escolar

#### 📝 Descripción (Description):
```
ios/fastlane/metadata/es-ES/description.txt
```
*Copia todo el contenido (1,850+ caracteres)*

#### 📝 Palabras Clave (Keywords):
```
ios/fastlane/metadata/es-ES/keywords.txt
```
**Valor**: transporte escolar,GPS,seguimiento,autobús,estudiantes,padres,conductores,tiempo real,escuela,ruta escolar,seguridad,notificaciones

#### 📝 URL de Marketing:
```
ios/fastlane/metadata/es-ES/marketing_url.txt
```
**Valor**: https://etalatam.com

#### 📝 URL de Soporte:
```
ios/fastlane/metadata/es-ES/support_url.txt
```
**Valor**: https://etalatam.com/support

#### 📝 URL de Privacidad:
```
ios/fastlane/metadata/es-ES/privacy_url.txt
```
**Valor**: https://etalatam.com/privacy

### Paso 5: Agregar Versión y Notas

1. Ve a la sección de tu app → **iOS App**
2. Selecciona la versión actual o crea una nueva
3. En **What's New in This Version** (para Español):

```
ios/fastlane/metadata/es-ES/release_notes.txt
```

### Paso 6: Repetir para Inglés

1. Agregar idioma **English (U.S.)**
2. Copiar archivos de: `ios/fastlane/metadata/en-US/`
3. Pegar en los mismos campos

**Tiempo estimado**: 15-20 minutos

---

## 📊 Archivos de Metadatos Disponibles

### 🇪🇸 Español (es-ES)
```
ios/fastlane/metadata/es-ES/
├── name.txt              - ETA School Transport
├── subtitle.txt          - Seguimiento de Transporte Escolar
├── description.txt       - Descripción completa (1,850 caracteres)
├── keywords.txt          - 12 palabras clave
├── marketing_url.txt     - https://etalatam.com
├── support_url.txt       - https://etalatam.com/support
├── privacy_url.txt       - https://etalatam.com/privacy
└── release_notes.txt     - Notas versión 1.12.38
```

### 🇺🇸 English (en-US)
```
ios/fastlane/metadata/en-US/
├── name.txt              - ETA School Transport
├── subtitle.txt          - School Bus Tracking System
├── description.txt       - Full description (1,750 characters)
├── keywords.txt          - 12 keywords
├── marketing_url.txt     - https://etalatam.com
├── support_url.txt       - https://etalatam.com/support
├── privacy_url.txt       - https://etalatam.com/privacy
└── release_notes.txt     - Version 1.12.38 notes
```

---

## ✅ Verificación

Después de subir, verifica en App Store Connect que:

- [ ] Aparecen 2 idiomas: Español y English
- [ ] La descripción en español se ve completa
- [ ] La descripción en inglés se ve completa
- [ ] Las URLs funcionan
- [ ] Las palabras clave están correctas
- [ ] Las notas de la versión están actualizadas

---

## 🔐 Credenciales Configuradas

Tu archivo `.env.appstore` ya tiene:

```
APPLE_ID=etalatamdev@gmail.com
TEAM_ID=494S8338AJ
APP_STORE_CONNECT_API_KEY_ID=2A6UCBGW5Z
APP_STORE_CONNECT_API_ISSUER_ID=633d3064-8dbd-412b-aa53-2c4aa211c354
```

---

## 💡 Recomendación

**Para esta primera vez**: Te recomiendo **Opción 3 (Manual)** porque:
- No requiere dependencias de Python
- No requiere Mac
- Puedes ver exactamente qué se sube
- Verificas que todo se ve correcto

**Para futuras actualizaciones**: Usa **Opción 1 (Python)** o **Opción 2 (Fastlane)** para automatizar.

---

## 📞 ¿Problemas?

Si algo no funciona:
1. Lee `CONFIGURACION_COMPLETADA.md`
2. Revisa que la app exista en App Store Connect
3. Verifica que las URLs funcionen

---

## 🎯 Siguiente Paso

Elige una opción de arriba y sube los metadatos. Una vez subidos, podrás:
- Agregar screenshots
- Configurar precios
- Enviar para revisión (cuando tengas el build)

**¿Cuál opción prefieres usar?**
- Opción 1: Python (requiere instalar dependencias)
- Opción 2: Fastlane en Mac (más completo)
- Opción 3: Manual (sin dependencias, 15-20 min)
