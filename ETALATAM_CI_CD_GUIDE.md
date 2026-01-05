# 🚌 ETAlatam CI/CD Pipeline Guide

## Sistema de Seguimiento de Transporte Escolar - Integración y Despliegue Continuo

### 📋 Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Arquitectura de Pipelines](#arquitectura-de-pipelines)
3. [Configuración Inicial](#configuración-inicial)
4. [Workflows Disponibles](#workflows-disponibles)
5. [Gestión de Secrets](#gestión-de-secrets)
6. [Uso de los Pipelines](#uso-de-los-pipelines)
7. [Troubleshooting](#troubleshooting)
8. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Visión General

ETAlatam ahora cuenta con una infraestructura completa de CI/CD que automatiza:
- ✅ Construcción de APKs Android para múltiples arquitecturas
- ✅ Construcción de IPAs iOS (requiere runner macOS)
- ✅ Análisis de calidad de código
- ✅ Ejecución de pruebas automatizadas
- ✅ Despliegue a TestFlight y Play Store (configuración adicional requerida)

### Tecnologías Utilizadas

| Componente | Tecnología | Versión |
|------------|------------|---------|
| CI/CD Platform | GitHub Actions | Latest |
| Flutter | Flutter SDK | 3.19.0 |
| Dart | Dart SDK | 3.2.0 |
| Android | Gradle/Kotlin | 8.0.2 |
| iOS | Xcode/Swift | 15.0 |
| Automation | FastLane | Latest |

## 🏗️ Arquitectura de Pipelines

```
ETAlatam CI/CD Architecture
├── 📱 Android Pipeline
│   ├── Build Debug APK
│   ├── Build Release APK (Signed)
│   ├── Split per Architecture
│   └── Upload Artifacts
│
├── 🍎 iOS Pipeline
│   ├── Build IPA
│   ├── Code Signing
│   ├── Archive & Export
│   └── TestFlight Upload (Optional)
│
└── 🔍 Code Quality Pipeline
    ├── Flutter Analyze
    ├── Dart Format Check
    ├── Run Tests
    └── Generate Reports
```

## 🚀 Configuración Inicial

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/etalatam/ETAlatam-flutter.git
cd ETAlatam-flutter
```

### Paso 2: Ejecutar Script de Configuración

```bash
# Hacer el script ejecutable
chmod +x etalatam_setup_secrets.sh

# Ejecutar configuración
./etalatam_setup_secrets.sh
```

### Paso 3: Preparar Certificados

#### Android
1. Generar keystore (si no existe):
```bash
keytool -genkey -v -keystore android/app/etalatam-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias etalatam
```

2. Colocar el keystore en: `android/app/etalatam-keystore.jks`

#### iOS
1. Exportar certificado de distribución desde Keychain (Mac)
2. Guardar como: `ios/certificates/etalatam_distribution.p12`
3. Exportar perfil de aprovisionamiento
4. Guardar como: `ios/certificates/etalatam.mobileprovision`

## 📦 Workflows Disponibles

### 1. ETAlatam Android Build

**Archivo**: `.github/workflows/etalatam-android-build.yml`

**Triggers**:
- Push a `main`, `master`, `develop`
- Pull Request a ramas principales
- Push a ramas `release/**`

**Funcionalidades**:
- ✅ Build automático de APKs
- ✅ Separación por arquitectura (arm64, armv7, x86_64)
- ✅ Firma digital (si los secrets están configurados)
- ✅ Upload de artefactos
- ✅ Comentarios automáticos en PRs

**Ejemplo de uso**:
```bash
git checkout -b feature/nueva-funcionalidad
# Hacer cambios
git add .
git commit -m "feat: Agregar nueva funcionalidad ETAlatam"
git push origin feature/nueva-funcionalidad
# Crear PR - el pipeline se ejecuta automáticamente
```

### 2. ETAlatam iOS Build

**Archivo**: `.github/workflows/etalatam-ios-build.yml`

**Requisitos**:
- Runner macOS (self-hosted o GitHub-hosted con plan de pago)
- Certificados y perfiles configurados
- Secrets de App Store Connect

**Funcionalidades**:
- ✅ Build de IPA
- ✅ Code signing automático
- ✅ Export con opciones de distribución
- ✅ Upload opcional a TestFlight
- ✅ Limpieza automática de keychain temporal

### 3. ETAlatam Code Quality

**Archivo**: `.github/workflows/etalatam-code-quality.yml`

**Se ejecuta en**:
- Cada push a cualquier rama
- Cada Pull Request

**Verificaciones**:
- Flutter analyze
- Dart format check
- Ejecución de tests
- Búsqueda de print statements
- Conteo de TODOs
- Análisis de manejo de errores

## 🔐 Gestión de Secrets

### Secrets Requeridos

#### Android Secrets
| Secret Name | Descripción | Requerido |
|-------------|-------------|-----------|
| `ETALATAM_ANDROID_KEYSTORE_BASE64` | Keystore codificado en base64 | Sí |
| `ETALATAM_ANDROID_KEYSTORE_PASSWORD` | Password del keystore | Sí |
| `ETALATAM_ANDROID_KEY_PASSWORD` | Password de la llave | Sí |
| `ETALATAM_ANDROID_KEY_ALIAS` | Alias de la llave (ej: etalatam) | Sí |

#### iOS Secrets
| Secret Name | Descripción | Requerido |
|-------------|-------------|-----------|
| `ETALATAM_IOS_BUILD_CERTIFICATE_BASE64` | Certificado P12 en base64 | Sí |
| `ETALATAM_IOS_BUILD_CERTIFICATE_PASSWORD` | Password del certificado | Sí |
| `ETALATAM_IOS_MOBILE_PROVISIONING_PROFILE_BASE64` | Perfil en base64 | Sí |
| `ETALATAM_IOS_GITHUB_KEYCHAIN_PASSWORD` | Password para keychain temporal | Sí |
| `ETALATAM_APPLE_TEAM_ID` | ID del equipo de Apple | Sí |

#### App Store Connect Secrets
| Secret Name | Descripción | Requerido |
|-------------|-------------|-----------|
| `ETALATAM_APP_STORE_CONNECT_API_KEY_ID` | API Key ID | Para TestFlight |
| `ETALATAM_APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID | Para TestFlight |
| `ETALATAM_APP_STORE_CONNECT_API_KEY_CONTENT` | Contenido del .p8 | Para TestFlight |

### Configurar Secrets Manualmente

1. Navegar a: `https://github.com/[tu-org]/ETAlatam-flutter/settings/secrets/actions`
2. Click en "New repository secret"
3. Agregar nombre y valor
4. Click en "Add secret"

### Configurar Secrets por Script

```bash
# El script automatiza todo el proceso
./etalatam_setup_secrets.sh
```

## 🎮 Uso de los Pipelines

### Flujo de Trabajo Típico

1. **Desarrollo Local**
```bash
# Crear rama de feature
git checkout -b feature/eta-123-nueva-funcionalidad

# Desarrollar y probar localmente
flutter test
flutter analyze

# Commit y push
git add .
git commit -m "feat: [ETA-123] Implementar nueva funcionalidad"
git push origin feature/eta-123-nueva-funcionalidad
```

2. **Pull Request**
- Crear PR en GitHub
- Pipelines se ejecutan automáticamente
- Revisar resultados en la pestaña "Checks"
- Los APKs están disponibles como artefactos

3. **Merge a Main**
- Una vez aprobado el PR
- Merge activa pipeline de release
- APKs firmados se generan automáticamente

### Despliegue Manual

#### Android
```bash
# Build local
flutter build apk --release --split-per-abi

# Los APKs están en:
# build/app/outputs/flutter-apk/
```

#### iOS
```bash
# Requiere Mac
flutter build ios --release

# O con FastLane
cd ios
fastlane build_etalatam
```

## 🔧 Troubleshooting

### Problema: Pipeline de Android falla

**Solución**:
1. Verificar que el keystore existe
2. Verificar secrets configurados:
```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/[tu-org]/ETAlatam-flutter/actions/secrets
```

### Problema: iOS pipeline no se ejecuta

**Solución**:
- Verificar runner macOS disponible
- Para self-hosted runner:
```bash
# En la máquina Mac
./actions-runner/svc.sh status
```

### Problema: "Secret not found"

**Solución**:
```bash
# Re-ejecutar configuración
./etalatam_setup_secrets.sh
```

### Problema: APK no firmado

**Verificar**:
- Keystore presente en `android/app/etalatam-keystore.jks`
- Secrets `ETALATAM_ANDROID_*` configurados
- Branch es `main` (solo se firma en main)

## 📊 Monitoreo y Métricas

### Dashboard de Actions

Ver todos los workflows:
`https://github.com/[tu-org]/ETAlatam-flutter/actions`

### Notificaciones

Configurar en GitHub:
1. Settings → Notifications
2. Activar para:
   - Failed workflows
   - Successful deployments

### Métricas de Build

Los pipelines generan reportes automáticos:
- Tiempo de build
- Tamaño de APK/IPA
- Resultados de tests
- Issues de código

## ✅ Mejores Prácticas

### 1. Nomenclatura de Branches
- `feature/eta-XXX-descripcion` - Nuevas funcionalidades
- `fix/eta-XXX-descripcion` - Corrección de bugs
- `release/vX.Y.Z` - Preparación de release
- `hotfix/eta-XXX-descripcion` - Fixes urgentes

### 2. Commit Messages
```
tipo: [ETA-XXX] descripción breve

Descripción detallada opcional

BREAKING CHANGE: descripción de cambios breaking (si aplica)
```

Tipos: feat, fix, docs, style, refactor, test, chore

### 3. Versionado
Seguir Semantic Versioning:
- MAJOR.MINOR.PATCH
- Ejemplo: 1.12.33

### 4. Seguridad
- ❌ NUNCA commitear secrets o credenciales
- ✅ Usar GitHub Secrets
- ✅ Rotar credenciales regularmente
- ✅ Revisar permisos de workflows

### 5. Optimización
- Cache de dependencias Flutter
- Build incremental cuando sea posible
- Limpiar artefactos antiguos

## 🚀 Roadmap Futuro

### Corto Plazo (1-2 semanas)
- [ ] Configurar runner self-hosted macOS
- [ ] Implementar cache de dependencias
- [ ] Agregar más tests automatizados

### Mediano Plazo (1-2 meses)
- [ ] Integración con Play Store automática
- [ ] Integración con App Store Connect
- [ ] Implementar release notes automáticas
- [ ] Dashboard de métricas de calidad

### Largo Plazo (3-6 meses)
- [ ] Implementar CD completo
- [ ] A/B testing automation
- [ ] Performance monitoring
- [ ] Crash reporting automation

## 📚 Referencias

### Documentación Oficial
- [GitHub Actions](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [FastLane](https://docs.fastlane.tools/)

### Archivos del Proyecto
- Workflows: `.github/workflows/etalatam-*.yml`
- Configuración: `etalatam_setup_secrets.sh`
- Esta guía: `ETALATAM_CI_CD_GUIDE.md`

## 🆘 Soporte

Para asistencia con los pipelines de ETAlatam:

1. **Documentación**: Revisar esta guía
2. **Logs**: Verificar en GitHub Actions
3. **Issues**: Crear issue en el repositorio
4. **Equipo**: Contactar al equipo DevOps de ETAlatam

---

**Proyecto**: ETAlatam School Transport Tracking System
**Versión**: 1.12.33
**Última Actualización**: Enero 2025
**Mantenido por**: Equipo DevOps ETAlatam