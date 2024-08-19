class DestinationModel {
  
  int? destination_id;
  int? route_id;
  String? location_name;
  String? address;
  double? latitude;
  double? longitude;
  String? distance;
  String? contact_number;
  String? picture;
  String? status;
  String? student_name;

  DestinationModel({
    this.destination_id,
    this.route_id,
    this.latitude,
    this.longitude,
    this.location_name,
    this.picture,
    this.address,
    this.distance,
    this.contact_number,
    this.status,
    this.student_name,
  });

  
  
  
  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      "destination_id" : destination_id,
      "route_id" : route_id,
      "latitude" :latitude,
      "longitude" : longitude,
      "location_name" : location_name,
      "address" : address,
      "contact_number" :contact_number,
      "distance" : distance,
      "status" : status,
      "student_name" : student_name,
    };
  }



  factory DestinationModel.fromJson( json) {
    return DestinationModel(
      destination_id: json['destination_id'] as int?,
      route_id: json['route_id'] as int?,
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      location_name: json['location_name'] as String?,
      address: json['address'] as String?,
      contact_number: json['contact_number'] as String?,
      picture: json['picture'] as String?,
      status: json['status'] as String?,
      student_name: json['student_name'] as String?,
    );
  }

}