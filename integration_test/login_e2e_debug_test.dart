import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eta_school_app/main.dart' as app;
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/controllers/helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login E2E Debug Test - Credenciales Reales', () {
    // Credenciales de prueba reales
    const testEmail = 'etalatam+representante1@gmail.com';
    const testPassword = 'casa1234';

    testWidgets('Test E2E completo del flujo de login con diagnóstico',
        (WidgetTester tester) async {
      print('\n==========================================');
      print('INICIANDO TEST E2E DE LOGIN');
      print('==========================================\n');

      // Limpiar storage antes de iniciar
      print('[1/10] Limpiando storage antes del test...');
      await storage.clear();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      print('✓ Storage limpiado\n');

      // Iniciar la aplicación
      print('[2/10] Iniciando la aplicación...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      print('✓ Aplicación iniciada\n');

      // Verificar que estamos en la página de login
      print('[3/10] Verificando página de login...');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final loginPage = find.byType(Login);
      expect(loginPage, findsOneWidget, reason: 'Debe mostrar la página de login');
      print('✓ Página de login encontrada\n');

      // Verificar campos de entrada
      print('[4/10] Buscando campos de entrada...');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      final textFields = find.byType(TextField);
      print('   Campos TextField encontrados: ${tester.widgetList(textFields).length}');

      final textFormFields = find.byType(TextFormField);
      print('   Campos TextFormField encontrados: ${tester.widgetList(textFormFields).length}');

      // El email es TextField y el password es TextFormField
      expect(textFields, findsWidgets, reason: 'Debe haber campo de email');
      expect(textFormFields, findsWidgets, reason: 'Debe haber campo de password');
      print('✓ Campos de entrada encontrados\n');

      // Ingresar email
      print('[5/10] Ingresando email: $testEmail');
      final emailField = textFields.first;
      await tester.tap(emailField);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.enterText(emailField, testEmail);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      print('✓ Email ingresado\n');

      // Ingresar password
      print('[6/10] Ingresando password...');
      final passwordField = textFormFields.first;
      await tester.tap(passwordField);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      print('✓ Password ingresado\n');

      // Verificar el storage antes del login
      print('[7/10] Verificando storage ANTES del login...');
      final tokenBefore = await storage.getItem('token');
      final relationNameBefore = await storage.getItem('relation_name');
      final idUsuBefore = await storage.getItem('id_usu');
      print('   Token antes: ${tokenBefore ?? "NULL"}');
      print('   relation_name antes: ${relationNameBefore ?? "NULL"}');
      print('   id_usu antes: ${idUsuBefore ?? "NULL"}\n');

      // Buscar y presionar el botón de login (GestureDetector con texto "Ingresar")
      print('[8/10] Buscando y presionando botón de login...');
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Buscar el texto "Ingresar" o traducción equivalente
      final ingregarButton = find.text('Ingresar');
      if (tester.any(ingregarButton)) {
        print('   Botón "Ingresar" encontrado');
        await tester.tap(ingregarButton);
      } else {
        // Fallback: buscar cualquier GestureDetector que contenga Text
        print('   Buscando botón alternativo...');
        final buttons = find.byType(GestureDetector);
        bool found = false;
        for (int i = 0; i < tester.widgetList(buttons).length; i++) {
          final button = buttons.at(i);
          final widget = tester.widget<GestureDetector>(button);
          if (widget.child is Text || (widget.child is Container)) {
            print('   Intentando con botón en posición $i');
            await tester.tap(button);
            found = true;
            break;
          }
        }
        expect(found, true, reason: 'Debe encontrar el botón de login');
      }

      print('✓ Botón de login presionado\n');
      print('[9/10] Esperando respuesta del login (máximo 20 segundos)...');

      // Esperar con logging detallado
      bool loginCompleted = false;
      int waitedSeconds = 0;
      const maxWait = 20;

      while (waitedSeconds < maxWait && !loginCompleted) {
        await tester.pump(const Duration(seconds: 1));
        waitedSeconds++;

        // Verificar si llegamos a HomeScreen
        final homeScreen = find.byType(HomeScreen);
        if (tester.any(homeScreen)) {
          loginCompleted = true;
          print('   ✓ HomeScreen detectado después de $waitedSeconds segundos');
        } else if (waitedSeconds % 3 == 0) {
          // Cada 3 segundos, mostrar progreso
          print('   ... esperando ($waitedSeconds/$maxWait segundos)');

          // Verificar storage intermedio
          final tokenTemp = await storage.getItem('token');
          final relationNameTemp = await storage.getItem('relation_name');
          if (tokenTemp != null) {
            print('   >>> Token detectado en storage!');
          }
          if (relationNameTemp != null) {
            print('   >>> relation_name detectado: $relationNameTemp');
          }
        }
      }

      print('');

      // Verificar storage DESPUÉS del login
      print('[10/10] Verificando storage DESPUÉS del login...');
      final tokenAfter = await storage.getItem('token');
      final relationNameAfter = await storage.getItem('relation_name');
      final relationIdAfter = await storage.getItem('relation_id');
      final idUsuAfter = await storage.getItem('id_usu');
      final nomUsuAfter = await storage.getItem('nom_usu');
      final monitorAfter = await storage.getItem('monitor');

      print('   Token: ${tokenAfter ?? "NULL"}');
      print('   relation_name: ${relationNameAfter ?? "NULL"}');
      print('   relation_id: ${relationIdAfter ?? "NULL"}');
      print('   id_usu: ${idUsuAfter ?? "NULL"}');
      print('   nom_usu: ${nomUsuAfter ?? "NULL"}');
      print('   monitor: ${monitorAfter ?? "NULL"}\n');

      // DIAGNÓSTICO: Verificar qué falta
      print('==========================================');
      print('DIAGNÓSTICO DE DATOS');
      print('==========================================');

      List<String> missingData = [];
      if (tokenAfter == null) missingData.add('token');
      if (relationNameAfter == null) missingData.add('relation_name');
      if (idUsuAfter == null) missingData.add('id_usu');

      if (missingData.isNotEmpty) {
        print('⚠️  DATOS FALTANTES: ${missingData.join(", ")}');
        print('   Esto puede causar que el login se quede pegado!\n');
      } else {
        print('✅ Todos los datos necesarios están presentes\n');
      }

      // Verificar resultado final
      if (loginCompleted) {
        print('==========================================');
        print('✅ TEST EXITOSO');
        print('==========================================');
        print('El login funcionó correctamente y navegó a HomeScreen\n');

        // Verificar que HomeScreen está visible
        expect(find.byType(HomeScreen), findsOneWidget,
            reason: 'Debe estar en HomeScreen');

        // Verificar que Login no está visible
        expect(find.byType(Login), findsNothing,
            reason: 'No debe estar en Login');

        // Verificar bottom navigation
        expect(find.byType(BottomNavigationBar), findsOneWidget,
            reason: 'Debe mostrar el navigation bar');

      } else {
        print('==========================================');
        print('❌ TEST FALLIDO');
        print('==========================================');
        print('El login NO navegó a HomeScreen después de $maxWait segundos');
        print('Verificar logs arriba para identificar el problema\n');

        // Verificar si todavía estamos en Login
        final stillInLogin = find.byType(Login);
        if (tester.any(stillInLogin)) {
          print('⚠️  El usuario sigue en la página de login (PROBLEMA)');
        }

        fail('Login no completó dentro del tiempo esperado');
      }
    });

    testWidgets('Verificar comportamiento de checkSession',
        (WidgetTester tester) async {
      print('\n==========================================');
      print('TEST: Verificar checkSession()');
      print('==========================================\n');

      // Simular datos guardados manualmente
      print('Guardando datos de prueba en storage...');
      await storage.setItem('token', 'test_token_123');
      await storage.setItem('id_usu', '123');
      await storage.setItem('relation_name', 'eta.guardians');
      print('✓ Datos guardados\n');

      // Iniciar app
      print('Iniciando aplicación con sesión existente...');
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verificar que va directo a HomeScreen
      print('Verificando navegación automática...');
      final homeScreen = find.byType(HomeScreen);

      if (tester.any(homeScreen)) {
        print('✅ Navegó correctamente a HomeScreen con sesión existente');
        expect(homeScreen, findsOneWidget);
      } else {
        print('❌ No navegó a HomeScreen a pesar de tener sesión');
        print('Verificando si está en Login...');
        final login = find.byType(Login);
        if (tester.any(login)) {
          print('⚠️  Está en Login (no debería)');
        }
        fail('No navegó a HomeScreen con sesión existente');
      }

      // Limpiar
      await storage.clear();
      print('\n✓ Storage limpiado\n');
    });
  });
}
