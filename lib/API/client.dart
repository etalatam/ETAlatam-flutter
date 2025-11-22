import 'dart:convert';
import 'package:eta_school_app/Models/attendance_model.dart';
import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/emitter_keygen.dart';
import 'package:eta_school_app/Models/login_information_model.dart';
import 'package:eta_school_app/Models/trips_students_model.dart';
import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/Pages/providers/driver_provider.dart';
import 'package:eta_school_app/domain/entities/user/driver.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';
import 'package:eta_school_app/infrastructure/datasources/login_information_datasource.dart';
import 'package:eta_school_app/infrastructure/mappers/driver_mapper.dart';
import 'package:eta_school_app/infrastructure/mappers/login_information_mapper.dart';
import 'package:eta_school_app/infrastructure/repositories/login_information_repository_impl.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:wakelock/wakelock.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Models/NotificationModel.dart';
import 'package:flutter/foundation.dart';
import 'package:eta_school_app/Pages/login_page.dart';

import '../Models/absence_model.dart';
import '../Models/recipient_group_model.dart';
import '../Models/user_topic_model.dart';

class HttpService {
  // Usar el storage global importado desde helpers.dart
  // que a su vez lo importa desde legacy_storage_adapter.dart

  String token = '';

  // Flag para evitar múltiples logouts simultáneos
  static bool _isLoggingOut = false;

  // String response_text = "";

  Map? headers;


  String getAvatarUrl(relationId, relationName) {
    final url =
        "$apiURL/rpc/get_reource_image?_relation_name=$relationName&_relation_id=$relationId";
    print("getAvatarUrl: $url");
    return url;
  }

  String getImage(relationId, relationName) {
    final url =
        "$apiURL/rpc/get_image?_relation_name=$relationName&_relation_id=$relationId";
    print("getImage: $url");
    return url;
  }

  String getImageUrl({relationName = "eta.usuarios", relationId = 0}) {
    // return "$apiURL/app/image.php?src=";
    return "$apiURL/rpc/get_reource_image?_relation_name=$relationName&_relation_id=$relationId";
  }

  String croppedImage(path, int? width, int? height) {
    // return "$apiURL/app/image.php?w=$width&h=$height&src=$path";
    return "https://admin.etalatam.com/assets/img$path";
  }

