# ETAlatam-flutter

ETAlatam es una aplicación Flutter diseñada para Android e iOS que forma parte de una plataforma de seguimiento de autobuses escolares. La aplicación permite a los conductores reportar el avance de sus rutas diarias, a los padres o representantes ver la ubicación de sus hijos y el autobús en tiempo real, y a los estudiantes reportar su ubicación y conocer cuándo llegará el autobús.

## Requisitos Previos

Antes de comenzar, asegúrate de cumplir con los siguientes requisitos:

- **Flutter SDK**: Debes tener instalado el SDK de Flutter. Puedes descargarlo desde [aquí](https://docs.flutter.dev/get-started/install).
  - **Versión de Flutter**: La versión de Flutter debe ser **exclusivamente la 3.19.0**.
  - **Versión de Dart SDK**: La versión del SDK de Dart debe ser **exclusivamente la 3.2.0**.
  
- **IDE compatible**: Necesitas un IDE compatible con Flutter, como Android Studio o Visual Studio Code.
- **Dispositivo físico o emulador**: Puedes usar un dispositivo Android/iOS físico o un emulador para ejecutar la aplicación.
- **Verificación del entorno**: Ejecuta el comando `flutter doctor` para verificar que tu entorno de desarrollo esté configurado correctamente.

## Configuración del Proyecto

### Paso 1: Clonar el Repositorio

Descarga o clona este repositorio utilizando el siguiente comando:

```bash
git clone https://github.com/etalatam/ETAlatam-flutter.git
```

### Paso 2: Obtener Dependencias

Navega a la raíz del proyecto y ejecuta el siguiente comando para obtener las dependencias necesarias:

```bash
flutter pub get
```

## Construcción de la Aplicación

### Construcción para Android

1. **Abre tu proyecto en tu IDE** (Android Studio o Visual Studio Code).
2. **Selecciona la plataforma para la que deseas construir**:
   - **Android**:
     - En Android Studio, selecciona `Build > Build APK`.
     - En Visual Studio Code, ejecuta el comando `flutter build apk`.
3. **Espera a que la construcción finalice**.
4. **Si la construcción es exitosa**, encontrarás el archivo APK en la carpeta `build/app/outputs`.

### Construcción para iOS

1. **Abre tu proyecto en Xcode**.
2. **Selecciona el dispositivo o simulador** en el que deseas ejecutar la aplicación.
3. **Ejecuta el comando `flutter build ios`** para construir la aplicación.
4. **Espera a que la construcción finalice**.
5. **Si la construcción es exitosa**, puedes ejecutar la aplicación en el simulador o en un dispositivo físico.

## Ejecución y Depuración

### Ejecutar la Aplicación

Puedes ejecutar la aplicación en un dispositivo físico o en un emulador utilizando el siguiente comando:

```bash
flutter run
```

### Depuración

- **Depuración en Android**: Conecta tu dispositivo Android y ejecuta `flutter run`. Asegúrate de que el dispositivo esté en modo de depuración.
- **Depuración en iOS**: Conecta tu dispositivo iOS y ejecuta `flutter run`. Asegúrate de que el dispositivo esté configurado para desarrollo.

### Solución de Problemas

- **Problemas con Dart**: Si encuentras problemas relacionados con Dart, puedes usar el comando `dart fix` para encontrar y corregir problemas comunes.
- **Linting**: Asegúrate de que tu código cumpla con las reglas de linting ejecutando `flutter analyze`.

## Ocultar Archivos Generados

Para ocultar archivos generados en tu IDE, sigue estos pasos:

### Android Studio

1. Navega a `Android Studio` -> `Preferences` -> `Editor` -> `File Types`.
2. Pega las siguientes líneas en la sección `Ignore files and folders`:

```
*.inject.summary;*.inject.dart;*.g.dart;
```

### Visual Studio Code

1. Navega a `Preferences` -> `Settings`.
2. Busca `Files:Exclude` y agrega los siguientes patrones:

```
**/*.inject.summary
**/*.inject.dart
**/*.g.dart
```

## Consejos Adicionales

- **Emparejamiento de Dispositivos**: Puedes emparejar un dispositivo usando `adb pair ipaddr:port`, donde `ipaddr:port` se obtiene del menú que aparece después de hacer clic en `Developer options > Wireless debugging > Pair device with pairing code`. Más información en [Android Debug Bridge (adb)](https://developer.android.com/tools/adb).
- **Documentación Oficial**: Puedes encontrar más información sobre cómo construir aplicaciones Flutter en la [documentación oficial de Flutter](https://flutter.dev/).

## Problemas Comunes y Soluciones

- **Versión de Flutter/Dart**: Asegúrate de que estás utilizando **Flutter 3.19.0** y **Dart SDK 3.2.0**. Si no, puedes cambiar la versión ejecutando `flutter downgrade` o `flutter upgrade` según sea necesario.
- **Dependencias no resueltas**: Si encuentras problemas con las dependencias, ejecuta `flutter pub get` nuevamente.
- **Errores de Linting**: Si tu código no pasa el análisis de linting, revisa los mensajes de error y corrige los problemas indicados.

