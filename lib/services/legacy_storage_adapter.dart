import 'package:eta_school_app/services/storage_service.dart';

/// Adaptador para mantener compatibilidad con el código existente que usa LocalStorage
/// Delegamos todas las operaciones a StorageService
class LegacyStorageAdapter {
  final StorageService _storageService = StorageService.instance;

  /// Simula el comportamiento de LocalStorage.ready
  Future<bool> get ready async {
    await _storageService.init();
    return true;
  }

  /// Obtiene un valor del storage (compatible con LocalStorage)
  Future<dynamic> getItem(String key) async {
    // Intentar primero como string
    final stringValue = await _storageService.getString(key);
    if (stringValue != null) return stringValue;

    // Si no es string, intentar como int
    final intValue = await _storageService.getInt(key);
    if (intValue != null) return intValue;

    // Si no es int, intentar como bool
    final boolValue = await _storageService.getBool(key);
    if (boolValue != null) return boolValue;

    // Si no es ninguno, intentar como lista
    final listValue = await _storageService.getStringList(key);
    if (listValue != null) return listValue;

    return null;
  }

  /// Guarda un valor en el storage (compatible con LocalStorage)
  Future<void> setItem(String key, dynamic value) async {
    if (value == null) {
      await _storageService.remove(key);
      return;
    }

    if (value is String) {
      await _storageService.setString(key, value);
    } else if (value is int) {
      await _storageService.setInt(key, value);
    } else if (value is bool) {
      await _storageService.setBool(key, value);
    } else if (value is List<String>) {
      await _storageService.setStringList(key, value);
    } else {
      // Para otros tipos, convertir a string
      await _storageService.setString(key, value.toString());
    }
  }

  /// Elimina un valor del storage
  Future<bool> removeItem(String key) async {
    return await _storageService.remove(key);
  }

  /// Alias para removeItem (compatible con LocalStorage)
  Future<bool> deleteItem(String key) async {
    return await _storageService.remove(key);
  }

  /// Limpia todo el storage
  Future<bool> clear() async {
    return await _storageService.clear();
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    return await _storageService.containsKey(key);
  }
}

/// Instancia global para reemplazar LocalStorage en el código existente
final storage = LegacyStorageAdapter();