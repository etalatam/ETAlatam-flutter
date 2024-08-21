import 'dart:convert';
import 'dart:math';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
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
    return "${apiURL}app/image.php?src=";
  }

  String croppedImage(path, int? width, int? height) {
    return "${apiURL}app/image.php?w=$width&h=$height&src=$path";
  }

  /// Run API GET query
  getQuery(String path, {useToken = true}) async {
    var token = storage.getItem('token');
    return await http.get(Uri.parse(apiURL + path),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': useToken ? 'Bearer $token': '',
    });
  }

  /// Run API POST query
  postQuery(String path, body, {useToken=true}) async {
    var token = storage.getItem('token');
    return await http.post(Uri.parse(apiURL + path),
        body: body, headers: {
          // 'Content-Type': 'application/json',
          'Authorization': useToken ? 'Bearer $token' : '',
        });
  }

  /// Load Trips
  Future<List<TripModel>> getTrips(int lastId) async {
    var res = await getQuery("mobile_api/trips?lastId=$lastId");
    List<dynamic> body = jsonDecode(res.body);
    return body.map((dynamic item) => TripModel.fromJson(item)).toList();
  }

  /// Load Latest Notifications
  Future<List<NotificationModel>?> getNotifications() async {
    var res = await getQuery("mobile_api/notifications");
    dynamic resObject = jsonDecode(res.body);
    List<dynamic> body = jsonDecode(jsonEncode(resObject['items']));
    return body
        .map((dynamic item) => NotificationModel.fromJson(item))
        .toList();
  }

  /// Load Help Messages
  Future<List<HelpMessageModel>?> getHelpMessages() async {
    var res = await getQuery("mobile_api/help_messages");
    List<dynamic> body = jsonDecode(res.body);
    return body.map((dynamic item) => HelpMessageModel.fromJson(item)).toList();
  }

  /// Load Route
  Future<List<RouteModel>> getRoute(String model) async {
    var res = await getQuery(model);
    List<dynamic> body = jsonDecode(res.body);
    return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
  }

  /// Load Route info
  Future<RouteModel> getRouteInfo(id) async {
    var res = await getQuery("route/$id");
    var body = jsonDecode(res.body);
    return body == null
        ? RouteModel(route_id: 0, route_name: '', pickup_locations: [])
        : RouteModel.fromJson(body);
  }

  /// Load Driver
  Future<DriverModel> getDriver(id) async {
  //   var res = await getQuery("driver/$id");
  //   var body = jsonDecode(res.body);
  //   return body == null
  //       ? DriverModel(driver_id: 0, first_name: '')
  //       : DriverModel.fromJson(body);
    return DriverModel(driver_id: 0, first_name: '');
  }

  /// Load Driver
  Future<ParentModel> getParent(id) async {
    var res = await getQuery("parent/$id");
    var body = jsonDecode(res.body);
    return body == null
        ? ParentModel(parent_id: 0, students: [])
        : ParentModel.fromJson(body);
  }

  /// Load Student pickup
  Future<PickupLocationModel> getPickup(int? id) async {
    var res = await getQuery("mobile_api/student_pickup?student_id=$id");
    var body = jsonDecode(res.body);
    return body == null
        ? PickupLocationModel()
        : PickupLocationModel.fromJson(body);
  }

  /// Load Events
  Future<List<EventModel>> getEvents() async {
    // var res = await getQuery("events?load=json");
    // var jsonResponse = jsonDecode(res.body);
    // List<dynamic> body = jsonResponse['items'] ?? [];
    // return body.map((dynamic item) => EventModel.fromJson(item)).toList();
    return [];
  }

  /// Load Routes
  Future<List<RouteModel>> getRoutes() async {
    var res = await getQuery("driver_routes");
    List<dynamic> body = jsonDecode(res.body);
    return body.map((dynamic item) => RouteModel.fromJson(item)).toList();
  }

  /// Load Trip
  Future<TripModel> getTrip(id) async {
    var res = await getQuery("trip/$id");
    var body = jsonDecode(res.body);

    return body == null ? TripModel(trip_id: 0) : TripModel.fromJson(body);
  }

  /// Load Trip
  Future<TripModel> getActiveTrip() async {
    http.Response res =
        await postQuery('mobile_api', {"model": "Driver.getActiveDriverTrip"});
    var body = jsonDecode(res.body);
    return (body == null || body.toString() == '[]')
        ? TripModel(trip_id: 0)
        : TripModel.fromJson(body);
  }

  /// Submit form to update data through API
  Future<TripModel> create_trip(
      int driverId, int routeId, int vehicleId) async {
    Map data = {
      "driver_id": driverId,
      "route_id": routeId,
      "vehicle_id": vehicleId,
      "trip_status": 'Scheduled',
    };

    Map? body = {"model": 'create_trip', "params": jsonEncode(data)};
    http.Response res = await postQuery('mobile_api', body);

    if (res.statusCode == 200) {
      return TripModel.fromJson(jsonDecode(res.body));
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Submit form to update data through API
  Future<String> endTrip(String tripId) async {
    Map data = {
      "trip_id": tripId,
      "trip_status": 'Completed',
    };

    http.Response res = await postQuery(
        'mobile_api', {"model": 'end_trip', "params": jsonEncode(data)});

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
        'mobile_api', {"model": 'update_pickup', "params": jsonEncode(data)});

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

    http.Response res = await postQuery('mobile_api',
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
        'mobile_api', {"model": "Driver.signup", "params": jsonEncode(data)});

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
        '_client_id': '8158677453437', 
        '_access_token': 'a9b44b37-b305-42e8-af90-8e0238bd3724'
      };
      
      final http.Response res = await postQuery('/rpc/request_access', data,useToken: false);

      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        debugPrint(body.toString());
        await storage.setItem(
          'token', body['token'].isEmpty ? '' : body['token']
        );
        return '1';
      }else{
        try {
          debugPrint(res.body.toString());
          var body = jsonDecode(res.body);

          if("${body['hint']}".isEmpty == false){
            return body['hint'];
          }else if("${body['message']}".isEmpty == false){
            return body['message'];
          }
        } catch (e) {
          debugPrint(e.toString());
        }

        return 'Unable to request access';
      }
  }

  /// Login with email & password
  login(String email, String password) async {
    debugPrint('login');
    final data = {
      "_email": email,
      "_pass": password,
    };

    var requestAccessRes = await requestAccess();
    if( requestAccessRes == '1') {
      http.Response res = await postQuery('/rpc/login', data);

      if (res.statusCode == 200) {
        var body = jsonDecode(res.body);
        debugPrint(body.toString());
        await storage.setItem(
            'token', body['token'].isEmpty ? '' : body['token']);
        await storage.setItem(
            'user_id', body['user_id'] ?? body['user_id']);
        return '1';
      } else {
        try {
          debugPrint(res.body.toString());
          var body = jsonDecode(res.body);
          if("${body['hint']}".isEmpty == false){
            return body['hint'];
          }else if("${body['message']}".isEmpty == false){
            return body['message'];
          }
        } catch (e) {
          debugPrint(e.toString());
        }

        return 'Unable to login';
      }
    }else{
      return requestAccessRes;
    }
  }

  /// Send message
  sendMessage(String subject, String message, String? priority) async {
    Map data = {
      "subject": subject,
      "message": message,
      "priority": priority,
      "status": 'new',
    };

    http.Response res = await postQuery('mobile_api',
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

    http.Response res = await postQuery('mobile_api/create',
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

    http.Response res = await postQuery('mobile_api',
        {"model": "Drivers.resetPassword", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      return body['success'] != null ? body['result'] : body['error'];
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send message
  resetChangePassword(String resetToken, String password) async {
    Map data = {
      "reset_token": resetToken,
      "password": password,
    };

    http.Response res = await postQuery('mobile_api',
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

    http.Response res = await postQuery('mobile_api',
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
        'mobile_api', {"model": "Vehicle.update", "params": jsonEncode(data)});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw "Unable to retrieve data.";
    }
  }

  /// Send Car Location
  addStudent(Map data) async {
    http.Response res = await postQuery('mobile_api/create',
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
    http.Response res = await postQuery('mobile_api/update',
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
    http.Response res = await postQuery('mobile_api/update',
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

    await postQuery('mobile_api/update',
        {"type": "Driver.update", "params": jsonEncode(data)});
  }

  /// Send Car Location
  readNotification(int? driverId, int? notificationId) async {
    if (notificationId == null) {
      return null;
    }

    Map data = {"driver_id": driverId, "id": notificationId, "status": 'read'};

    await postQuery('mobile_api/update',
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
}
