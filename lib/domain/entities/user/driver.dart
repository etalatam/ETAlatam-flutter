// ignore_for_file: non_constant_identifier_names
import 'package:isar/isar.dart';

part 'driver.g.dart';

@collection
class Driver {
  Id? isarId; //isar id
  int? driver_id;
  String? first_name;
  String? last_name;
  String? name;
  String? email;
  String? picture;
  String? contact_number;
  String? driver_license_number;

  Driver(
      {required this.driver_id,
      required this.first_name,
      this.last_name,
      this.name,
      this.email,
      this.picture,
      this.contact_number,
      this.driver_license_number});
}
