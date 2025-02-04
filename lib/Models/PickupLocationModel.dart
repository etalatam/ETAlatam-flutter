class PickupLocationModel {
  int? pickup_id;
  int? route_id;
  String? location_name;
  String? address;
  double? latitude;
  double? longitude;
  double? destination_latitude;
  double? destination_longitude;
  String? distance;
  String? contact_number;
  String? picture;
  String? student_name;
  bool? status;
  // bool saturday;
  // bool sunday;
  // bool monday;
  // bool tuesday;
  // bool wednesday;
  // bool thursday;
  // bool friday;

  PickupLocationModel({
    this.pickup_id,
    this.route_id,
    this.latitude,
    this.longitude,
    this.location_name,
    this.picture,
    this.student_name,
    this.address,
    this.distance,
    this.contact_number,
    this.status,
    // this.saturday = false,
    // this.sunday = false,
    // this.monday = false,
    // this.tuesday = false,
    // this.wednesday = false,
    // this.thursday = false,
    // this.friday = false,
  });

  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      "pickup_id": pickup_id,
      "route_id": route_id,
      "latitude": latitude,
      "longitude": longitude,
      "location_name": location_name,
      "address": address,
      "contact_number": contact_number,
      "distance": distance,
      "student_name": student_name,
      "picture": picture,
      // "saturday": saturday,
      // "sunday": sunday,
      // "monday": monday,
      // "tuesday": tuesday,
      // "wednesday": wednesday,
      // "thursday": thursday,
      // "friday": friday,
    };
  }

  // void setAttributeValue(String attributeName, dynamic value) {
  //   switch (attributeName) {
  //     case 'saturday':
  //       saturday = value as bool;
  //       break;
  //     case 'sunday':
  //       sunday = value as bool;
  //       break;
  //     case 'monday':
  //       monday = value as bool;
  //       break;
  //     case 'tuesday':
  //       tuesday = value as bool;
  //       break;
  //     case 'wednesday':
  //       wednesday = value as bool;
  //       break;
  //     case 'thursday':
  //       thursday = value as bool;
  //       break;
  //     case 'friday':
  //       friday = value as bool;
  //       break;
  //   }
  // }

  factory PickupLocationModel.fromJson(json) {
    if (json == null) {
      return PickupLocationModel();
    }

    return PickupLocationModel(
      pickup_id: json['id_pickup_point'] as int?,
      route_id: json['route_id'] as int?,
      latitude: double.parse("${json['pickup_point_lat']}"),
      longitude: double.parse("${json['pickup_point_lon']}"),
      location_name: json['pickup_point_name'] as String?,
      address: json['pickup_point_address'] as String?,
      contact_number: json['contact_number'] as String?,
      picture: json['picture'] ?? "",
      student_name: json['student_name'] as String?,
      // status: json['status'] == 1 ? true : false as bool?,
      // saturday: json['saturdays'].toString().isNotEmpty ? true : false,
      // sunday: json['sundays'].toString().isNotEmpty ? true : false,
      // monday: json['mondays'].toString().isNotEmpty ? true : false,
      // tuesday: json['tuesdays'].toString().isNotEmpty ? true : false,
      // wednesday: json['wednesdays'].toString().isNotEmpty ? true : false,
      // thursday: json['thursdays'].toString().isNotEmpty ? true : false,
      // friday: json['fridays'].toString().isNotEmpty ? true : false,
    );
  }
}