  /// Check for expired session
  Future<void> _checkSessionExpired(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // Evitar múltiples logouts simultáneos
      if (_isLoggingOut) {
        print("[HttpService] Logout already in progress, skipping...");
        return;
      }

      // Analizar el tipo de error 401
      bool isJWTError = false;
      try {
        final body = jsonDecode(response.body);
        // Solo considerar como sesión expirada si es específicamente un error JWT
        if (body['code'] == 'PGRST301' ||
            body['message']?.toString().contains('JWSError') == true ||
            body['message']?.toString().contains('JWT') == true ||
            body['message']?.toString().contains('token') == true) {
          isJWTError = true;
        }
      } catch (e) {
        // Si no podemos parsear el body, asumimos que es un error de autenticación
        isJWTError = true;
      }

      if (isJWTError) {
        print("[HttpService] JWT authentication error - clearing session");
        // Limpiar datos y redirigir al login
        await logout();
        Get.offAll(() => Login());
      } else {
        print("[HttpService] API returned ${response.statusCode} but not a JWT error - keeping session");
      }
    }
  }

  /// Run API GET query
  getQuery(String path, {useToken = true}) async {
    String? token = await storage.getItem('token');

    // Si no hay token de usuario, intentar usar el token temporal
    if (token == null || token.isEmpty) {
      token = await storage.getItem('temp_access_token');
    }

    final url = Uri.parse(apiURL + path);
    print("$url");

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': useToken ? 'Bearer $token' : '',
    }).onError((error, stackTrace) => handleHttpError(error));

    // Verificar si la sesi\u00f3n expir\u00f3
    await _checkSessionExpired(response);
    return response;
  }

  /// Run API POST query
  postQuery(String path, body,
      {useToken = true,
      contentType = 'application/x-www-form-urlencoded'}) async {
    String? token = await storage.getItem('token');

    // Si no hay token de usuario, intentar usar el token temporal
    if (token == null || token.isEmpty) {
      token = await storage.getItem('temp_access_token');
    }

    final url = Uri.parse(apiURL + path);
    print("[Api.url] $url");

    final response = await http.post(url, body: body, headers: {
      'Content-Type': contentType,
      'Authorization': useToken ? 'Bearer $token' : '',
    }).onError((error, stackTrace) => handleHttpError(error));

    // Verificar si la sesi\u00f3n expir\u00f3
    await _checkSessionExpired(response);
    return response;
  }

  /// Load Trips
  Future<List<TripModel>> getDriverTrips(int lastId) async {
    const endpoint = "/rpc/driver_trips";
    http.Response res = await getQuery(
        "$endpoint?select=*&running=eq.false&limit=10&order=start_ts.desc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body.map((dynamic item) async => TripModel.fromJson(item)).toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  Future<List<TripModel>> getMonitorActiveTrips() async {
    const endpoint = "/rpc/trips_monitor";
    http.Response res = await getQuery(
        "$endpoint?select=*&running=eq.true&limit=1&order=start_ts.desc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body.map((dynamic item) async => TripModel.fromJson(item)).toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Trips
  Future<List<TripModel>> getStudentTrips(studentId) async {
    const endpoint = "/rpc/student_trips";
    http.Response res = await getQuery(
        "$endpoint?select=*&running=eq.false&limit=10&order=start_ts.desc&student_id=$studentId");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body.map((dynamic item) async => TripModel.fromJson(item)).toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  Future<List<AttendanceModel>> getStudentActiveTrips(studentId) async {
    const endpoint = "/rpc/attendance";
    http.Response res = await getQuery(
        "$endpoint?select=*&running=eq.true&limit=1&order=start_ts.desc&id_student=eq.$studentId");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<AttendanceModel> trips = await Future.wait(
        body.map((dynamic item) async => AttendanceModel.fromJson(item)).toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];

  }

  /// Load Latest Notifications
  Future<List<NotificationModel>> getNotifications(String? topics) async {
    const endpoint = '';
    var query = "/rpc/notifications?order=id.desc&limit=20";

    if (topics != null) {
      topics =
          topics.replaceAll("[", "(").replaceAll("]", ")").replaceAll(" ", "");
      query += "&topic=in.$topics";
    }

    http.Response res = await getQuery(query);

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<NotificationModel> notificactions = await Future.wait(
        body
            .map((dynamic item) async => NotificationModel.fromJson(item))
            .toList(),
      );
      return notificactions;
    }
    debugPrint(res.body.toString());
    return [];
  }

  Future<List<SupportHelpCategory>> supportHelpCategory() async {
    const endpoint = "/rpc/support_help_category";
    http.Response res = await getQuery("$endpoint?order=name.asc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<SupportHelpCategory> supportHelpCategoryList =
          await Future.wait(
        body
            .map((dynamic item) async => SupportHelpCategory.fromJson(item))
            .toList(),
      );
      return supportHelpCategoryList;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Help Messages
  Future<List<HelpMessageModel>?> getHelpMessages() async {
    const endpoint = "/rpc/support_message";
    http.Response res = await getQuery("$endpoint?order=id.desc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<HelpMessageModel> supportMessage = await Future.wait(
        body
            .map((dynamic item) async => HelpMessageModel.fromJson(item))
            .toList(),
      );
      return supportMessage;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Route
  Future<RouteModel> getRoute(routeId) async {
    const endpoint = "/rpc/driver_routes";
    http.Response res =
        await getQuery("$endpoint?select=*&limit=1&route_id=eq.$routeId");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      if (body == null) {
        return RouteModel(route_id: 0, route_name: '', pickup_locations: []);
      }
      final RouteModel trips = RouteModel.fromJson(body[0]);
      return trips;
    }
    return RouteModel(route_id: 0, route_name: '', pickup_locations: []);
  }

  // /// Load Driver
  Future<DriverModel> getDriver() async {
    const endpoint = "/rpc/driver_info";
    http.Response res = await getQuery(endpoint);

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      final driverModel = DriverModel.fromJson(body);
      final Driver driver = DriverMapper.convert(driverModel);
      await driverProvider.save(driver);
      return driverModel;
    }
    return DriverModel(driver_id: 0, first_name: '');
  }

  Future<StudentModel> getStudent() async {
    const endpoint = '/rpc/student_info';
    try {
      http.Response res =
          await postQuery(endpoint, null, contentType: 'application/json');
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return StudentModel.fromJson(json);
      }
    } catch (e) {
      print("sendTracking error: ${e.toString()}");
    }
    return StudentModel(student_id: 0, parent_id: 0, pickup_points: []);
  }

  /// Load Parent
  Future<ParentModel> getParent() async {
    try {
      http.Response res = await postQuery('/rpc/guardian_info', null,
          contentType: 'application/json');
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return ParentModel.fromJson(json);
      }
    } catch (e) {
      print("sendTracking error: ${e.toString()}");
    }
    return ParentModel(parentId: 0, students: []);
  }

  Future<List<RouteModel>> getGuardianRoutes() async {
    const endpoint = "/rpc/guardian_routes";
    var res =
        await getQuery("$endpoint?limit=10&select=driver_id,bus_plate,route_id,route_description,schedule_start_time,schedule_end_time,schedule_id");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
      } catch (e) {
        print("getGuardianRoutes error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

    Future<List<RouteModel>> getStudentRoutes() async {
    const endpoint = "/rpc/student_routes";
    var res =
        await getQuery("$endpoint?limit=10&select=driver_id,bus_plate,route_id,route_description,schedule_start_time,schedule_end_time,schedule_id");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
      } catch (e) {
        print("getStudentRoutes error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  /// Load Routes
  Future<List<RouteModel>> getRoutes() async {
    const endpoint = "/rpc/driver_routes";
    var res =
        await getQuery("$endpoint?limit=10&order=schedule_start_time.desc");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
      } catch (e) {
        print("getRoutes error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  Future<List<RouteModel>> todayRoutes() async {
    const endpoint = "/rpc/today_driver_routes";
    var res =
        await getQuery("$endpoint?limit=10&order=schedule_start_time.desc");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");
    
    // Log adicional para debugging
    if (res.body == '[]') {
      print("[$endpoint] No routes found for today. This might be a date/timezone issue.");
      print("[$endpoint] Server might be filtering by a different date than expected.");
    }

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
      } catch (e) {
        print("todayRoutes error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  Future<EmitterKeyGenModel?> emitterKeyGen(String channel) async {
    const endpoint = "/rpc/emitter_keygen";
    http.Response res = await getQuery(
        "$endpoint?order=ts.asc&channel=ilike.*$channel*&limit=1");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    try {
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        if (body.isNotEmpty) {
          return EmitterKeyGenModel.fromJson(body[0]);
        }
      }
    } catch (e) {
      print("emitterKeyGen.error ${e.toString()}");
    }
    return null;
  }

  Future<EventModel?> getEvent(int eventId) async {
    const endpoint = "/rpc/trips_events";
    http.Response res = await getQuery("$endpoint?limit1&id_event=$eventId");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    try {
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        if (body.isNotEmpty) {
          return EventModel.fromJson(body[0]);
        }
      }
    } catch (e) {
      print("emitterKeyGen.error ${e.toString()}");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getPickUpLocationPoint() async {
    const endpoint = "/rpc/route_pickup_points";
    http.Response res = await getQuery(endpoint);

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        final List<Map<String, dynamic>> body = jsonDecode(res.body);
        if (res.body.isEmpty) return [];
        return body;
      } catch (e) {
        print("getPickUpLocationPoint error: ${e.toString()}");
      }
    }

    return [];
  }

  /// Load Trip
  Future<TripModel> getTrip(id) async {
    const endpoint = '/rpc/driver_trips';
    http.Response res =
        await getQuery("$endpoint?select=*&limit=1&id_trip=eq.$id");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      if (body == null) return TripModel(trip_id: 0);

      try {
        return TripModel.fromJson(body[0]);
      } catch (e) {
        print("getTrip error: ${e.toString()}");
      }
    }
    return TripModel(trip_id: 0);
  }

  /// Load Tripd
  Future<TripModel> getActiveTrip() async {
    const endpoint = "/rpc/driver_trips";
    http.Response res = await getQuery(
        "$endpoint?select=*&limit=1&running=eq.true&order=start_ts.desc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        var body = jsonDecode(res.body);
        if (body == null) return TripModel(trip_id: 0);

        final TripModel trips = TripModel.fromJson(body[0]);
        return trips;
      } catch (e) {
        print("[getActiveTrip] ${e.toString()}");
      }
    }
    return TripModel(trip_id: 0);
  }

  Future<List<TripModel>> getGuardianTrips(String active) async {
    const endpoint = "/rpc/guardian_trips";
    http.Response res =
        await getQuery("$endpoint?select=*&limit=10&running=eq.$active&order=id_trip.desc");

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => TripModel.fromJson(item)).toList();
      } catch (e) {
        print("[$endpoint] ${e.toString()}");
      }
    }
    return [];
  }

  /// Submit form to update data through API
  Future<TripModel> startTrip(RouteModel route) async {
    const endpoint = "/rpc/driver_start_trip";
    Map data = {
      "_route_id": "${route.route_id}",
      "_id_schedule": "${route.schedule_id}"
    };

    // Map? body = {"model": 'create_trip', "params": jsonEncode(data)};
    // http.Response res = await postQuery('/mobile_api', body);

    http.Response res = await postQuery(endpoint, data);
    print("[$endpoint] res.statusCode ${res.statusCode}");
    print("[$endpoint] res.body ${res.body}");

    if (res.statusCode == 200) {
      return TripModel.fromJson(jsonDecode(res.body));
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  Future<StudentModel> updateAttendance(
      TripModel trip, StudentModel student, String statusCode) async {
    const endpoint = "/rpc/update_attendance";
    final data = jsonEncode({
      "id_school": student.schoolId,
      "id_student": student.student_id,
      "id_trip": trip.trip_id,
      "status_code": statusCode
    });

    print("[client.updateAttendance] $data");

    http.Response res =
        await postQuery(endpoint, data, contentType: 'application/json');
    print("[$endpoint] res.statusCode ${res.statusCode}");
    print("[$endpoint] res.body ${res.body}");

    if (res.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(res.body));
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  /// Submit form to update data through API
  Future<String> endTrip(String tripId) async {
    const endpoint = '/rpc/driver_stop_trip';
    Map data = {
      // "trip_id": tripId,
      // "trip_status": 'Completed',
    };

    http.Response res = await postQuery(endpoint, data);
    print("[$endpoint]res.statusCode ${res.statusCode}");
    print("[$endpoint] res.body ${res.body}");

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  // request access to api
  requestAccess() async {
    debugPrint('requestAccess');
    const endpoint = "/rpc/request_access";
    final data = {
      '_client_id': '4926212245183',
      '_access_token': '8725ca59-71be-46c6-a364-eaac57f1786d'
    };

    final http.Response res = await postQuery(endpoint, data, useToken: false);

    print("[$endpoint] statuscode: ${res.statusCode}");
    print("[$endpoint]res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      debugPrint(body.toString());
      // Guardar temporalmente el token de request_access
      // NOTA: Este token será sobreescrito por el token del usuario después del login
      if (body['token'] != null && body['token'].toString().isNotEmpty) {
        await storage.setItem('temp_access_token', body['token']);
      }
      return '1';
    }

    return "${parseResponseMessage(res)}/${res.statusCode}";
  }

  /// Login with email & password
  login(String email, String password) async {
    debugPrint('login');
    const endpoint = '/rpc/login';
    final data = {
      "_email": email,
      "_pass": password,
    };

    var requestAccessRes = await requestAccess();
    if (requestAccessRes == '1') {
      // El postQuery ahora usará el token temporal automáticamente
      http.Response res = await postQuery(endpoint, data);

      print("[$endpoint] statuscode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");

      if (res.statusCode == 200) {
        dynamic body = jsonDecode(res.body);

        // Log detallado de la respuesta del login
        print('[login] Response data:');
        print('[login]   token: ${body['token'] != null ? "exists (${body['token'].toString().length} chars)" : "null"}');
        print('[login]   id_usu: ${body['id_usu']}');
        print('[login]   relation_name: ${body['relation_name']}');
        print('[login]   relation_id: ${body['relation_id']}');
        print('[login]   nom_usu: ${body['nom_usu']}');
        print('[login]   monitor: ${body['monitor']}');

        // Asegurar que el storage está listo antes de guardar
        await storage.ready;

        // Validar que el token no sea nulo ni vacío antes de guardarlo
        if (body['token'] != null && body['token'].toString().isNotEmpty) {
          await storage.setItem('token', body['token']);
          print('[login] Token saved successfully');
        } else {
          print('[login] Warning: Token is empty or null!');
        }
        // Guardar todos los valores del login, asegurando que no sean null
        if (body['id_usu'] != null) {
          await storage.setItem('id_usu', body['id_usu']);
          print('[login] id_usu saved: ${body['id_usu']}');
        }
        if (body['relation_name'] != null) {
          await storage.setItem('relation_name', body['relation_name']);
          print('[login] relation_name saved: ${body['relation_name']}');
        }
        if (body['relation_id'] != null) {
          await storage.setItem('relation_id', body['relation_id']);
          print('[login] relation_id saved: ${body['relation_id']}');
        }
        if (body['nom_usu'] != null) {
          await storage.setItem('nom_usu', body['nom_usu']);
          print('[login] nom_usu saved: ${body['nom_usu']}');
        }
        // monitor puede ser false, así que guardamos aunque sea false
        await storage.setItem('monitor', body['monitor'] ?? false);
        print('[login] monitor saved: ${body['monitor'] ?? false}');

        // Guardar el email del usuario para usarlo en las suscripciones FCM
        await storage.setItem('user_email', email);
        print('[login] user_email saved: $email');

        try {
          final LoginInformation login =
              LoginInformationMapper.information(LoginInfo.fromJson(body));
          final userService =
              LoginInformationRepositoryImpl(LoginInformationDatasource());
          await userService.saveLogin(login);
        } on Exception catch (e) {
          debugPrint('Error saving login info: $e');
        }
        if(!EmitterService.instance.isConnected()){
          EmitterService.instance.connect();
        }

        // Setup de notificaciones FCM al hacer login exitoso (en background)
        // No esperamos el resultado para no bloquear la navegación
        // Agregamos timeout para evitar bloqueos
        Future.delayed(Duration(milliseconds: 100), () {
          NotificationService.instance.setupNotifications()
            .timeout(Duration(seconds: 5))
            .catchError((e) {
              print('[login] Error en setupNotifications: $e');
            });
        });

        return '1';
      } else {
        return "${parseResponseMessage(res)}/${res.statusCode}";
      }
    }

    return requestAccessRes;
  }

  /// Send message
  Future<HelpMessageModel> sendMessage(
      int categoryId, String message, int priority) async {
    const endpoint = '/rpc/save_support_message';
    final data = {
      "category_id": categoryId,
      "content": message,
      "priority_id": priority
    };

    http.Response res = await postQuery(endpoint, jsonEncode(data),
        contentType: 'application/json');

    print("[$endpoint] statuscode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      //return (body['success'] != null) ? body['result'] : body['error'];
      return HelpMessageModel.fromJson(body);
    }

    throw "${parseResponseMessage(res)}/${res.statusCode}";
  }

  /// Send message
  Future<CommentModel> sendMessageComment(String comment, int messageId) async {
    const endpoint = '/rpc/save_support_message_comment';
    final data = {"message_id": messageId, "comment": comment};

    http.Response res = await postQuery(endpoint, jsonEncode(data),
        contentType: 'application/json');

    print("[$endpoint] statuscode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return CommentModel.fromJson(body);
    }

    throw "${parseResponseMessage(res)}/${res.statusCode}";
  }

  /// Send message
  Future<String> resetPassword(String email) async {
    const endpoint = '/rpc/update_password_request';
    Map data = {
      "email": email,
    };

    // Check if we already have a valid token (authenticated user from profile)
    final existingToken = await storage.getItem('token');

    if (existingToken != null && existingToken.toString().isNotEmpty) {
      // User is authenticated (calling from profile), use existing token
      print("[$endpoint] Using existing token for authenticated user");
      http.Response res = await postQuery(endpoint, data);

      print("[$endpoint] res.statusCode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");

      if (res.statusCode == 200) {
        return '1';
      } else {
        return "${parseResponseMessage(res)}/${res.statusCode}";
      }
    } else {
      // User is not authenticated (calling from login), need to request access first
      print("[$endpoint] Requesting access token for unauthenticated user");
      var requestAccessRes = await requestAccess();
      if (requestAccessRes == '1') {
        http.Response res = await postQuery(endpoint, data);

        print("[$endpoint] res.statusCode: ${res.statusCode}");
        print("[$endpoint] res.body: ${res.body}");

        if (res.statusCode == 200) {
          return '1';
        } else {
          return "${parseResponseMessage(res)}/${res.statusCode}";
        }
      }
      return requestAccessRes;
    }
  }

  // get message error from request response
  parseResponseMessage(http.Response res) {
    try {
      debugPrint(res.body.toString());
      var body = jsonDecode(res.body);
      if (body['details'] != null) {
        return body['details'];
      } else if (body['hint'] != null) {
        return body['hint'];
      } else if ("${body['message']}".isEmpty == false) {
        return body['message'];
      }
    } catch (e) {
      debugPrint(e.toString());
      return 'Respuesta inesperada del servidor 😳';
    }
    // return "";
  }

  /// Send Car Location
  readNotification(int? driverId, int? notificationId) async {
    if (notificationId == null) {
      return null;
    }

    // Map data = {"driver_id": driverId, "id": notificationId, "status": 'read'};

    // await postQuery('/mobile_api/update',
    //     {"type": "Notification.update", "params": jsonEncode(data)});
  }

  // Logout and clear localStorage
  logout() async {
    // Prevenir múltiples logouts simultáneos
    if (_isLoggingOut) {
      print("[httpService.logout] Logout already in progress, skipping...");
      return;
    }

    _isLoggingOut = true;
    print("[httpService.logout] Starting logout process...");

    // Stop location services
    try {
      print("[httpService.logout] Stopping LocationService...");
      LocationService.instance.stopLocationService();
    } catch (e) {
      print("[httpService.logout] Error stopping LocationService: $e");
    }
    
    // Disconnect EmitterService
    try {
      print("[httpService.logout] Disconnecting EmitterService...");
      EmitterService.instance.disconnect();
    } catch (e) {
      print("[httpService.logout] Error disconnecting EmitterService: $e");
    }
    
    // Close NotificationService
    try {
      print("[httpService.logout] Closing NotificationService...");
      await NotificationService.instance.close();
    } catch (e) {
      print("[httpService.logout] Error closing NotificationService: $e");
    }
    
    // Disable Wakelock
    try {
      print("[httpService.logout] Disabling Wakelock...");
      await Wakelock.disable();
    } catch (e) {
      print("[httpService.logout] Error disabling Wakelock: $e");
    }
    
    // Clear all storage
    try {
      print("[httpService.logout] Clearing storage...");
      await storage.clear();
    } catch (e) {
      print("[httpService.logout] Error clearing storage: $e");
    }

    print("[httpService.logout] Logout process completed");

    // Reset el flag al final
    _isLoggingOut = false;
  }

  Future<dynamic> sendTracking({required position, required userId}) async {
    print('sendTracking.position $position');

    final data = {
      'user_id': userId,
      'latitude': position['latitude'],
      'longitude': position['longitude'],
      'speed': position['speed'],
      'accuracy': position['accuracy'],
      'altitude': position['altitude'],
      'speedAccuracy': position['speedAccuracy'],
      'time': position['time'],
      'background': position['background'],
      'distance': position['distance']

    };
    final jsonData = jsonEncode(data);
    try {
      http.Response res = await postQuery('/rpc/user_tracking', jsonData,
          contentType: 'application/json');
      if (res.statusCode == 200) {
        return res.body;
      } else {
        return res;
      }
    } catch (e) {
      print("sendTracking error: ${e.toString()}");
      return null;
    }
  }

  Future<List<StudentModel>> routeStudents(
      {required tripId, limit = 20, offset = 0, String filter = ''}) async {
    const endpoint = "/rpc/route_students";
    String url =
        "$endpoint?order=student_firstname.desc&limit=$limit&offset=$offset";

    url = "$url&id_trip=eq.$tripId";

    if (filter.isNotEmpty) {
      url = "$url&or=(";
      url = "${url}student_firstname.ilike.*$filter*";
      url = "$url,student_lastname.ilike.*$filter*";
      url = "$url,student_address.ilike.*$filter*";
      url = "$url,school_name.ilike.*$filter*";
      url = "$url,pickup_point_name.ilike.*$filter*";
      url = "$url)";
    }

    http.Response res = await getQuery(url);

    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint]res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<StudentModel> students = await Future.wait(
        body.map((dynamic item) async => StudentModel.fromJson(item)).toList(),
      );
      return students;
    }
    debugPrint(res.body.toString());
    return [];
  }

  Future<dynamic> driverInfo() async {
    try {
      const endpoint = '/rpc/driver_info';
      http.Response res =
          await postQuery(endpoint, null, contentType: 'application/json');

      print("[$endpoint] res.statusCode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");

      if (res.statusCode == 200) {
        return res.body;
      } else {
        return res;
      }
    } catch (e) {
      print("driverInfo error: ${e.toString()}");
      return null;
    }
  }

  Future<UserModel?> userInfo() async {
    try {
      const endpoint = '/rpc/user_info';
      http.Response res =
          await postQuery(endpoint, null, contentType: 'application/json');

      print("[$endpoint] res.statusCode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return UserModel.fromJson(json);
      }
    } catch (e) {
      print("userInfo error: ${e.toString()}");
    }
    return null;
  }
  
  handleHttpError(e) async {
    print("HTTP error: ${e.toString()}");
    // Si hay un error de conexión, devolver un response vacío
    return http.Response('', 500);
  }


  /// Load Routes for Student by Date
  Future<List<TripStudentModel>> getTripsStudentByDate(int studentId, String date, String endDate) async {
    const endpoint = "/rpc/next_trips_students";
    var queryParams = "studentid=$studentId&start_date=$date&end_date=$endDate";
    var res = await getQuery("$endpoint?$queryParams");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");
    
    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((item) => TripStudentModel.fromJson(item)).toList();
      } catch (e) {
        print("getTripsStudentByDate error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  /// Register Student Absence
  Future<Map<String, dynamic>> registerStudentAbsence(String jsonBody) async {
    const endpoint = "/rpc/request_absence";
    try {
      http.Response res = await postQuery(
        endpoint,
        jsonBody,
        contentType: 'application/json',
      );
      
      print("[$endpoint] res.statusCode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");
      
      // Intentar parsear la respuesta
      Map<String, dynamic> responseData = {};
      try {
        responseData = jsonDecode(res.body);
      } catch (e) {
        print("Error parsing response: ${e.toString()}");
      }
      
      final bool isSuccess = res.statusCode == 200 || res.statusCode == 201;
      final String status = responseData['status'] ?? (isSuccess ? 'success' : 'error');
      final String message = responseData['message'] ?? (isSuccess ? 'Operación exitosa' : 'Error en la operación');
      
      return {
        'success': status == 'success',
        'message': message,
      };
    } catch (e) {
      print("registerStudentAbsence error: ${e.toString()}");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get Student Absences
  Future<List<AbsenceModel>> getStudentAbsences(int studentId) async {
    const endpoint = "/rpc/get_absences";
    var res = await getQuery("$endpoint?id_student=eq.$studentId&order=absence_date.desc");
    print("[$endpoint] res.statusCode: ${res.statusCode}");
    print("[$endpoint] res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => AbsenceModel.fromJson(item)).toList();
      } catch (e) {
        print("getStudentAbsences error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  /// Cancel Student Absence
  Future<Map<String, dynamic>> cancelStudentAbsence(AbsenceModel absence) async {
    const endpoint = "/rpc/cancel_absence";

    // Crear un mapa con solo los parámetros requeridos por la función de PostgreSQL
    final Map<String, dynamic> requestData = {
      '_student_id': absence.idStudent,
      '_absence_date': absence.absenceDate.toIso8601String(),
      '_id_schedule': absence.idSchedule,
    };

    try {
      http.Response res = await postQuery(
        endpoint,
        jsonEncode(requestData),
        contentType: 'application/json',
      );

      print("[$endpoint] res.statusCode: ${res.statusCode}");
      print("[$endpoint] res.body: ${res.body}");

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final jsonResponse = jsonDecode(res.body);
        final status = jsonResponse['status'];

        if (status == 'success') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? 'Inasistencia cancelada exitosamente',
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Error al cancelar la inasistencia',
          };
        }
      } else {
        return {
          'success': false,
          'message': parseResponseMessage(res) ?? 'Error al cancelar la inasistencia',
        };
      }
    } catch (e) {
      print("[$endpoint] Error: $e");
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get My User Topic
  /// Obtiene el topic personal del usuario para notificaciones FCM
  /// useSessionCheck: false para evitar bucle infinito durante login
  Future<UserTopicModel?> getMyUserTopic({bool useSessionCheck = false}) async {
    const endpoint = '/rpc/get_my_user_topic';
    try {
      final token = await storage.getItem('token');
      final url = Uri.parse(apiURL + endpoint);

      final response = await http.post(
        url,
        body: null,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).onError((error, stackTrace) => handleHttpError(error));

      print("[$endpoint] res.statusCode: ${response.statusCode}");
      print("[$endpoint] res.body: ${response.body}");

      // Solo verificar sesión expirada si está habilitado
      if (useSessionCheck) {
        await _checkSessionExpired(response);
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return UserTopicModel.fromJson(json);
      } else {
        print("[$endpoint] Non-200 status: ${response.statusCode}");
      }
    } catch (e) {
      print("[$endpoint] error: ${e.toString()}");
    }
    return null;
  }

  /// Get My Recipient Groups
  /// Obtiene los grupos de destinatarios a los que pertenece el usuario
  /// useSessionCheck: false para evitar bucle infinito durante login
  Future<List<RecipientGroupModel>> getMyRecipientGroups({bool useSessionCheck = false}) async {
    const endpoint = '/rpc/get_my_recipient_groups';
    try {
      final token = await storage.getItem('token');
      final url = Uri.parse(apiURL + endpoint);

      final response = await http.post(
        url,
        body: null,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).onError((error, stackTrace) => handleHttpError(error));

      print("[$endpoint] res.statusCode: ${response.statusCode}");
      print("[$endpoint] res.body: ${response.body}");

      // Solo verificar sesión expirada si está habilitado
      if (useSessionCheck) {
        await _checkSessionExpired(response);
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => RecipientGroupModel.fromJson(json)).toList();
      } else {
        print("[$endpoint] Non-200 status: ${response.statusCode}");
      }
    } catch (e) {
      print("[$endpoint] error: ${e.toString()}");
    }
    return [];
  }

}
