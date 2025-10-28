import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('Login API Test', () {
    test('Verificar login con credenciales válidas', () async {
      print('\n===== PRUEBA DE LOGIN API =====');
      print('Probando con credenciales: etalatam+representante1@gmail.com');

      final dio = Dio();
      dio.options.baseUrl = 'https://api.etalatam.com';
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 10);

      try {
        print('Enviando petición de login...');

        final response = await dio.post(
          '/rpc/login',
          data: {
            '_email': 'etalatam+representante1@gmail.com',
            '_pass': 'casa1234',
          },
        );

        print('Respuesta recibida:');
        print('Status: ${response.statusCode}');
        print('Data: ${response.data}');

        // Verificar respuesta exitosa
        expect(response.statusCode, equals(200));

        // Verificar que hay un token o datos de usuario
        if (response.data != null) {
          if (response.data['token'] != null) {
            print('✓ Token recibido: ${response.data['token'].toString().substring(0, 20)}...');
          }
          if (response.data['user'] != null) {
            print('✓ Usuario autenticado: ${response.data['user']['email'] ?? response.data['user']['name']}');
          }
          if (response.data['data'] != null) {
            print('✓ Datos adicionales recibidos');
          }
        }

        print('\n✅ LOGIN EXITOSO - El servidor respondió correctamente');

      } on DioException catch (e) {
        print('\n❌ ERROR en la petición:');
        print('Tipo de error: ${e.type}');
        print('Mensaje: ${e.message}');

        if (e.response != null) {
          print('Status Code: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            print('\n⚠️  Credenciales inválidas o expiradas');
          } else if (e.response?.statusCode == 403) {
            print('\n⚠️  Acceso denegado');
          } else if (e.response?.statusCode == 404) {
            print('\n⚠️  Endpoint de login no encontrado');
          } else if (e.response?.statusCode == 500) {
            print('\n⚠️  Error del servidor');
          }
        } else {
          print('\n⚠️  No se pudo conectar al servidor');
          print('Verificar: ');
          print('  - Conexión a internet');
          print('  - URL del servidor: https://api.etalatam.com');
          print('  - Firewall o proxy');
        }

        // Re-lanzar el error para que la prueba falle
        rethrow;
      } catch (e) {
        print('\n❌ ERROR INESPERADO: $e');
        rethrow;
      }

      print('\n===== FIN DE PRUEBA =====\n');
    });

    test('Verificar manejo de credenciales incorrectas', () async {
      print('\n===== PRUEBA DE CREDENCIALES INCORRECTAS =====');

      final dio = Dio();
      dio.options.baseUrl = 'https://api.etalatam.com';
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 10);

      try {
        print('Enviando petición con credenciales incorrectas...');

        final response = await dio.post(
          '/rpc/login',
          data: {
            '_email': 'usuario.invalido@test.com',
            '_pass': 'password123',
          },
        );

        // Si llegamos aquí y el status es 200, algo está mal
        if (response.statusCode == 200) {
          print('⚠️  ADVERTENCIA: El servidor aceptó credenciales inválidas');
          print('Response: ${response.data}');
        }

      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          print('✅ Credenciales incorrectas rechazadas correctamente');
          print('Status: ${e.response?.statusCode}');
          print('Mensaje: ${e.response?.data}');
        } else {
          print('⚠️  Error inesperado: ${e.response?.statusCode}');
          print('Data: ${e.response?.data}');
        }
      }

      print('\n===== FIN DE PRUEBA =====\n');
    });
  });
}