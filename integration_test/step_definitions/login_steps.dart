import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:eta_school_app/services/storage_service.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';

/// Step: Dado que la aplicación está iniciada
class AppIsRunning extends GivenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // La aplicación ya está ejecutándose en el test
    await world.appDriver.waitForAppToSettle();
  }

  @override
  RegExp get pattern => RegExp(r'que la aplicación está iniciada');
}

/// Step: Y no hay sesión activa
class NoActiveSession extends Given1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String input) async {
    // Limpiar cualquier sesión existente
    await StorageService.instance.clearUserSession();
    await world.appDriver.waitForAppToSettle();
  }

  @override
  RegExp get pattern => RegExp(r'no hay sesión activa');
}

/// Step: Dado que estoy en la pantalla de login
class OnLoginScreen extends GivenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Verificar que estamos en la pantalla de login
    await world.appDriver.waitForAppToSettle();

    final loginFinder = find.byType(Login);
    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(loginFinder),
    );

    expect(await world.appDriver.isPresent(loginFinder), true,
        reason: 'No se encontró la pantalla de login');
  }

  @override
  RegExp get pattern => RegExp(r'que estoy en la pantalla de login');
}

/// Step: Cuando ingreso "{email}" en el campo de correo
class EnterEmail extends When2WithWorld<String, String, FlutterWorld> {
  @override
  Future<void> executeStep(String email, String fieldName) async {
    // Buscar el campo de email
    final emailFieldFinder = find.byType(TextField).first;

    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(emailFieldFinder),
    );

    await world.appDriver.tap(emailFieldFinder);
    await world.appDriver.enterText(emailFieldFinder, email);
    await world.appDriver.waitForAppToSettle();
  }

  @override
  RegExp get pattern =>
      RegExp(r'ingreso {string} en el campo de correo');
}

/// Step: Y ingreso "{password}" en el campo de contraseña
class EnterPassword extends When2WithWorld<String, String, FlutterWorld> {
  @override
  Future<void> executeStep(String password, String fieldName) async {
    // Buscar el campo de contraseña
    final passwordFieldFinder = find.byType(TextFormField);

    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(passwordFieldFinder),
    );

    await world.appDriver.tap(passwordFieldFinder);
    await world.appDriver.enterText(passwordFieldFinder, password);
    await world.appDriver.waitForAppToSettle();
  }

  @override
  RegExp get pattern =>
      RegExp(r'ingreso {string} en el campo de contraseña');
}

/// Step: Y presiono el botón de "Ingresar"
class PressLoginButton extends WhenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Buscar el botón de login por su texto
    final loginButtonFinder = find.text('sign in');

    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(loginButtonFinder),
    );

    await world.appDriver.tap(loginButtonFinder);

    // Esperar un poco más para el proceso de login
    await Future.delayed(Duration(seconds: 3));
    await world.appDriver.waitForAppToSettle();
  }

  @override
  RegExp get pattern => RegExp(r'presiono el botón de "(.*)"');
}

/// Step: Entonces debería ver la pantalla de inicio
class ShouldSeeHomeScreen extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Esperar a que aparezca la pantalla de inicio
    final homeScreenFinder = find.byType(HomeScreen);

    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(homeScreenFinder),
      timeout: Duration(seconds: 10),
    );

    expect(await world.appDriver.isPresent(homeScreenFinder), true,
        reason: 'No se encontró la pantalla de inicio');
  }

  @override
  RegExp get pattern => RegExp(r'debería ver la pantalla de inicio');
}

/// Step: Y debería estar autenticado como "{userName}"
class ShouldBeAuthenticatedAs extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String userName) async {
    // Verificar que el usuario está autenticado
    final session = await StorageService.instance.getUserSession();

    expect(session, isNotNull,
        reason: 'No hay sesión de usuario activa');
    expect(session!['nom_usu'], contains(userName),
        reason: 'El nombre de usuario no coincide');
  }

  @override
  RegExp get pattern =>
      RegExp(r'debería estar autenticado como {string}');
}

/// Step: Y mi rol debería ser "{role}"
class MyRoleShouldBe extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String role) async {
    // Verificar el rol del usuario
    final session = await StorageService.instance.getUserSession();

    expect(session, isNotNull,
        reason: 'No hay sesión de usuario activa');
    expect(session!['relation_name'], equals(role),
        reason: 'El rol del usuario no coincide');
  }

  @override
  RegExp get pattern => RegExp(r'mi rol debería ser {string}');
}

/// Step: Entonces debería ver un mensaje de error
class ShouldSeeErrorMessage extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Buscar el mensaje de error
    final errorDialogFinder = find.text('Error');

    await world.appDriver.waitUntil(
      () async => await world.appDriver.isPresent(errorDialogFinder),
      timeout: Duration(seconds: 5),
    );

    expect(await world.appDriver.isPresent(errorDialogFinder), true,
        reason: 'No se encontró mensaje de error');
  }

  @override
  RegExp get pattern => RegExp(r'debería ver un mensaje de error');
}

