import 'package:intl/intl.dart';

class Utils {
  // Método para convertir una fecha UTC a la hora local
  static DateTime convertirUtcALocal(String fechaUtc) {
    // Parsea la fecha UTC a un objeto DateTime
    DateTime fechaUtcDateTime = DateTime.parse('${fechaUtc}Z');

    // Convierte la fecha UTC a la hora local del dispositivo
    DateTime fechaLocalDateTime = fechaUtcDateTime.toLocal();

    // Retorna la fecha local como DateTime
    return fechaLocalDateTime;
  }

  // Método para formatear la fecha según si es el día actual o no
  static String formatearFechaCorta(DateTime fechaLocal) {
    DateTime ahora = DateTime.now();

    if (esHoy(fechaLocal, ahora)) {
      // Verificar si es el mismo minuto
      if (esMismoMinuto(fechaLocal, ahora)) {
        // Formato para el mismo minuto: hh:mm:ss a
        return DateFormat('hh:mm:ss a').format(fechaLocal);
      } else {
        // Formato para otro minuto: hh:mm a
        return DateFormat('hh:mm a').format(fechaLocal);
      }
    } else {
      // Formato para otros días: dd/MM/yyyy hh:mm a
      return DateFormat('dd/MM/yyyy hh:mm a').format(fechaLocal);
    }
  }

  // Método auxiliar para verificar si una fecha es hoy
  static bool esHoy(DateTime fecha, DateTime ahora) {
    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day;
  }

  // Método auxiliar para verificar si es el mismo minuto
  static bool esMismoMinuto(DateTime fecha, DateTime ahora) {
    return fecha.year == ahora.year &&
        fecha.month == ahora.month &&
        fecha.day == ahora.day &&
        fecha.hour == ahora.hour &&
        fecha.minute == ahora.minute;
  }

  static String formatElapsedTime(DateTime date) {
    final now = DateTime.now();
    
    Duration difference = now.difference(date).abs();

    // Siempre mostrar formato HH:MM:SS
    String hours = difference.inHours.toString().padLeft(2, '0');
    String minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
