# 📋 Guía Simple: Subir Metadatos Manualmente

**Tiempo estimado**: 10-15 minutos
**Requisitos**: Solo navegador web

---

## 🎯 Resumen

Como no podemos ejecutar el script Python desde este Linux (falta permisos sudo), la forma más simple es:

**Copiar los textos de los archivos y pegarlos en App Store Connect**

---

## 📝 PASO A PASO

### 1. Abrir App Store Connect

Ve a: **https://appstoreconnect.apple.com**
- Email: `etalatamdev@gmail.com`
- Inicia sesión

### 2. Ir a tu App

1. Haz clic en **"My Apps"**
2. Busca y abre **"ETA School Transport"**

### 3. Configurar Idioma Español

#### A) Agregar Español si no está:
1. Ve a **"App Information"** (en el sidebar izquierdo)
2. Busca la sección **"Localizable Information"**
3. Si no ves "Spanish (Spain)", haz clic en **"+ Add Locale"**
4. Selecciona **"Spanish (Spain)"**
5. Haz clic en **"Add"**

#### B) Completar datos en Español:

Abre los siguientes archivos y copia el contenido:

**Nombre** (Name):
```bash
cat ios/fastlane/metadata/es-ES/name.txt
```
Copiar: `ETA School Transport`

**Subtítulo** (Subtitle):
```bash
cat ios/fastlane/metadata/es-ES/subtitle.txt
```
Copiar: `Seguimiento de Transporte Escolar`

**Privacy Policy URL**:
```bash
cat ios/fastlane/metadata/es-ES/privacy_url.txt
```
Copiar: `https://etalatam.com/privacy`

Haz clic en **"Save"**

### 4. Configurar Descripción y Palabras Clave (Español)

1. En el sidebar, ve a la versión de tu app (ej: **"1.0 Prepare for Submission"** o similar)
2. Selecciona el idioma **"Spanish (Spain)"**

**Descripción** (Description):
```bash
cat ios/fastlane/metadata/es-ES/description.txt
```

**Palabras clave** (Keywords):
```bash
cat ios/fastlane/metadata/es-ES/keywords.txt
```

**Marketing URL**:
```bash
cat ios/fastlane/metadata/es-ES/marketing_url.txt
```

**Support URL**:
```bash
cat ios/fastlane/metadata/es-ES/support_url.txt
```

**Promotional Text** (opcional - puedes usar el subtítulo):
```bash
cat ios/fastlane/metadata/es-ES/subtitle.txt
```

**What's New** (Notas de la versión):
```bash
cat ios/fastlane/metadata/es-ES/release_notes.txt
```

Haz clic en **"Save"**

### 5. Repetir para Inglés

Ahora repite los pasos 3 y 4, pero:
- Selecciona idioma: **"English (U.S.)"**
- Usa los archivos de: `ios/fastlane/metadata/en-US/`

---

## 📂 Comandos para Ver los Archivos

### Español (es-ES):

```bash
# Nombre
cat ios/fastlane/metadata/es-ES/name.txt

# Subtítulo
cat ios/fastlane/metadata/es-ES/subtitle.txt

# Descripción
cat ios/fastlane/metadata/es-ES/description.txt

# Palabras clave
cat ios/fastlane/metadata/es-ES/keywords.txt

# URLs
cat ios/fastlane/metadata/es-ES/marketing_url.txt
cat ios/fastlane/metadata/es-ES/support_url.txt
cat ios/fastlane/metadata/es-ES/privacy_url.txt

# Notas de versión
cat ios/fastlane/metadata/es-ES/release_notes.txt
```

### English (en-US):

```bash
# Name
cat ios/fastlane/metadata/en-US/name.txt

# Subtitle
cat ios/fastlane/metadata/en-US/subtitle.txt

# Description
cat ios/fastlane/metadata/en-US/description.txt

# Keywords
cat ios/fastlane/metadata/en-US/keywords.txt

# URLs
cat ios/fastlane/metadata/en-US/marketing_url.txt
cat ios/fastlane/metadata/en-US/support_url.txt
cat ios/fastlane/metadata/en-US/privacy_url.txt

# Release notes
cat ios/fastlane/metadata/en-US/release_notes.txt
```

---

## ✅ Checklist de Verificación

Después de copiar todo, verifica:

- [ ] Idioma Español agregado
- [ ] Idioma English agregado
- [ ] Nombre en ambos idiomas
- [ ] Subtítulo en ambos idiomas
- [ ] Descripción completa en ambos idiomas
- [ ] Palabras clave en ambos idiomas
- [ ] URLs (marketing, support, privacy) en ambos idiomas
- [ ] Notas de versión en ambos idiomas
- [ ] Todo guardado (Save)

---

## 🎯 Campos Importantes

### En "App Information":
- Name (Nombre)
- Subtitle (Subtítulo)
- Privacy Policy URL

### En la Versión de la App:
- Description (Descripción)
- Keywords (Palabras clave)
- What's New (Notas de la versión)
- Support URL
- Marketing URL

---

## 💡 Tips

1. **Copia con `cat`**: Usa los comandos de arriba para ver el contenido
2. **Selecciona todo**: Ctrl+A en la terminal
3. **Copia**: Ctrl+Shift+C
4. **Pega en App Store Connect**: Ctrl+V
5. **Guarda**: No olvides hacer clic en "Save" después de cada sección

---

## ⏱️ Tiempo Estimado por Sección

- App Information (Español): 2 minutos
- App Information (Inglés): 2 minutos
- Versión App (Español): 5 minutos
- Versión App (Inglés): 5 minutos
- **Total**: ~15 minutos

---

## 🆘 ¿Problemas?

### "No puedo agregar idioma Español"
- Asegúrate de estar en "App Information"
- Busca "Localizable Information"
- Haz clic en el botón "+"

### "No encuentro dónde poner la descripción"
- Ve al sidebar izquierdo
- Busca tu versión de app (ej: "1.0 Prepare for Submission")
- Selecciona el idioma en el dropdown

### "¿Qué pongo en Screenshots?"
- Por ahora déjalo vacío
- Los screenshots los puedes agregar después
- No son obligatorios para guardar metadatos

---

## ✨ ¡Listo!

Una vez que copies todo:

1. Verifica que todo se vea bien en App Store Connect
2. Haz clic en "Save" en cada sección
3. Puedes agregar screenshots más tarde
4. Cuando tengas el build, podrás enviarlo a revisión

**¡Los metadatos ya estarán configurados en 2 idiomas!** 🎉

---

## 🔄 Alternativa para el Futuro

Cuando tengas acceso a una máquina con permisos o una Mac:

```bash
# Opción Python (con permisos sudo):
sudo apt install python3-pyjwt python3-cryptography python3-requests
python3 upload_metadata_api.py

# Opción Fastlane (en Mac):
./setup_appstore.sh
cd ios && bundle exec fastlane upload_metadata
```

Pero por ahora, la forma manual es la más práctica.
