import 'dart:convert';
import 'dart:math';
import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/Models/login_information_model.dart';
import 'package:eta_school_app/Pages/providers/driver_provider.dart';
import 'package:eta_school_app/domain/entities/user/driver.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';
import 'package:eta_school_app/infrastructure/datasources/login_information_datasource.dart';
import 'package:eta_school_app/infrastructure/mappers/driver_mapper.dart';
import 'package:eta_school_app/infrastructure/mappers/login_information_mapper.dart';
import 'package:eta_school_app/infrastructure/repositories/login_information_repository_impl.dart';
import 'package:eta_school_app/methods.dart';
// import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/Models/parent_model.dart';
import 'package:eta_school_app/Models/EventModel.dart';
import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/Models/NotificationModel.dart';
import 'package:location/location.dart';
import 'package:flutter/foundation.dart';

class HttpService {
  final LocalStorage storage = LocalStorage('tokens.json');

  String token = '';

  // String response_text = "";

  Map? headers;

  String getAvatarUrl(relationId, relationName) {
    return "$apiURL/rpc/get_reource_image?_relation_name=$relationName&_relation_id=$relationId";
  }

  String getImageUrl() {
    // return "$apiURL/app/image.php?src=";
    return "$apiURL/rpc/get_reource_image?_relation_name=eta.usuarios&_relation_id=";
  }

  String croppedImage(path, int? width, int? height) {
    // return "$apiURL/app/image.php?w=$width&h=$height&src=$path";
    return "https://admin.etalatam.com/assets/img$path";
  }

