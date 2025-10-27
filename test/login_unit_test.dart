import 'package:flutter_test/flutter_test.dart';
import 'package:eta_school_app/API/client.dart';

void main() {
  group('Login Unit Tests', () {
    late HttpService httpService;

    setUp(() {
      httpService = HttpService();
    });

    test('Login exitoso retorna "1"', () async {
      // Credenciales de prueba
      const email = 'etalatam+representante1@gmail.com';
      const password = 'casa1234';

      print('Probando login con credenciales:');
      print('Email: $email');
      print('Password: [OCULTO]');

      // Ejecutar login real (requiere conexión a internet)
      final result = await httpService.login(email, password);

      // El login exitoso debe retornar "1"
      expect(result, '1', reason: 'Login exitoso debe retornar "1"');
      print('✓ Login exitoso verificado');
    });

    test('Login con credenciales inválidas no retorna "1"', () async {
      // Credenciales incorrectas
      const email = 'usuario.invalido@test.com';
      const password = 'password_incorrecta';

      print('Probando login con credenciales inválidas...');

      // Ejecutar login con credenciales incorrectas
      final result = await httpService.login(email, password);

      // El login fallido NO debe retornar "1"
      expect(result, isNot('1'), reason: 'Login fallido no debe retornar "1"');
      print('✓ Login fallido verificado correctamente');
    });

    test('Login con timeout se maneja correctamente', () async {
      // Credenciales de prueba
      const email = 'etalatam+representante1@gmail.com';
      const password = 'casa1234';

      print('Probando manejo de timeout en login...');

      // Medir tiempo de ejecución
      final stopwatch = Stopwatch()..start();

      try {
        // Ejecutar login con timeout
        final result = await httpService.login(email, password)
            .timeout(Duration(seconds: 10));

        stopwatch.stop();
        print('Login completado en ${stopwatch.elapsed.inSeconds} segundos');

        // Verificar que completó dentro del timeout
        expect(stopwatch.elapsed.inSeconds, lessThanOrEqualTo(10),
            reason: 'Login debe completarse dentro de 10 segundos');

        // Si tuvo éxito, debe ser "1"
        if (result == '1') {
          print('✓ Login exitoso dentro del timeout');
        } else {
          print('✓ Login falló pero se manejó dentro del timeout');
        }
      } catch (e) {
        stopwatch.stop();

        // Si hay timeout, verificar que fue después de 10 segundos
        if (e.toString().contains('TimeoutException')) {
          expect(stopwatch.elapsed.inSeconds, greaterThanOrEqualTo(9),
              reason: 'Timeout debe ocurrir cerca de los 10 segundos');
          print('✓ Timeout manejado correctamente');
        } else {
          // Otro error
          print('Error inesperado: $e');
          fail('Error inesperado durante el login');
        }
      }
    });

    test('Validación de campos de login', () {
      // Validar email vacío
      expect(
        () => _validateEmail(''),
        throwsA(isA<ArgumentError>()),
        reason: 'Email vacío debe lanzar error',
      );
      print('✓ Validación de email vacío');

      // Validar email inválido
      expect(
        () => _validateEmail('email_invalido'),
        throwsA(isA<ArgumentError>()),
        reason: 'Email sin @ debe lanzar error',
      );
      print('✓ Validación de formato de email');

      // Validar password vacío
      expect(
        () => _validatePassword(''),
        throwsA(isA<ArgumentError>()),
        reason: 'Password vacío debe lanzar error',
      );
      print('✓ Validación de password vacío');

      // Validar password muy corto
      expect(
        () => _validatePassword('123'),
        throwsA(isA<ArgumentError>()),
        reason: 'Password muy corto debe lanzar error',
      );
      print('✓ Validación de longitud de password');

      // Validar credenciales correctas
      expect(
        _validateEmail('etalatam+representante1@gmail.com'),
        true,
        reason: 'Email válido debe pasar validación',
      );
      expect(
        _validatePassword('casa1234'),
        true,
        reason: 'Password válido debe pasar validación',
      );
      print('✓ Validación de credenciales correctas');
    });
  });
}

// Funciones de validación auxiliares
bool _validateEmail(String email) {
  if (email.isEmpty) {
    throw ArgumentError('Email no puede estar vacío');
  }
  if (!email.contains('@')) {
    throw ArgumentError('Email debe contener @');
  }
  return true;
}

bool _validatePassword(String password) {
  if (password.isEmpty) {
    throw ArgumentError('Password no puede estar vacío');
  }
  if (password.length < 6) {
    throw ArgumentError('Password debe tener al menos 6 caracteres');
  }
  return true;
}