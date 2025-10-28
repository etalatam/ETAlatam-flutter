import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/main.dart' as app;
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:localstorage/localstorage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Tests', () {
    final LocalStorage storage = LocalStorage('tokens.json');

    setUp(() async {
      // Limpiar storage antes de cada test
      await storage.ready;
      await storage.clear();
    });

    testWidgets('Login screen should display correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar que estamos en la pantalla de login
      expect(find.byType(Login), findsOneWidget);

      // Verificar elementos de la UI
      expect(find.text('Welcome Back👋'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('sign in'), findsOneWidget);
      expect(find.text('Forgot_password'), findsOneWidget);
    });

    testWidgets('Should show error on invalid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar campos de entrada
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextFormField);

      // Ingresar credenciales inválidas
      await tester.enterText(emailField, 'invalid@email.com');
      await tester.enterText(passwordField, 'wrongpassword');

      // Tap en el botón de login
      await tester.tap(find.text('sign in'));
      await tester.pump(Duration(seconds: 2));

      // Verificar que aparece el diálogo de error
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('Should navigate to home after successful login', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar campos de entrada
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextFormField);

      // Ingresar credenciales válidas
      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.enterText(passwordField, 'casa1234');

      // Tap en el botón de login
      await tester.tap(find.text('sign in'));

      // Esperar la respuesta del servidor
      await tester.pump(Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verificar que navegamos a HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Verificar que el token fue guardado
      final token = await storage.getItem('token');
      expect(token, isNotNull);
      expect(token, isNotEmpty);
    });

    testWidgets('Should handle login timeout gracefully', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar campos de entrada
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextFormField);

      // Ingresar credenciales
      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'testpass');

      // Tap en el botón de login
      await tester.tap(find.text('sign in'));

      // Esperar timeout (10 segundos según el código)
      await tester.pump(Duration(seconds: 11));

      // Verificar que se muestra el mensaje de error de conexión
      expect(find.text('Connection error. Please try again.'), findsOneWidget);
    });

    testWidgets('Login flow should not loop infinitely', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Guardar un token válido simulado
      await storage.setItem('token', 'test-token-123');
      await storage.setItem('id_usu', '123');

      // Reiniciar la app
      app.main();
      await tester.pumpAndSettle();

      // Debería navegar directamente a HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Login), findsNothing);
    });

    testWidgets('Should handle 401 error correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Encontrar campos de entrada
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextFormField);

      // Ingresar credenciales que causan 401
      await tester.enterText(emailField, 'test@test.com');
      await tester.enterText(passwordField, 'testpass');

      // Tap en el botón de login
      await tester.tap(find.text('sign in'));
      await tester.pump(Duration(seconds: 2));

      // Verificar que se muestra el error 401
      expect(find.textContaining('401'), findsOneWidget);
    });
  });

  group('Navigation After Login Tests', () {
    testWidgets('Driver should see DriverHome', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simular login de conductor
      final storage = LocalStorage('tokens.json');
      await storage.ready;
      await storage.setItem('token', 'driver-token');
      await storage.setItem('id_usu', '1');
      await storage.setItem('relation_name', 'eta.drivers');

      // Navegar a HomeScreen
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen())
      );
      await tester.pumpAndSettle();

      // Verificar que se muestra el home del conductor
      expect(find.text('DriverHome'), findsOneWidget);
    });

    testWidgets('Student should see StudentsHome', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simular login de estudiante
      final storage = LocalStorage('tokens.json');
      await storage.ready;
      await storage.setItem('token', 'student-token');
      await storage.setItem('id_usu', '2');
      await storage.setItem('relation_name', 'eta.students');

      // Navegar a HomeScreen
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen())
      );
      await tester.pumpAndSettle();

      // Verificar que se muestra el home del estudiante
      expect(find.text('StudentsHome'), findsOneWidget);
    });

    testWidgets('Guardian should see GuardiansHome', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simular login de guardian
      final storage = LocalStorage('tokens.json');
      await storage.ready;
      await storage.setItem('token', 'guardian-token');
      await storage.setItem('id_usu', '3');
      await storage.setItem('relation_name', 'eta.guardians');

      // Navegar a HomeScreen
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen())
      );
      await tester.pumpAndSettle();

      // Verificar que se muestra el home del guardian
      expect(find.text('GuardiansHome'), findsOneWidget);
    });
  });
}