  /// Run API GET query
  getQuery(String path, {useToken = true}) async {
    final token = storage.getItem('token');
    final url = Uri.parse(apiURL + path);
    print("$url");
    return await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': useToken ? 'Bearer $token' : '',
    });
  }

  /// Run API POST query
  postQuery(String path, body,
      {useToken = true,
      contentType = 'application/x-www-form-urlencoded'}) async {
    final token = storage.getItem('token');
    final url = Uri.parse(apiURL + path);
    print("[Api.url] $url");
    return await http.post(url, body: body, headers: {
      'Content-Type': contentType,
      'Authorization': useToken ? 'Bearer $token' : '',
    });
  }

  /// Load Trips
  Future<List<TripModel>> getDriverTrips(int lastId) async {
    http.Response res = await getQuery(
        "/rpc/driver_trips?select=*&running=eq.false&limit=10&order=start_ts.desc");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body
            .map((dynamic item) async => TripModel.fromJson(item))
            .toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Trips
  Future<List<TripModel>> getStudentTrips(studentId) async {
    http.Response res = await getQuery(
        "/rpc/student_trips?select=*&running=eq.false&limit=10&order=start_ts.desc&student_id=$studentId");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<TripModel> trips = await Future.wait(
        body
            .map((dynamic item) async => TripModel.fromJson(item))
            .toList(),
      );
      return trips;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Latest Notifications
  Future<List<NotificationModel>?> getNotifications() async {
    http.Response res = await getQuery(
        "/rpc/notifications?order=id.desc");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

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
    http.Response res =
        await getQuery("/rpc/support_help_category?order=name.asc");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<SupportHelpCategory> supportHelpCategoryList =
          await Future.wait(
        body
            .map((dynamic item) async =>
                SupportHelpCategory.fromJson(item))
            .toList(),
      );
      return supportHelpCategoryList;
    }
    debugPrint(res.body.toString());
    return [];
  }

  /// Load Help Messages
  Future<List<HelpMessageModel>?> getHelpMessages() async {
    http.Response res = await getQuery("/rpc/support_message?order=id.desc");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

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
    http.Response res = await getQuery(
        "/rpc/driver_routes?select=*&limit=1&route_id=eq.$routeId");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

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

  /// Load Route info
  Future<RouteModel> getRouteInfo(id) async {
    http.Response res = await getQuery("/route/$id");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return RouteModel.fromJson(body);
    }
    return RouteModel(route_id: 0, route_name: '', pickup_locations: []);
  }

  // /// Load Driver
  Future<DriverModel> getDriver() async {
    http.Response res = await getQuery("/rpc/driver_info");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

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
    try {
      http.Response res = await postQuery('/rpc/student_info', null,
          contentType: 'application/json');
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return StudentModel.fromJson(json);
      } 
    } catch (e) {
      print("sendTracking error: ${e.toString()}");
    }
    return StudentModel(student_id: 0, parent_id: 0);
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
    var res = await getQuery("/rpc/driver_routes?limit=10");
    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        List<dynamic> body = jsonDecode(res.body);
        return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
        // await Future.wait(body
        //       .map((dynamic item) async => RouteModel.fromJson(item))
        //       .toList());
      } catch (e) {
        print("getRoutes error: ${e.toString()}");
        return [];
      }
    }

    return [];
  }

  ///
  // Future<List<RouteModel>> getRoutes() async {
  //   http.Response res = await getQuery(
  //     "/rpc/driver_routes?limit=10",
  //   );

  //   print("res.statusCode: ${res.statusCode}");
  //   print("res.body: ${res.body}");

  //   if (res.statusCode == 200) {
  //     try {
  //       final pickUpLocation = await getPickUpLocationPoint();
  //       final List<Map<String, dynamic>> body = jsonDecode(res.body);

  //       if (res.body.isEmpty) return [];
  //       // Recorrer la lista de pickUpLocation
  //       for (var route in body) {
  //         for (var location in pickUpLocation) {
  //           if (route["route_id"] == location["route_id"]) {
  //             route["pickup_location"] = {
  //               "schedule_start_time": location["schedule_start_time"],
  //               "schedule_end_time": location["schedule_end_time"],
  //               "bus_plate": location["bus_plate"],
  //               "bus_model": location["bus_model"],
  //               "bus_year": location["bus_year"],
  //               "driver_id": location["driver_id"],
  //               "monitor_id": location["monitor_id"]
  //             };
  //           }
  //         }
  //       }

  //       // Convertir todo el arreglo de forma asíncrona
  //       final List<RouteModel> routes = await Future.wait(body
  //             .map((dynamic item) async => await RouteModel.fromJson(item))
  //             .toList(),
  //       );
  //       return routes;
  //     } catch (e) {
  //       print("getRoutes error: ${e.toString()}");
  //       return [];
  //     }
  //   } else {
  //     print("erorr en peticion: ${res.toString()}");
  //   }

  //   return [];
  // }

  Future<List<Map<String, dynamic>>> getPickUpLocationPoint() async {
    http.Response res = await getQuery(
      "/rpc/route_pickup_points",
    );

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

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
    http.Response res =
        await getQuery("/rpc/driver_trips?select=*&limit=1&id_trip=eq.$id&order=id.desc");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      if (body == null) return TripModel(trip_id: 0);
      final TripModel trips = TripModel.fromJson(body[0]);
      return trips;
    }
    return TripModel(trip_id: 0);
  }

  /// Load Tripd
  Future<TripModel> getActiveTrip() async {
    http.Response res =
        await getQuery("/rpc/driver_trips?select=*&limit=1&running=eq.true");

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      try {
        var body = jsonDecode(res.body);
        if (body == null) return TripModel(trip_id: 0);
        final TripModel trips = TripModel.fromJson(body[0]);
        return trips;
      } catch (e) {
        print(e.toString());
      }
    }
    return TripModel(trip_id: 0);
  }

  /// Submit form to update data through API
  Future<TripModel> startTrip(int routeId) async {
    Map data = {
      "_route_id": "$routeId",
      // "driver_id": driverId,
      // "route_id": routeId,
      // "vehicle_id": vehicleId,
      // "trip_status": 'Scheduled',
    };

    // Map? body = {"model": 'create_trip', "params": jsonEncode(data)};
    // http.Response res = await postQuery('/mobile_api', body);

    http.Response res = await postQuery('/rpc/driver_start_trip', data);
    print("res.statusCode ${res.statusCode}");
    print("res.body ${res.body}");

    if (res.statusCode == 200) {
      return TripModel.fromJson(jsonDecode(res.body));
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  Future<StudentModel> updateAttendance(
      TripModel trip, StudentModel student, String statusCode) async {
    final data = jsonEncode({
      "id_school": student.schoolId,
      "id_student": student.student_id,
      "id_trip": trip.trip_id,
      "status_code": statusCode
    });

    print("[client.updateAttendance] $data");

    http.Response res = await postQuery('/rpc/update_attendance', data,
        contentType: 'application/json');
    print("res.statusCode ${res.statusCode}");
    print("res.body ${res.body}");

    if (res.statusCode == 200) {
      return StudentModel.fromJson(jsonDecode(res.body));
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  /// Submit form to update data through API
  Future<String> endTrip(String tripId) async {
    Map data = {
      // "trip_id": tripId,
      // "trip_status": 'Completed',
    };

    http.Response res = await postQuery('/rpc/driver_stop_trip', data);
    print("res.statusCode ${res.statusCode}");
    print("res.body ${res.body}");

    if (res.statusCode == 200) {
      return res.body;
    } else {
      throw "${parseResponseMessage(res)}/${res.statusCode}";
    }
  }

  /// Submit form to update data through API
  Future updatePickup(int pickupId, int tripId, String status) async {
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

    print("statuscode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      debugPrint(body.toString());
      await storage.setItem(
          'token', body['token'].isEmpty ? '' : body['token']);
      return '1';
    }

    return "${parseResponseMessage(res)}/${res.statusCode}";
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

      print("statuscode: ${res.statusCode}");
      print("res.body: ${res.body}");

      if (res.statusCode == 200) {
        dynamic body = jsonDecode(res.body);
        await storage.setItem('token', body['token'].isEmpty ? '' : body['token']);
        await storage.setItem('id_usu', body['id_usu'] ?? body['id_usu']);
        await storage.setItem('relation_name', body['relation_name'] ?? body['relation_name']);
        await storage.setItem('relation_id', body['relation_id'] ?? body['relation_id']);

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
        return "${parseResponseMessage(res)}/${res.statusCode}";
      }
    }

    return requestAccessRes;
  }

  // Future<List<TripModel>> getStudentTrips(int? studentId, int lastId) async {
  //   var res = await getQuery("mobile_api/student_trips?student_id=$studentId&lastId=$lastId");
  //   List<dynamic> body =  jsonDecode(res.body);
  //     return body .map( (dynamic item) => TripModel.fromJson(item) ) .toList();
  // }

  /// Load student
  Future<StudentModel> loadStudent(int? studentId) async {
    http.Response res = await postQuery('mobile_api', {"model":'student_locations', "params":jsonEncode({ "student_id" : studentId})});
    dynamic body =  jsonDecode(res.body);
    return body == null ? StudentModel(student_id: 0,parent_id: 0) : StudentModel.fromJson(body);
  }



  /// Send message
  Future<HelpMessageModel> sendMessage(
      int categoryId, String message, int priority) async {
    final data = {
      "category_id": categoryId,
      "content": message,
      "priority_id": priority
    };

    http.Response res = await postQuery(
        '/rpc/save_support_message', jsonEncode(data),
        contentType: 'application/json');

    print("[sendMessage] statuscode: ${res.statusCode}");
    print("[sendMessage] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      //return (body['success'] != null) ? body['result'] : body['error'];
      return HelpMessageModel.fromJson(body);
    }

    throw "${parseResponseMessage(res)}/${res.statusCode}";
  }

  /// Send message
  Future<CommentModel> sendMessageComment(String comment, int messageId) async {
    final data = {"message_id": messageId, "comment": comment};

    http.Response res = await postQuery(
        '/rpc/save_support_message_comment', jsonEncode(data),
        contentType: 'application/json');

    print("[sendMessageComment] statuscode: ${res.statusCode}");
    print("[sendMessageComment] res.body: ${res.body}");

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return CommentModel.fromJson(body);
    }

    throw "${parseResponseMessage(res)}/${res.statusCode}";
  }

  /// Send message
  Future<String> resetPassword(String email) async {
    Map data = {
      "email": email,
    };

    var requestAccessRes = await requestAccess();
    if (requestAccessRes == '1') {
      http.Response res = await postQuery('/rpc/update_password_request', data);

      print("res.statusCode: ${res.statusCode}");
      print("res.body: ${res.body}");

      if (res.statusCode == 200) {
        return '1';
      } else {
        return "${parseResponseMessage(res)}/${res.statusCode}";
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
      return 'Respuesta inesperada del servidor 😳';
    }
    // return "";
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

  Future<dynamic> sendTracking({required position, int driver = 18}) async {
    print('sendTracking.position $position');
    final userId = await storage.getItem('id_usu');
    final data = {
      'user_id': userId,
      'latitude': position['latitude'],
      'longitude': position['longitude'],
      'speed': position['speed'],
      'heading': position['heading'],
      'time': position['time'],
      'accuracy': position['accuracy'],
      'altitude': position['altitude']
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
    String url =
        "/rpc/route_students?order=firstname.desc&limit=$limit&offset=$offset";

    url = "$url&id_trip=eq.$tripId";

    if (filter.isNotEmpty) {
      url = "$url&or=(";
      url = "${url}firstname.ilike.*$filter*";
      url = "$url,lastname.ilike.*$filter*";
      url = "$url,address.ilike.*$filter*";
      url = "$url,school_name.ilike.*$filter*";
      url = "$url,pickup_point_name.ilike.*$filter*";
      url = "$url)";
    }

    http.Response res = await getQuery(url);

    print("res.statusCode: ${res.statusCode}");
    print("res.body: ${res.body}");

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      final List<StudentModel> students = await Future.wait(
        body
            .map((dynamic item) async => StudentModel.fromJson(item))
            .toList(),
      );
      return students;
    }
    debugPrint(res.body.toString());
    return [];
  }

  Future<dynamic> driverInfo() async {
    try {
      http.Response res = await postQuery('/rpc/driver_info', null,
          contentType: 'application/json');

      print("res.statusCode: ${res.statusCode}");
      print("res.body: ${res.body}");

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
      http.Response res = await postQuery('/rpc/user_info', null,
          contentType: 'application/json');

      print("res.statusCode: ${res.statusCode}");
      print("res.body: ${res.body}");
      
      if (res.statusCode == 200) {
        final json  = jsonDecode(res.body);
        // print("res.body.json: $json");
        return UserModel.fromJson(json);
      } 
    } catch (e) {
      print("userInfo error: ${e.toString()}");
      
    }
    return null;
  }
}
