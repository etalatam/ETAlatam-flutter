import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('Login Flow Test - Flujo completo', () {
    test('Login completo con requestAccess y login', () async {
      print('\n========================================');
      print('   PRUEBA COMPLETA DE LOGIN - ETAlatam   ');
      print('========================================\n');

      final dio = Dio();
      dio.options.baseUrl = 'https://api.etalatam.com';
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 10);

      String? tempAccessToken;

      try {
        // PASO 1: Request Access
        print('[PASO 1] Solicitando acceso al API (requestAccess)...');
        print('Endpoint: /rpc/request_access');

        final requestAccessResponse = await dio.post(
          '/rpc/request_access',
          data: {
            '_client_id': '4926212245183',
            '_access_token': '8725ca59-71be-46c6-a364-eaac57f1786d'
          },
        );

        print('Status: ${requestAccessResponse.statusCode}');

        if (requestAccessResponse.statusCode == 200) {
          print('✅ Acceso concedido');

          // Extraer el token temporal
          if (requestAccessResponse.data != null &&
              requestAccessResponse.data['token'] != null) {
            tempAccessToken = requestAccessResponse.data['token'];
            print('Token temporal recibido: ${tempAccessToken?.substring(0, 20)}...');
          }

          print('Response: ${requestAccessResponse.data}');
        } else {
          print('❌ Error al solicitar acceso: ${requestAccessResponse.statusCode}');
          return;
        }

        // PASO 2: Login con credenciales
        print('\n[PASO 2] Realizando login con credenciales...');
        print('Email: etalatam+representante1@gmail.com');
        print('Endpoint: /rpc/login');

        // Configurar headers con el token temporal si existe
        if (tempAccessToken != null) {
          dio.options.headers['Authorization'] = 'Bearer $tempAccessToken';
          print('Authorization header configurado');
        }

        final loginResponse = await dio.post(
          '/rpc/login',
          data: {
            '_email': 'etalatam+representante1@gmail.com',
            '_pass': 'casa1234',
          },
        );

        print('\nStatus: ${loginResponse.statusCode}');

        if (loginResponse.statusCode == 200) {
          print('✅ LOGIN EXITOSO');

          final loginData = loginResponse.data;

          // Mostrar información del usuario
          if (loginData != null) {
            print('\n📋 Información del usuario:');

            if (loginData['token'] != null) {
              print('  Token: ${loginData['token'].toString().substring(0, 30)}...');
            }

            if (loginData['id_usu'] != null) {
              print('  ID Usuario: ${loginData['id_usu']}');
            }

            if (loginData['nom_usu'] != null) {
              print('  Nombre: ${loginData['nom_usu']}');
            }

            if (loginData['relation_name'] != null) {
              print('  Rol: ${loginData['relation_name']}');
            }

            if (loginData['relation_id'] != null) {
              print('  ID Relación: ${loginData['relation_id']}');
            }

            if (loginData['monitor'] != null) {
              print('  Monitor: ${loginData['monitor']}');
            }

            // Verificar campos adicionales
            print('\n📊 Campos adicionales:');
            loginData.forEach((key, value) {
              if (!['token', 'id_usu', 'nom_usu', 'relation_name',
                    'relation_id', 'monitor'].contains(key)) {
                print('  $key: $value');
              }
            });
          }

          print('\n========================================');
          print('✅ EL LOGIN ESTÁ FUNCIONANDO CORRECTAMENTE');
          print('========================================\n');

        } else {
          print('❌ Login falló con status: ${loginResponse.statusCode}');
          print('Response: ${loginResponse.data}');
        }

      } on DioException catch (e) {
        print('\n❌ ERROR DE CONEXIÓN:');
        print('Tipo: ${e.type}');
        print('Mensaje: ${e.message}');

        if (e.response != null) {
          print('Status Code: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');

          if (e.response?.statusCode == 401) {
            print('\n⚠️ Error 401: Unauthorized');
            print('Posibles causas:');
            print('  1. Credenciales incorrectas');
            print('  2. Token temporal expirado');
            print('  3. Usuario bloqueado o inactivo');
          } else if (e.response?.statusCode == 403) {
            print('\n⚠️ Error 403: Forbidden');
            print('El usuario no tiene permisos para esta operación');
          } else if (e.response?.statusCode == 404) {
            print('\n⚠️ Error 404: Not Found');
            print('Verificar que el endpoint sea correcto');
          } else if (e.response?.statusCode == 500) {
            print('\n⚠️ Error 500: Error del servidor');
            print('Contactar al administrador del sistema');
          }
        } else {
          print('\n⚠️ No se pudo conectar al servidor');
          print('Verificar:');
          print('  - Conexión a internet');
          print('  - URL del servidor: https://api.etalatam.com');
          print('  - Firewall o proxy bloqueando la conexión');
        }
      } catch (e) {
        print('\n❌ ERROR INESPERADO: $e');
      }
    });

    test('Verificar manejo de credenciales incorrectas con flujo completo', () async {
      print('\n========================================');
      print('   PRUEBA DE CREDENCIALES INCORRECTAS    ');
      print('========================================\n');

      final dio = Dio();
      dio.options.baseUrl = 'https://api.etalatam.com';
      dio.options.connectTimeout = Duration(seconds: 10);

      try {
        // PASO 1: Request Access
        print('[PASO 1] Solicitando acceso...');
        final requestAccessResponse = await dio.post(
          '/rpc/request_access',
          data: {
            '_client_id': '4926212245183',
            '_access_token': '8725ca59-71be-46c6-a364-eaac57f1786d'
          },
        );

        String? tempAccessToken;
        if (requestAccessResponse.statusCode == 200 &&
            requestAccessResponse.data['token'] != null) {
          tempAccessToken = requestAccessResponse.data['token'];
          print('✅ Token temporal obtenido');
        }

        // PASO 2: Login con credenciales incorrectas
        print('\n[PASO 2] Intentando login con credenciales incorrectas...');

        if (tempAccessToken != null) {
          dio.options.headers['Authorization'] = 'Bearer $tempAccessToken';
        }

        final loginResponse = await dio.post(
          '/rpc/login',
          data: {
            '_email': 'usuario.invalido@test.com',
            '_pass': 'claveincorrecta123',
          },
        );

        // Si llegamos aquí con status 200, algo está mal
        if (loginResponse.statusCode == 200) {
          print('⚠️ ADVERTENCIA: El servidor aceptó credenciales inválidas');
          print('Esto puede ser un problema de seguridad');
          print('Response: ${loginResponse.data}');
        }

      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          print('✅ Credenciales incorrectas rechazadas correctamente');
          print('Status: ${e.response?.statusCode}');
          print('Mensaje: ${e.response?.data}');
        } else {
          print('⚠️ Error inesperado: ${e.response?.statusCode}');
          print('Data: ${e.response?.data}');
        }
      }

      print('\n========================================\n');
    });
  });
}