/// Step: Y el mensaje debería contener "{text}"
class MessageShouldContain extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String text) async {
    // Buscar texto específico en el mensaje
    final textFinder = find.textContaining(text);

    expect(await world.appDriver.isPresent(textFinder), true,
        reason: 'No se encontró el texto "$text" en el mensaje');
  }

  @override
  RegExp get pattern =>
      RegExp(r'el mensaje debería contener {string}');
}

/// Step: Y debería permanecer en la pantalla de login
class ShouldRemainOnLoginScreen extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Verificar que seguimos en la pantalla de login
    final loginScreenFinder = find.byType(Login);

    expect(await world.appDriver.isPresent(loginScreenFinder), true,
        reason: 'No estamos en la pantalla de login');
  }

  @override
  RegExp get pattern =>
      RegExp(r'debería permanecer en la pantalla de login');
}

/// Step: Entonces el token de sesión debería estar guardado en el almacenamiento local
class TokenShouldBeSaved extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Verificar que el token está guardado
    final token = await StorageService.instance.getString('token');

    expect(token, isNotNull,
        reason: 'El token no está guardado');
    expect(token!.length, greaterThan(20),
        reason: 'El token parece inválido');
  }

  @override
  RegExp get pattern =>
      RegExp(r'el token de sesión debería estar guardado en el almacenamiento local');
}

/// Step: Y el id de usuario debería ser {userId}
class UserIdShouldBe extends Then1WithWorld<int, FlutterWorld> {
  @override
  Future<void> executeStep(int userId) async {
    // Verificar el ID del usuario
    final storedUserId = await StorageService.instance.getInt('id_usu');

    expect(storedUserId, equals(userId),
        reason: 'El ID de usuario no coincide');
  }

  @override
  RegExp get pattern =>
      RegExp(r'el id de usuario debería ser {int}');
}

/// Step: Y el nombre de relación debería ser "{relationName}"
class RelationNameShouldBe extends Then1WithWorld<String, FlutterWorld> {
  @override
  Future<void> executeStep(String relationName) async {
    // Verificar el nombre de relación
    final storedRelationName = await StorageService.instance.getString('relation_name');

    expect(storedRelationName, equals(relationName),
        reason: 'El nombre de relación no coincide');
  }

  @override
  RegExp get pattern =>
      RegExp(r'el nombre de relación debería ser {string}');
}

/// Step: Y el id de relación debería ser {relationId}
class RelationIdShouldBe extends Then1WithWorld<int, FlutterWorld> {
  @override
  Future<void> executeStep(int relationId) async {
    // Verificar el ID de relación
    final storedRelationId = await StorageService.instance.getInt('relation_id');

    expect(storedRelationId, equals(relationId),
        reason: 'El ID de relación no coincide');
  }

  @override
  RegExp get pattern =>
      RegExp(r'el id de relación debería ser {int}');
}

/// Step: Entonces no debería volver a la pantalla de login automáticamente
class ShouldNotReturnToLogin extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Esperar un poco para verificar que no hay navegación automática
    await Future.delayed(Duration(seconds: 3));

    // Verificar que NO estamos en la pantalla de login
    final loginScreenFinder = find.byType(Login);

    expect(await world.appDriver.isPresent(loginScreenFinder), false,
        reason: 'Volvimos a la pantalla de login inesperadamente');
  }

  @override
  RegExp get pattern =>
      RegExp(r'no debería volver a la pantalla de login automáticamente');
}

/// Step: Y debería permanecer en la pantalla de inicio
class ShouldStayOnHomeScreen extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Verificar que seguimos en la pantalla de inicio
    final homeScreenFinder = find.byType(HomeScreen);

    expect(await world.appDriver.isPresent(homeScreenFinder), true,
        reason: 'No estamos en la pantalla de inicio');
  }

  @override
  RegExp get pattern =>
      RegExp(r'debería permanecer en la pantalla de inicio');
}

/// Step: Y no debería ver parpadeos entre pantallas
class ShouldNotSeeFlickering extends ThenWithWorld<FlutterWorld> {
  @override
  Future<void> executeStep() async {
    // Monitorear cambios de pantalla durante 2 segundos
    bool hasFlickered = false;
    final homeScreenFinder = find.byType(HomeScreen);
    final loginScreenFinder = find.byType(Login);

    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(milliseconds: 200));

      final hasHome = await world.appDriver.isPresent(homeScreenFinder);
      final hasLogin = await world.appDriver.isPresent(loginScreenFinder);

      if (hasLogin) {
        hasFlickered = true;
        break;
      }
    }

    expect(hasFlickered, false,
        reason: 'Se detectó parpadeo entre pantallas');
  }

  @override
  RegExp get pattern =>
      RegExp(r'no debería ver parpadeos entre pantallas');
}