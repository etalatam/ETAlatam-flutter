/// DEPRECATED: Este archivo ya no se usa activamente.
/// Se mantiene por compatibilidad con imports existentes.
/// La funcionalidad de tracking ahora está en RobustLocationTracker.

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {}

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {}

  @pragma('vm:entry-point')
  static Future<void> callback(dynamic locationDto) async {}

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {}
}
