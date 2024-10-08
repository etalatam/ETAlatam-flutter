import 'dart:convert';
import 'dart:math';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/login_information_model.dart';
import 'package:MediansSchoolDriver/Pages/providers/driver_provider.dart';
import 'package:MediansSchoolDriver/domain/datasources/login_datasource.dart';
import 'package:MediansSchoolDriver/domain/entities/background_locator/background_position.dart';
import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';
import 'package:MediansSchoolDriver/domain/entities/user/login_information.dart';
import 'package:MediansSchoolDriver/domain/repositories/login_information_repository.dart';
import 'package:MediansSchoolDriver/infrastructure/datasources/login_information_datasource.dart';
import 'package:MediansSchoolDriver/infrastructure/mappers/driver_mapper.dart';
import 'package:MediansSchoolDriver/infrastructure/mappers/login_information_mapper.dart';
import 'package:MediansSchoolDriver/infrastructure/repositories/login_information_repository_impl.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/Models/ParentModel.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/Models/EventModel.dart';
import 'package:MediansSchoolDriver/Models/HelpMessageModel.dart';
import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:MediansSchoolDriver/Models/NotificationModel.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';

class HttpService {
  final LocalStorage storage = LocalStorage('tokens.json');

  String token = '';

  // String response_text = "";

  Map? headers;

  String getImageUrl() {
    // return "$apiURL/app/image.php?src=";
    return "$apiURL/rpc/get_image_avatar?_relacion=eta.usuarios&_id_usu=";
  }

  String croppedImage(path, int? width, int? height) {
    // return "$apiURL/app/image.php?w=$width&h=$height&src=$path";
    return "$apiURL/rpc/get_image_avatar?_relacion=eta.usuarios&_id_usu=";
  }

  /// Run API GET query
  getQuery(String path, {useToken = true}) async {
    var token = storage.getItem('token');
    return await http.get(Uri.parse(apiURL + path), headers: {
      'Content-Type': 'application/json',
      'Authorization': useToken ? 'Bearer $token' : '',
    });
  }

  /// Run API POST query
  postQuery(String path, body,
      {useToken = true,
      contentType = 'application/x-www-form-urlencoded'}) async {
    final token = storage.getItem('token');
    return await http.post(Uri.parse(apiURL + path), body: body, headers: {
      'Content-Type': contentType,
      'Authorization': useToken ? 'Bearer $token' : '',
    });
  }

  /// Load Trips
  Future<List<TripModel>> getTrips(int lastId) async {
    http.Response res = await getQuery("/rpc/driver_trips?select=*&limit=10");
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body
            .map((dynamic item) async => await TripModel.fromJson(item))
            .toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Latest Notifications
  Future<List<NotificationModel>?> getNotifications() async {
    http.Response res = await getQuery("/mobile_api/notifications");

    if (res.statusCode == 200) {
      dynamic resObject = jsonDecode(res.body);
      List<dynamic> body = jsonDecode(jsonEncode(resObject['items']));
      return body
          .map((dynamic item) => NotificationModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Load Help Messages
  Future<List<HelpMessageModel>?> getHelpMessages() async {
    http.Response res = await getQuery("/mobile_api/help_messages");
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      return body
          .map((dynamic item) => HelpMessageModel.fromJson(item))
          .toList();
    }

    return [];
  }

  /// Load Route
  Future<List<RouteModel>> getRoute(String model) async {
    http.Response res = await getQuery(model);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<RouteModel> routes = await Future.wait(
          body.map((dynamic item) => RouteModel.fromJson(item)).toList());
      return routes;
    }
    return [];
  }

  /// Load Route info
  Future<RouteModel> getRouteInfo(id) async {
    http.Response res = await getQuery("/route/$id");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return RouteModel.fromJson(body);
    }
    return RouteModel(route_id: 0, route_name: '', pickup_locations: []);
  }

  /// Load Driver
  Future<DriverModel> getDriver(id) async {
    http.Response res = await getQuery("/rpc/driver_info");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      final driverModel = DriverModel.fromJson(body);
      final Driver driver = DriverMapper.convert(driverModel);
      await driverProvider.save(driver);
      return driverModel;
    }
    return DriverModel(driver_id: 0, first_name: '');
  }

  /// Load Parent
  Future<ParentModel> getParent(id) async {
    http.Response res = await getQuery("/parent/$id");
    var body = jsonDecode(res.body);
    return body == null
        ? ParentModel(parent_id: 0, students: [])
        : ParentModel.fromJson(body);
  }

