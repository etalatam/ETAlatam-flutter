import 'package:eta_school_app/Models/DriverModel.dart';
import 'package:eta_school_app/domain/entities/user/driver.dart';

class DriverMapper {
  static Driver convert(DriverModel driver) => Driver(
      driver_id: driver.driver_id,
      first_name: driver.first_name,
      contact_number: driver.contact_number,
      driver_license_number: driver.driver_license_number,
      email: driver.email,
      last_name: driver.last_name,
      name: driver.name,
      picture: driver.picture);
}
