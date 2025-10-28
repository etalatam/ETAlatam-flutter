import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eta_school_app/main.dart' as app;
import 'package:eta_school_app/services/storage_service.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Tests - BDD Style', () {
    setUp(() async {
      // Given: La aplicación está iniciada y no hay sesión activa
      await StorageService.instance.clear();
    });

    testWidgets('Escenario: Login exitoso con credenciales válidas', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      expect(find.byType(Login), findsOneWidget);
      print('✓ Given: Estoy en la pantalla de login');

      // When: Ingreso "etalatam+representante1@gmail.com" en el campo de correo
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump();
      print('✓ When: Ingreso email de prueba');

      // And: Ingreso "casa1234" en el campo de contraseña
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'casa1234');
      await tester.pump();
      print('✓ And: Ingreso contraseña de prueba');

      // And: Presiono el botón de "Ingresar"
      final loginButton = find.text('sign in');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      print('✓ And: Presiono el botón de login');

      // Then: Debería ver la pantalla de inicio
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 15),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Login), findsNothing);
      print('✓ Then: Navego exitosamente a HomeScreen');

      // And: El token de sesión debería estar guardado
      final token = await StorageService.instance.getString('token');
      expect(token, isNotNull);
      expect(token!.isNotEmpty, true);
      print('✓ And: Token guardado correctamente');

      // And: El id de usuario debería ser 128
      final userId = await StorageService.instance.getInt('id_usu');
      expect(userId, equals(128));
      print('✓ And: ID de usuario correcto (128)');

      // And: El nombre de relación debería ser "eta.guardians"
      final relationName = await StorageService.instance.getString('relation_name');
      expect(relationName, equals('eta.guardians'));
      print('✓ And: Rol correcto (eta.guardians)');
    });

    testWidgets('Escenario: Login fallido con credenciales inválidas', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      expect(find.byType(Login), findsOneWidget);
      print('✓ Given: Estoy en la pantalla de login');

      // When: Ingreso "usuario.invalido@test.com" en el campo de correo
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'usuario.invalido@test.com');
      await tester.pump();
      print('✓ When: Ingreso email inválido');

      // And: Ingreso "passwordIncorrecta" en el campo de contraseña
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'passwordIncorrecta');
      await tester.pump();
      print('✓ And: Ingreso contraseña incorrecta');

      // And: Presiono el botón de "Ingresar"
      final loginButton = find.text('sign in');
      await tester.tap(loginButton);
      print('✓ And: Presiono el botón de login');

      // Then: Debería ver un mensaje de error
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 10),
      );

      expect(find.textContaining('Error'), findsAny);
      print('✓ Then: Veo mensaje de error');

      // And: Debería permanecer en la pantalla de login
      expect(find.byType(Login), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      print('✓ And: Permanezco en pantalla de login');

      // And: No debería haber token guardado
      final token = await StorageService.instance.getString('token');
      expect(token, isNull);
      print('✓ And: No hay token guardado');
    });

    testWidgets('Escenario: Validación de campos vacíos', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      expect(find.byType(Login), findsOneWidget);
      print('✓ Given: Estoy en la pantalla de login');

      // When: Presiono el botón de "Ingresar" sin llenar los campos
      final loginButton = find.text('sign in');
      await tester.tap(loginButton);
      await tester.pump(Duration(seconds: 1));
      print('✓ When: Presiono login sin llenar campos');

      // Then: No debería poder continuar
      // And: Debería permanecer en la pantalla de login
      expect(find.byType(Login), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      print('✓ Then: Permanezco en pantalla de login');

      // And: No debería haber token guardado
      final token = await StorageService.instance.getString('token');
      expect(token, isNull);
      print('✓ And: No hay token guardado');
    });

    testWidgets('Escenario: Persistencia de datos después del login', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));
      print('✓ Given: Estoy en la pantalla de login');

      // When: Ingreso credenciales válidas
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump();
      await tester.enterText(passwordField, 'casa1234');
      await tester.pump();
      print('✓ When: Ingreso credenciales válidas');

      // And: Presiono el botón de "Ingresar"
      final loginButton = find.text('sign in');
      await tester.tap(loginButton);
      print('✓ And: Presiono login');

      // And: Navego a la pantalla de inicio exitosamente
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 15),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      print('✓ And: Navego a HomeScreen');

      // Then: El token de sesión debería estar guardado en el almacenamiento local
      final session = await StorageService.instance.getUserSession();
      expect(session, isNotNull);
      expect(session!['token'], isNotNull);
      print('✓ Then: Token guardado en almacenamiento local');

      // And: El id de usuario debería ser 128
      expect(session['id_usu'], equals(128));
      print('✓ And: ID de usuario = 128');

      // And: El nombre de relación debería ser "eta.guardians"
      expect(session['relation_name'], equals('eta.guardians'));
      print('✓ And: Relación = eta.guardians');

      // And: El id de relación debería ser 20
      expect(session['relation_id'], equals(20));
      print('✓ And: ID de relación = 20');
    });

    testWidgets('Escenario: Prevención de bucle infinito en login', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));
      print('✓ Given: Estoy en la pantalla de login');

      // When: Ingreso credenciales válidas y hago login
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.pump();
      await tester.enterText(passwordField, 'casa1234');
      await tester.pump();

      final loginButton = find.text('sign in');
      await tester.tap(loginButton);
      print('✓ When: Hago login exitoso');

      // Then: No debería volver a la pantalla de login automáticamente
      await tester.pumpAndSettle(
        Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        Duration(seconds: 15),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Login), findsNothing);
      print('✓ Then: No vuelvo a login');

      // And: Debería permanecer en la pantalla de inicio
      await tester.pump(Duration(seconds: 3));
      expect(find.byType(HomeScreen), findsOneWidget);
      print('✓ And: Permanezco en HomeScreen');

      // And: No debería ver parpadeos entre pantallas
      bool hasFlickered = false;
      for (int i = 0; i < 5; i++) {
        await tester.pump(Duration(milliseconds: 500));
        if (find.byType(Login).evaluate().isNotEmpty) {
          hasFlickered = true;
          break;
        }
      }
      expect(hasFlickered, false);
      print('✓ And: No hay parpadeos entre pantallas');
    });

    testWidgets('Escenario: Navegación a recuperación de contraseña', (WidgetTester tester) async {
      // Given: Estoy en la pantalla de login
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));
      print('✓ Given: Estoy en la pantalla de login');

      // When: Presiono el enlace "¿Olvidaste tu contraseña?"
      final forgotPasswordLink = find.text('Forgot_password');
      if (forgotPasswordLink.evaluate().isNotEmpty) {
        await tester.tap(forgotPasswordLink);
        await tester.pumpAndSettle();
        print('✓ When: Presiono enlace de recuperación');

        // Then: Debería ver la pantalla de recuperación de contraseña
        expect(find.byType(Login), findsNothing);
        print('✓ Then: Navego fuera de login');
      }
    });
  });
}