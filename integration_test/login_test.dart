import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eta_school_app/main.dart' as app;
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration Tests', () {
    // Credenciales de prueba
    const testEmail = 'etalatam+representante1@gmail.com';
    const testPassword = 'casa1234';

    testWidgets('Login exitoso y navegación a HomeScreen', (WidgetTester tester) async {
      // Iniciar la aplicación
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que estamos en la página de login
      expect(find.byType(Login), findsOneWidget);
      print('✓ Página de login cargada correctamente');

      // Buscar los campos de email y password
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Verificar que los campos existen
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      print('✓ Campos de email y password encontrados');

      // Ingresar credenciales
      await tester.enterText(emailField, testEmail);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      print('✓ Credenciales ingresadas');

      // Buscar y presionar el botón de login
      final loginButton = find.byType(GestureDetector).where((finder) {
        final widget = tester.widget(finder);
        if (widget is GestureDetector) {
          final child = widget.child;
          if (child is Text) {
            return child.data?.toLowerCase().contains('sign') ?? false;
          }
        }
        return false;
      });

      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      print('✓ Botón de login presionado');

      // Esperar a que el login se procese (con timeout de seguridad)
      await tester.pumpAndSettle(const Duration(seconds: 15));

      // Verificar que navegamos a HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      print('✓ Navegación exitosa a HomeScreen');

      // Verificar que el Login ya no está visible
      expect(find.byType(Login), findsNothing);
      print('✓ Página de login ya no está visible');

      // Verificar elementos del HomeScreen
      // Esperamos encontrar el bottom navigation bar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      print('✓ BottomNavigationBar encontrado en HomeScreen');

      print('\n✅ Prueba completada exitosamente');
    });

    testWidgets('Login con credenciales inválidas muestra error', (WidgetTester tester) async {
      // Iniciar la aplicación
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que estamos en la página de login
      expect(find.byType(Login), findsOneWidget);

      // Buscar los campos
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Ingresar credenciales incorrectas
      await tester.enterText(emailField, 'usuario.invalido@test.com');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.enterText(passwordField, 'password_incorrecta');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Buscar y presionar el botón de login
      final loginButton = find.byType(GestureDetector).where((finder) {
        final widget = tester.widget(finder);
        if (widget is GestureDetector) {
          final child = widget.child;
          if (child is Text) {
            return child.data?.toLowerCase().contains('sign') ?? false;
          }
        }
        return false;
      });

      await tester.tap(loginButton);
      print('✓ Intento de login con credenciales inválidas');

      // Esperar respuesta del servidor
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verificar que seguimos en la página de login
      expect(find.byType(Login), findsOneWidget);
      print('✓ Permanecemos en página de login tras error');

      // Verificar que NO navegamos a HomeScreen
      expect(find.byType(HomeScreen), findsNothing);
      print('✓ No se navegó a HomeScreen con credenciales inválidas');

      print('\n✅ Prueba de error completada exitosamente');
    });

    testWidgets('Verificar timeout de login no bloquea la app', (WidgetTester tester) async {
      // Iniciar la aplicación
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verificar que estamos en la página de login
      expect(find.byType(Login), findsOneWidget);
      print('✓ Página de login cargada');

      // Buscar los campos
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;

      // Ingresar credenciales de prueba
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      print('✓ Credenciales ingresadas');

      // Buscar y presionar el botón de login
      final loginButton = find.byType(GestureDetector).where((finder) {
        final widget = tester.widget(finder);
        if (widget is GestureDetector) {
          final child = widget.child;
          if (child is Text) {
            return child.data?.toLowerCase().contains('sign') ?? false;
          }
        }
        return false;
      });

      await tester.tap(loginButton);
      print('✓ Login iniciado');

      // Esperar máximo 15 segundos (nuestro timeout es de 10s + navegación)
      bool loginCompleted = false;
      int waitedSeconds = 0;

      while (waitedSeconds < 15 && !loginCompleted) {
        await tester.pump(const Duration(seconds: 1));
        waitedSeconds++;

        // Verificar si navegamos a HomeScreen
        if (tester.any(find.byType(HomeScreen))) {
          loginCompleted = true;
          print('✓ Login completado en $waitedSeconds segundos');
        }
      }

      // Verificar que el login se completó dentro del timeout
      expect(loginCompleted, true,
        reason: 'El login debe completarse dentro de 15 segundos');

      print('\n✅ Prueba de timeout completada exitosamente');
    });
  });
}