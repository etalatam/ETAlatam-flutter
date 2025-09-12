# Implementación del Sistema de Temas - ETA School App

## Resumen de Cambios

Se ha implementado un sistema completo de gestión de temas oscuro/claro para la aplicación ETA School App. Los cambios principales incluyen:

### 1. Nuevo Provider de Temas (`lib/providers/theme_provider.dart`)

- **Clase `ThemeProvider`**: Gestiona el estado del tema de la aplicación
- **Persistencia**: Guarda la preferencia del usuario en SharedPreferences
- **Temas definidos**: 
  - `lightTheme()`: Tema claro con colores corporativos
  - `darkTheme()`: Tema oscuro con fondo azul oscuro (#1e3050)
- **Métodos principales**:
  - `toggleTheme()`: Alterna entre tema claro y oscuro
  - `setDarkMode(bool)`: Establece el modo oscuro directamente
  - `loadThemeFromPrefs()`: Carga la preferencia guardada al iniciar

### 2. Actualización del Main (`lib/main.dart`)

- Se agregó `ThemeProvider` al MultiProvider
- Se configuró `GetMaterialApp` con:
  - `theme`: Tema claro
  - `darkTheme`: Tema oscuro
  - `themeMode`: Controlado por ThemeProvider
- Se envolvió MyApp con Consumer<ThemeProvider> para reactividad

### 3. Actualización de Settings Page (`lib/Pages/settings_page.dart`)

- Se reemplazó el sistema antiguo de temas locales
- Se integró con ThemeProvider usando Provider.of
- El switch de Dark Mode ahora:
  - Lee el estado desde ThemeProvider
  - Actualiza el tema globalmente al cambiar
  - Persiste automáticamente la preferencia

### 4. Actualización del Header (`lib/components/header.dart`)

- Se actualizó para usar `Theme.of(context)`
- Usa los estilos del tema actual automáticamente

## Características del Sistema de Temas

### Tema Claro
- Fondo: Blanco
- Color primario: Verde azulado (#3B8C87)
- Texto: Azul oscuro (#1e3050)
- AppBar: Fondo blanco con texto oscuro

### Tema Oscuro
- Fondo: Azul oscuro (#1e3050)
- Color primario: Verde azulado (#3B8C87)
- Texto: Blanco
- AppBar: Fondo azul oscuro con texto blanco

## Migración de Componentes

Para migrar otros componentes al nuevo sistema de temas:

### Antes (Sistema antiguo):
```dart
Container(
  color: activeTheme.main_bg,
  child: Text('Texto', style: activeTheme.h5)
)
```

### Después (Sistema nuevo):
```dart
Container(
  color: Theme.of(context).scaffoldBackgroundColor,
  child: Text('Texto', style: Theme.of(context).textTheme.titleLarge)
)
```

## Mapeo de Estilos

| Estilo Antiguo | Estilo Nuevo |
|----------------|--------------|
| activeTheme.main_bg | Theme.of(context).scaffoldBackgroundColor |
| activeTheme.main_color | Theme.of(context).primaryColor |
| activeTheme.h1 | Theme.of(context).textTheme.headlineLarge |
| activeTheme.h2 | Theme.of(context).textTheme.headlineMedium |
| activeTheme.h3 | Theme.of(context).textTheme.headlineSmall |
| activeTheme.h4 | Theme.of(context).textTheme.headlineSmall |
| activeTheme.h5 | Theme.of(context).textTheme.titleLarge |
| activeTheme.h6 | Theme.of(context).textTheme.titleMedium |
| activeTheme.normalText | Theme.of(context).textTheme.bodyLarge |
| activeTheme.smallText | Theme.of(context).textTheme.bodyMedium |

## Archivos que Necesitan Actualización

Los siguientes archivos aún usan el sistema antiguo y deberían actualizarse:

- `lib/Pages/driver_home.dart`
- `lib/Pages/trip_page.dart`
- `lib/Pages/guardians_home.dart`
- `lib/Pages/students_home.dart`
- `lib/Pages/login_page.dart`
- `lib/components/widgets.dart`
- Otros componentes en `lib/components/`

## Cómo Probar

1. **Instalar Flutter** (si no está instalado):
   ```bash
   # Seguir instrucciones en https://flutter.dev/docs/get-started/install
   ```

2. **Ejecutar la aplicación**:
   ```bash
   flutter pub get
   flutter run
   ```

3. **Probar el cambio de tema**:
   - Navegar a Settings/Configuración
   - Activar/desactivar el switch de "Dark mode"
   - El tema debe cambiar inmediatamente en toda la aplicación
   - Cerrar y abrir la app debe mantener la preferencia

## Script de Build

Se ha creado `build_app.sh` para facilitar el proceso de build:

```bash
./build_app.sh
```

Este script:
- Verifica que Flutter esté instalado
- Limpia el proyecto
- Obtiene dependencias
- Analiza el código
- Permite construir para Android (APK/Bundle), iOS o Web

## Notas Importantes

- El sistema de temas ahora es **global** y **reactivo**
- Los cambios se aplican **inmediatamente** en toda la aplicación
- La preferencia se **persiste** entre sesiones
- Compatible con el sistema de localización existente (Español/English)