  /// Load Student pickup
  Future<PickupLocationModel> getPickup(int? id) async {
    http.Response res =
        await getQuery("/mobile_api/student_pickup?student_id=$id");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return PickupLocationModel.fromJson(body);
    }

    return PickupLocationModel();
  }

  /// Load Events
  Future<List<EventModel>> getEvents() async {
    http.Response res = await getQuery("/events?load=json");
    if (res.statusCode == 200) {
      var jsonResponse = jsonDecode(res.body);
      List<dynamic> body = jsonResponse['items'] ?? [];
      return body.map((dynamic item) => EventModel.fromJson(item)).toList();
    }

    return [];
  }

  /// Load Routes
  Future<List<RouteModel>> getRoutes() async {
    http.Response res = await getQuery(
      "/rpc/driver_routes?limit=10",
    );
    if (res.statusCode == 200) {
      try {
        final pickUpLocation = await getPickUpLocationPoint();
        final List<Map<String, dynamic>> body = jsonDecode(res.body);

        if (res.body.isEmpty) return [];
        // Recorrer la lista de pickUpLocation
        for (var route in body) {
          for (var location in pickUpLocation) {
            if (route["route_id"] == location["route_id"]) {
              route["pickup_location"] = {
                "schedule_start_time": location["schedule_start_time"],
                "schedule_end_time": location["schedule_end_time"],
                "bus_plate": location["bus_plate"],
                "bus_model": location["bus_model"],
                "bus_year": location["bus_year"],
                "driver_id": location["driver_id"],
                "monitor_id": location["monitor_id"]
              };
            }
          }
        }

        // Convertir todo el arreglo de forma asíncrona
        final List<RouteModel> routes = await Future.wait(
          body
              .map((dynamic item) async => await RouteModel.fromJson(item))
              .toList(),
        );
        return routes;
      } catch (e) {
        print("getRoutes error: ${e.toString()}");
        return [];
      }
    } else {
      print("erorr en peticion: ${res.toString()}");
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getPickUpLocationPoint() async {
    http.Response res = await getQuery(
      "/rpc/route_pickup_points",
    );
    if (res.statusCode == 200) {
      try {
        final List<Map<String, dynamic>> body = jsonDecode(res.body);
        if (res.body.isEmpty) return [];
        return body;
      } catch (e) {
        print("getPickUpLocationPoint error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  /// Load Trip
  //TODO
  Future<TripModel> getTrip(id) async {
    final trip = {
      "id_trip": 1,
      "start_ts": "2024-09-22T17:59:46.716875",
      "end_ts": "2024-09-22T18:00:06.299405",
      "distance": 0,
      "duration": "00:00:19.58253",
      "running": false,
      "schedule_start_time": "05:30:00",
      "schedule_end_time": "07:30:00",
      "route_id": 1,
      "route_description": "Ruta1",
      "bus_plate": "ABCDEF",
      "bus_model": "",
      "bus_year": 2006,
      "driver_id": 25,
      "monitor_id": 3,
      "relation_name_monitor": "eta.drivers"
    };
    final viaje = TripModel.fromJson(trip);
    return viaje;
    // http.Response res = await getQuery("/trip/$id");

    // if (res.statusCode == 200) {
    //   var body = jsonDecode(res.body);
    //   if (body == null) return TripModel(trip_id: 0);
    //   final TripModel trips = await TripModel.fromJson(body);
    //   return trips;
    // }
    // return TripModel(trip_id: 0);
  }

  /// Load Tripd
  Future<TripModel> getActiveTrip() async {
    http.Response res =
        await postQuery('/mobile_api', {"model": "Driver.getActiveDriverTrip"});
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return TripModel.fromJson(body);
    }
    return TripModel(trip_id: 0);
  }

  /// Submit form to update data through API
  //TODO cambiar por servicio de crear viaje
  Future<TripModel> create_trip(
      int driverId, int routeId, int vehicleId) async {
    final trip = {
      "id_trip": 1,
      "start_ts": "2024-09-22T17:59:46.716875",
      "end_ts": "2024-09-22T18:00:06.299405",
      "distance": 0,
      "duration": "00:00:19.58253",
      "running": false,
      "schedule_start_time": "05:30:00",
      "schedule_end_time": "07:30:00",
      "route_id": 1,
      "route_description": "Ruta1",
      "bus_plate": "ABCDEF",
      "bus_model": "",
      "bus_year": 2006,
      "driver_id": 25,
      "monitor_id": 3,
      "relation_name_monitor": "eta.drivers"
    };
    final viaje = TripModel.fromJson(trip);
    return viaje;
    // Map data = {
    //   "driver_id": driverId,
    //   "route_id": routeId,
    //   "vehicle_id": vehicleId,
    //   "trip_status": 'Scheduled',
    // };

    // Map? body = {"model": 'create_trip', "params": jsonEncode(data)};
    // http.Response res = await postQuery('/mobile_api', body);

    // if (res.statusCode == 200) {

    //   return TripModel.fromJson(jsonDecode(res.body));
    // } else {
    //   throw "Unable to retrieve data.";
    // }
  }

  /// Submit form to update data through API
  Future<String> endTrip(String tripId) async {
    Map data = {
      "trip_id": tripId,
      "trip_status": 'Completed',
    };

    http.Response res = await postQuery(
        '/mobile_api', {"model": 'end_trip', "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Submit form to update data through API
  Future update_pickup(int pickupId, int tripId, String status) async {
    Map data = {
      "trip_id": tripId,
      "trip_pickup_id": pickupId,
      "status": status,
    };

    http.Response res = await postQuery(
        '/mobile_api', {"model": 'update_pickup', "params": jsonEncode(data)});

    if (res.statusCode == 200) {
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Submit form to update data through API
  Future update_destination(
      int destinationId, int tripId, String status) async {
    Map data = {
      "trip_id": tripId,
      "trip_destination_id": destinationId,
      "status": 'done',
    };

    http.Response res = await postQuery('/mobile_api',
        {"model": 'update_destination', "params": jsonEncode(data)});

    if (res.statusCode == 200) {
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Create an account as Driver
  signup(String firstName, String lastName, String email, String contactNumber,
      String gender) async {
    Map data = {
      "contact_number": contactNumber,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "gender": gender,
    };

    http.Response res = await postQuery(
        '/mobile_api', {"model": "Driver.signup", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body['success'] != null ? '1' : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  // request access to api
  requestAccess() async {
    debugPrint('requestAccess');
    final data = {
      '_client_id': '4926212245183',
      '_access_token': '8725ca59-71be-46c6-a364-eaac57f1786d'
    };

    final http.Response res =
        await postQuery('/rpc/request_access', data, useToken: false);

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      debugPrint(body.toString());
      await storage.setItem(
          'token', body['token'].isEmpty ? '' : body['token']);
      return '1';
    }

    return parseResponseMessage(res);
  }

  /// Login with email & password
  login(String email, String password) async {
    debugPrint('login');
    final data = {
      "_email": email,
      "_pass": password,
    };

    var requestAccessRes = await requestAccess();
    if (requestAccessRes == '1') {
      http.Response res = await postQuery('/rpc/login', data);

      if (res.statusCode == 200) {
        dynamic body = jsonDecode(res.body);

        debugPrint(body.toString());
        await storage.setItem(
            'token', body['token'].isEmpty ? '' : body['token']);
        await storage.setItem('driver_id', body['id_usu'] ?? body['id_usu']);
        try {
          final LoginInformation login =
              LoginInformationMapper.information(LoginInfo.fromJson(body));
          final userService =
              LoginInformationRepositoryImpl(LoginInformationDatasource());
          await userService.saveLogin(login);
        } on Exception catch (e) {
          debugPrint('Error saving login info: $e');
        }
        return '1';
      } else {
        return parseResponseMessage(res);
      }
    }

    return requestAccessRes;
  }

  /// Send message
  sendMessage(String subject, String message, String? priority) async {
    Map data = {
      "subject": subject,
      "message": message,
      "priority": priority,
      "status": 'new',
    };

    http.Response res = await postQuery('/mobile_api',
        {"model": "driver_help_message", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);

      return (body['success'] != null) ? body['result'] : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send message
  sendMessageComment(String comment, int messageId) async {
    Map data = {
      "message_id": messageId,
      "comment": comment,
    };

    http.Response res = await postQuery('/mobile_api/create',
        {"model": "HelpMessageComment.create", "params": jsonEncode(data)});
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);

      return body['success'] != null ? body['result'] : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send message
  Future<String> resetPassword(String email) async {
    Map data = {
      "email": email,
    };

    var requestAccessRes = await requestAccess();
    if (requestAccessRes == '1') {
      http.Response res = await postQuery('/rpc/update_password_request', data);

      if (res.statusCode == 200) {
        return '1';
      } else {
        return parseResponseMessage(res);
      }
    }

    return requestAccessRes;
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
    }
  }

  /// Send message
  resetChangePassword(String resetToken, String password) async {
    Map data = {
      "reset_token": resetToken,
      "password": password,
    };

    http.Response res = await postQuery('/mobile_api',
        {"model": "Drivers.resetChangePassword", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body['success'] != null ? body['result'] : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send message
  changePassword(String currentPassword, String newPassword,
      String confirmedPassword) async {
    Map data = {
      "current_password": currentPassword,
      "new_password": newPassword,
      "confirmed_password": confirmedPassword,
    };

    http.Response res = await postQuery('/mobile_api',
        {"model": "Driver.changePassword", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body['success'] != null ? body['result'] : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send Car Location
  sendLocation(int vehicleId) async {
    LocationData location = await getCurrentLocation();

    Map data = {
      "vehicle_id": vehicleId,
      "last_latitude": location.latitude,
      "last_longitude": location.longitude
    };

    http.Response res = await postQuery(
        '/mobile_api', {"model": "Vehicle.update", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send Car Location
  addStudent(Map data) async {
    http.Response res = await postQuery('/mobile_api/create',
        {"model": "Student.create", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      final studentResult = jsonDecode(res.body);

      if (studentResult['success'] != null) {
        final model = StudentModel.fromJson(studentResult['result']);
        return {"result": model, "error": null};
      } else {
        return {"result": studentResult['error'], "error": true};
      }
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Update student info
  updateStudentInfo(Map data) async {
    http.Response res = await postQuery('/mobile_api/update',
        {"model": "Student.updateStudentInfo", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      final studentResult = jsonDecode(res.body);

      if (studentResult['success'] != null) {
        return {"result": studentResult['result'], "error": null};
      } else {
        return {"result": studentResult['error'], "error": true};
      }
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Update student info
  Future<bool> saveWorkingDays(Map data) async {
    http.Response res = await postQuery('/mobile_api/update',
        {"model": "PickupLocation.update", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      final studentResult = jsonDecode(res.body);

      return (studentResult['success'] != null) ? true : false;
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send OneSignal id & token
  sendOneSignalId(
      String? driverId, String? oneSignalId, String? oneSignalToken) async {
    if (oneSignalId == null) {
      return null;
    }

    Map data = {
      "driver_id": driverId,
      "field": {"onesignal_id": oneSignalId, "onesignal_token": oneSignalToken},
    };

    await postQuery('/mobile_api/update',
        {"type": "Driver.update", "params": jsonEncode(data)});
  }

  /// Send Car Location
  readNotification(int? driverId, int? notificationId) async {
    if (notificationId == null) {
      return null;
    }

    Map data = {"driver_id": driverId, "id": notificationId, "status": 'read'};

    await postQuery('/mobile_api/update',
        {"type": "Notification.update", "params": jsonEncode(data)});
  }

  // Logout and clear localStorage
  logout() async {
    await storage.clear();
  }

  /// Search for addresses
  getSuggestion(String input) async {
    String sessionToken = Random(999).toString();
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request =
        '$baseURL?input=$input&key=$googleApiKey&sessiontoken=$sessionToken';
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      return json.decode(response.body)['predictions'];
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  /// Get location address
  getPlace(String input) async {
    String baseURL = 'https://places.googleapis.com/v1/places/';
    String request =
        '$baseURL$input?fields=id,location,formattedAddress,photos&key=$googleApiKey';
    var response = await http.get(Uri.parse(request));
    return json.decode(response.body);
  }

  Future<dynamic> sendTracking(
      {required BackgroundPosition position, int driver = 18}) async {
    debugPrint('sendTracking');
    final driverID = await storage.getItem('driver_id');
    final data = {
      'driver_id': driverID ?? driver,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speed': position.speed,
      'heading': position.heading,
      'time': position.time,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'speedAccuracy': position.speedAccuracy,
      'isMocked': position.isMocked
    };
    final jsonData = jsonEncode(data);
    try {
      // var requestAccessRes = await requestAccess();
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

  Future<dynamic> driverInfo(
      {required BackgroundPosition position, int driver = 18}) async {
    debugPrint('sendTracking');
    final driverID = await storage.getItem('driver_id');
    final data = {
      'driver_id': driverID ?? driver,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speed': position.speed,
      'heading': position.heading,
      'time': position.time,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'speedAccuracy': position.speedAccuracy,
      'isMocked': position.isMocked
    };
    final jsonData = jsonEncode(data);
    try {
      // var requestAccessRes = await requestAccess();
      http.Response res = await postQuery('/rpc/driver_info', null,
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
}
