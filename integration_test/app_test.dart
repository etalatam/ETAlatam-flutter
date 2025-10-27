import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eta_school_app/main.dart' as app;

void main() {
  group('Login E2E Tests', () {
    testWidgets('Login de representante exitoso', (WidgetTester tester) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que la pantalla de login esté visible
      await tester.pump(Duration(seconds: 2));

      // Verificar que estamos en la página de login
      expect(find.text('ETA'), findsOneWidget);

      // Buscar los campos de entrada
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Ingresar las credenciales de prueba
      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump();

      await tester.enterText(passwordField, 'casa1234');
      await tester.pump();

      // Buscar y presionar el botón de login
      final loginButton = find.text('INICIAR');
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pump();

      // Esperar la respuesta del servidor (con timeout)
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 10),
      );

      // Verificar que el login fue exitoso
      // Esto dependerá de qué pantalla se muestra después del login exitoso
      // Por ejemplo, buscar un elemento específico del dashboard
      expect(find.text('Bienvenido'), findsAny);
    });

    testWidgets('Login con credenciales incorrectas', (WidgetTester tester) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que la pantalla de login esté visible
      await tester.pump(Duration(seconds: 2));

      // Buscar los campos de entrada
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Ingresar credenciales incorrectas
      await tester.enterText(emailField, 'usuario@incorrecto.com');
      await tester.pump();

      await tester.enterText(passwordField, 'claveincorrecta');
      await tester.pump();

      // Buscar y presionar el botón de login
      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);
      await tester.pump();

      // Esperar la respuesta
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 10),
      );

      // Verificar que se muestra un mensaje de error
      expect(find.textContaining('error'), findsAny);
    });

    testWidgets('Validación de campos vacíos', (WidgetTester tester) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que la pantalla de login esté visible
      await tester.pump(Duration(seconds: 2));

      // Buscar y presionar el botón de login sin llenar campos
      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);
      await tester.pump();

      // Verificar que se muestran mensajes de validación
      expect(find.text('Este campo es requerido'), findsAny);
    });
  });

  group('Pruebas de navegación post-login', () {
    testWidgets('Navegación después de login exitoso', (WidgetTester tester) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que la pantalla de login esté visible
      await tester.pump(Duration(seconds: 2));

      // Login con credenciales válidas
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump();

      await tester.enterText(passwordField, 'casa1234');
      await tester.pump();

      final loginButton = find.text('INICIAR');
      await tester.tap(loginButton);

      // Esperar navegación
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 15),
      );

      // Verificar que estamos en la página principal
      // y que hay elementos del menú o dashboard
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsAny);
    });
  });

  group('Pruebas de recuperación de contraseña', () {
    testWidgets('Acceso a recuperación de contraseña', (WidgetTester tester) async {
      // Inicializar la aplicación
      app.main();
      await tester.pumpAndSettle();

      // Esperar a que la pantalla de login esté visible
      await tester.pump(Duration(seconds: 2));

      // Buscar y presionar el link de "¿Olvidaste tu contraseña?"
      final forgotPasswordLink = find.text('¿OLVIDÓ SU CONTRASEÑA?');
      if (forgotPasswordLink.evaluate().isNotEmpty) {
        await tester.tap(forgotPasswordLink);
        await tester.pumpAndSettle();

        // Verificar que navegamos a la página de recuperación
        expect(find.text('Recuperar contraseña'), findsAny);
      }
    });
  });
}