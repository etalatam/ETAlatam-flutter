import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script de prueba para diagnosticar problemas de login
/// Ejecutar con: dart test_login_debug.dart
void main() async {
  print('=== Iniciando diagnóstico del flujo de login ===\n');

  const apiURL = 'https://api.etalatam.com';
  const clientId = '4926212245183';
  const accessToken = '8725ca59-71be-46c6-a364-eaac57f1786d';

  // Test 1: Verificar conectividad con el servidor
  print('[1] Verificando conectividad con el servidor...');
  try {
    final response = await http.get(Uri.parse(apiURL));
    print('   ✅ Servidor accesible. Status: ${response.statusCode}');
  } catch (e) {
    print('   ❌ Error de conectividad: $e');
    return;
  }

  // Test 2: Obtener token de acceso temporal
  print('\n[2] Obteniendo token de acceso temporal (request_access)...');
  String? tempToken;
  try {
    final requestAccessResponse = await http.post(
      Uri.parse('$apiURL/rpc/request_access'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        '_client_id': clientId,
        '_access_token': accessToken,
      },
    );

    print('   Status Code: ${requestAccessResponse.statusCode}');
    print('   Response Body: ${requestAccessResponse.body}');

    if (requestAccessResponse.statusCode == 200) {
      final body = jsonDecode(requestAccessResponse.body);
      tempToken = body['token'];
      print('   ✅ Token temporal obtenido: ${tempToken?.substring(0, 20)}...');
    } else {
      print('   ❌ Error al obtener token temporal');
      print('   Detalles: ${requestAccessResponse.body}');
      return;
    }
  } catch (e) {
    print('   ❌ Excepción: $e');
    return;
  }

  // Test 3: Intentar login con credenciales de prueba
  print('\n[3] Intentando login con credenciales...');
  const email = 'etalatam+representante1@gmail.com';
  const password = 'casa1234';

  try {
    final loginResponse = await http.post(
      Uri.parse('$apiURL/rpc/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $tempToken',
      },
      body: {
        '_email': email,
        '_pass': password,
      },
    );

    print('   Status Code: ${loginResponse.statusCode}');
    print('   Response Headers: ${loginResponse.headers}');

    if (loginResponse.statusCode == 200) {
      final body = jsonDecode(loginResponse.body);
      print('   ✅ Login exitoso!');
      print('   User ID: ${body['id_usu']}');
      print('   Relation Name: ${body['relation_name']}');
      print('   Token: ${body['token']?.substring(0, 20)}...');
    } else {
      print('   ❌ Error en login. Status: ${loginResponse.statusCode}');
      print('   Body: ${loginResponse.body}');

      // Intentar parsear el error
      try {
        final errorBody = jsonDecode(loginResponse.body);
        print('   Mensaje de error: ${errorBody['message'] ?? errorBody['details'] ?? errorBody['hint']}');
      } catch (_) {
        print('   No se pudo parsear el mensaje de error');
      }
    }
  } catch (e) {
    print('   ❌ Excepción durante el login: $e');
  }

  // Test 4: Verificar endpoint de usuario sin autenticación (debería dar 401)
  print('\n[4] Verificando comportamiento de endpoints protegidos...');
  try {
    final userInfoResponse = await http.post(
      Uri.parse('$apiURL/rpc/user_info'),
      headers: {'Content-Type': 'application/json'},
    );

    print('   Status Code sin token: ${userInfoResponse.statusCode}');
    if (userInfoResponse.statusCode == 401) {
      print('   ✅ Endpoint protegido correctamente (401 sin token)');
    }
  } catch (e) {
    print('   ❌ Error: $e');
  }

  // Test 5: Verificar con token temporal
  if (tempToken != null) {
    try {
      final userInfoWithTempToken = await http.post(
        Uri.parse('$apiURL/rpc/user_info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tempToken',
        },
      );

      print('   Status Code con token temporal: ${userInfoWithTempToken.statusCode}');
      if (userInfoWithTempToken.statusCode == 401) {
        print('   ✅ Token temporal no tiene acceso a user_info (esperado)');
      } else if (userInfoWithTempToken.statusCode == 200) {
        print('   ⚠️ Token temporal tiene acceso a user_info (inesperado)');
      }
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }

  print('\n=== Diagnóstico completado ===');
}