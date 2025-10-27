import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eta_school_app/main.dart' as app;

/// Pruebas funcionales detalladas del flujo de login
/// Credenciales de prueba: etalatam+representante1@gmail.com / casa1234

void main() {
  group('Pruebas E2E del flujo de Login', () {
    testWidgets('Login exitoso con credenciales válidas de representante',
        (WidgetTester tester) async {
      // Arrancar la aplicación
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      print('[TEST] Iniciando prueba de login exitoso');

      // Buscar campos de texto
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Ingresar credenciales válidas
      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump(Duration(milliseconds: 300));

      await tester.enterText(passwordField, 'casa1234');
      await tester.pump(Duration(milliseconds: 300));

      print('[TEST] Credenciales ingresadas correctamente');

      // Buscar y presionar el botón de login
      final loginButton = find.text('INICIAR');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      print('[TEST] Botón de login presionado');

      // Esperar la respuesta del servidor
      await tester.pump(Duration(seconds: 1));

      // Intentar hasta 10 segundos para ver si el login es exitoso
      bool loginSuccessful = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(Duration(seconds: 1));

        // Buscar indicadores de éxito
        if (find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
            find.byType(AppBar).evaluate().length > 1 ||
            find.text('Inicio').evaluate().isNotEmpty ||
            find.text('Bienvenido').evaluate().isNotEmpty) {
          loginSuccessful = true;
          print('[TEST] ✓ Login exitoso detectado');
          break;
        }

        // Verificar si hay error
        if (find.text('Error').evaluate().isNotEmpty) {
          print('[TEST] ✗ Se detectó un error en el login');
          break;
        }
      }

      expect(loginSuccessful, true,
          reason: 'El login debe ser exitoso con credenciales válidas');
    });

    testWidgets('Manejo de credenciales incorrectas',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      print('[TEST] Probando login con credenciales incorrectas');

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Credenciales incorrectas
      await tester.enterText(emailField, 'usuario.invalido@test.com');
      await tester.enterText(passwordField, 'password123');

      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);

      await tester.pump(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que permanecemos en login
      expect(find.text('INICIAR'), findsOneWidget,
          reason: 'Debe permanecer en la pantalla de login');

      print('[TEST] ✓ Login rechazado correctamente');
    });

    testWidgets('Validación de campos vacíos', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      print('[TEST] Probando validación de campos vacíos');

      // Intentar login sin llenar campos
      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);
      await tester.pump();

      // Debe permanecer en pantalla de login
      expect(find.text('INICIAR'), findsOneWidget);

      // Verificar si hay mensajes de validación
      final hasValidation =
          find.text('Requerido').evaluate().isNotEmpty ||
          find.text('Este campo es requerido').evaluate().isNotEmpty ||
          find.text('Por favor').evaluate().isNotEmpty;

      print('[TEST] Validación de campos: ${hasValidation ? "✓" : "⚠"}');
    });

    testWidgets('Verificar elementos UI del login',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      print('[TEST] Verificando elementos de UI');

      // Verificar presencia del logo o título
      expect(find.text('ETA'), findsWidgets);

      // Verificar campos de entrada
      expect(find.byType(TextFormField), findsNWidgets(2));

      // Verificar botón de login
      expect(find.text('INICIAR'), findsOneWidget);

      // Verificar link de recuperación de contraseña
      final forgotPassword = find.text('¿OLVIDÓ SU CONTRASEÑA?');
      if (forgotPassword.evaluate().isNotEmpty) {
        print('[TEST] ✓ Link de recuperación de contraseña presente');
      }

      print('[TEST] ✓ Todos los elementos UI verificados');
    });

    testWidgets('Medición de tiempo de respuesta del login',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      print('[TEST] Midiendo tiempo de respuesta');

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.enterText(passwordField, 'casa1234');

      final stopwatch = Stopwatch()..start();

      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);

      // Esperar hasta que el login complete
      bool completed = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(Duration(milliseconds: 500));

        if (find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
            find.text('Error').evaluate().isNotEmpty) {
          completed = true;
          break;
        }
      }

      stopwatch.stop();

      if (completed) {
        final milliseconds = stopwatch.elapsedMilliseconds;
        print('[TEST] Tiempo de respuesta: ${milliseconds}ms');

        if (milliseconds < 2000) {
          print('[TEST] ✓ Excelente rendimiento (<2s)');
        } else if (milliseconds < 4000) {
          print('[TEST] ✓ Buen rendimiento (<4s)');
        } else {
          print('[TEST] ⚠ Rendimiento mejorable (>${milliseconds / 1000}s)');
        }
      }
    });
  });
}