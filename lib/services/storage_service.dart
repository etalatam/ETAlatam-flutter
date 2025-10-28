import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio singleton para manejo seguro y centralizado del almacenamiento
/// Resuelve problemas de acceso concurrente usando SharedPreferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static StorageService get instance => _instance;

  SharedPreferences? _prefs;
  final _initCompleter = Completer<void>();
  bool _isInitialized = false;

  /// Inicializa el servicio de almacenamiento
  Future<void> init() async {
    if (_isInitialized) return _initCompleter.future;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      _initCompleter.complete();
      print('[StorageService] Inicializado correctamente');
    } catch (e) {
      print('[StorageService] Error al inicializar: $e');
      _initCompleter.completeError(e);
      rethrow;
    }
  }

  /// Asegura que el servicio esté listo antes de cualquier operación
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// Guarda un string
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.setString(key, value);
      print('[StorageService] Guardado $key: ${value.substring(0, value.length > 20 ? 20 : value.length)}...');
      return result;
    } catch (e) {
      print('[StorageService] Error guardando $key: $e');
      return false;
    }
  }

  /// Obtiene un string
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    try {
      final value = _prefs!.getString(key);
      if (value != null) {
        print('[StorageService] Leído $key: ${value.substring(0, value.length > 20 ? 20 : value.length)}...');
      } else {
        print('[StorageService] $key es null');
      }
      return value;
    } catch (e) {
      print('[StorageService] Error leyendo $key: $e');
      return null;
    }
  }

  /// Guarda un int
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.setInt(key, value);
      print('[StorageService] Guardado $key: $value');
      return result;
    } catch (e) {
      print('[StorageService] Error guardando $key: $e');
      return false;
    }
  }

  /// Obtiene un int
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      print('[StorageService] Error leyendo $key: $e');
      return null;
    }
  }

  /// Guarda un bool
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.setBool(key, value);
      print('[StorageService] Guardado $key: $value');
      return result;
    } catch (e) {
      print('[StorageService] Error guardando $key: $e');
      return false;
    }
  }

  /// Obtiene un bool
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      print('[StorageService] Error leyendo $key: $e');
      return null;
    }
  }

  /// Guarda una lista de strings
  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.setStringList(key, value);
      print('[StorageService] Guardado $key: $value');
      return result;
    } catch (e) {
      print('[StorageService] Error guardando $key: $e');
      return false;
    }
  }

  /// Obtiene una lista de strings
  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    try {
      return _prefs!.getStringList(key);
    } catch (e) {
      print('[StorageService] Error leyendo $key: $e');
      return null;
    }
  }

  /// Elimina una clave
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.remove(key);
      print('[StorageService] Eliminado $key');
      return result;
    } catch (e) {
      print('[StorageService] Error eliminando $key: $e');
      return false;
    }
  }

  /// Limpia todo el almacenamiento
  Future<bool> clear() async {
    await _ensureInitialized();
    try {
      final result = await _prefs!.clear();
      print('[StorageService] Almacenamiento limpiado');
      return result;
    } catch (e) {
      print('[StorageService] Error limpiando almacenamiento: $e');
      return false;
    }
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Guarda los datos de sesión del usuario
  Future<bool> saveUserSession({
    required String token,
    required int userId,
    required String relationName,
    required int relationId,
    required String userName,
    required bool isMonitor,
  }) async {
    try {
      print('[StorageService] Guardando sesión de usuario...');

      final results = await Future.wait([
        setString('token', token),
        setInt('id_usu', userId),
        setString('relation_name', relationName),
        setInt('relation_id', relationId),
        setString('nom_usu', userName),
        setBool('monitor', isMonitor),
      ]);

      final success = results.every((result) => result == true);

      if (success) {
        print('[StorageService] Sesión guardada exitosamente');
      } else {
        print('[StorageService] Error: Algunos valores no se guardaron');
      }

      return success;
    } catch (e) {
      print('[StorageService] Error guardando sesión: $e');
      return false;
    }
  }

  /// Obtiene los datos de sesión del usuario
  Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final token = await getString('token');
      final userId = await getInt('id_usu');
      final relationName = await getString('relation_name');
      final relationId = await getInt('relation_id');
      final userName = await getString('nom_usu');
      final isMonitor = await getBool('monitor');

      // Verificar que los campos críticos existan
      if (token == null || userId == null || relationName == null) {
        print('[StorageService] Sesión incompleta o no existe');
        return null;
      }

      return {
        'token': token,
        'id_usu': userId,
        'relation_name': relationName,
        'relation_id': relationId,
        'nom_usu': userName,
        'monitor': isMonitor ?? false,
      };
    } catch (e) {
      print('[StorageService] Error obteniendo sesión: $e');
      return null;
    }
  }

  /// Limpia la sesión del usuario
  Future<bool> clearUserSession() async {
    try {
      print('[StorageService] Limpiando sesión de usuario...');

      final results = await Future.wait([
        remove('token'),
        remove('id_usu'),
        remove('relation_name'),
        remove('relation_id'),
        remove('nom_usu'),
        remove('monitor'),
      ]);

      final success = results.every((result) => result == true);

      if (success) {
        print('[StorageService] Sesión limpiada exitosamente');
      } else {
        print('[StorageService] Advertencia: Algunos valores no se eliminaron');
      }

      return success;
    } catch (e) {
      print('[StorageService] Error limpiando sesión: $e');
      return false;
    }
  }

  /// Verifica si hay una sesión activa
  Future<bool> hasActiveSession() async {
    final session = await getUserSession();
    return session != null;
  }
}