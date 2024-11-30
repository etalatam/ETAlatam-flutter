# ETAlatam-flutter

ETAlatam Flutter application

**Previous requirements:**

* Have Flutter SDK installed. You can download it from [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install).
* Have a Flutter-compatible IDE installed, such as Android Studio or Visual Studio Code.
* A physical Android or an emulator.
* You can use the `flutter doctor` command to verify that your development environment is configured correctly.

**Step 1:**

Download or clone this repo by using the link below:

```
git clone https://github.com/etalatam/ETAlatam-flutter.git
```

**Step 2:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```

**Step 3:**

Go to project root and execute the following command in console to get the required dependencies: 

```
flutter pub get 
```

## Alternative build

1. **Open your Flutter project in your IDE.**
2. **Select the platform you want to build for:**

      * **Android:**
          * In Android Studio, select `Build > Build APK`.
          * In Visual Studio Code, run the `flutter build apk` command.

3. **Wait for the build to finish.**
4. **If the build is successful, you will find the APK (Android) file in the `build/app/outputs` folder.**

**Additional tips:**

* You can par device using `adb pair ipaddr:port`

> Where ipaddr:port is taken from the menu shown after clicking from Developer options > Wireless debugging > Pair device with pairing code. 
> More info at [Android Debug Bridge (adb)](https://developer.android.com/tools/adb)

* You can use the `flutter run` command to run the app on your device or emulator without compiling it.
* You can find more information on how to build Flutter apps in the official documentation: [https://flutter.dev/](https://flutter.dev/)
* you can finds and fixes two types of issues [dart fix](https://dart.dev/tools/dart-fix)


## Hide Generated Files

In-order to hide generated files, navigate to `Android Studio` -> `Preferences` -> `Editor` -> `File Types` and paste the below lines under `ignore files and folders` section:

```
*.inject.summary;*.inject.dart;*.g.dart;
```

In Visual Studio Code, navigate to `Preferences` -> `Settings` and search for `Files:Exclude`. Add the following patterns:
```
**/*.inject.summary
**/*.inject.dart
**/*.g.dart
```

