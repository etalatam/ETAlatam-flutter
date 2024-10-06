import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:flutter/material.dart';
import '../Pages/ProfilePage.dart';
import '../controllers/Helpers.dart';
import '../methods.dart';

class UserAvatar extends StatefulWidget {
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  DriverModel? driver;

  Future<DriverModel> getDriver() async {
    final driverId = await storage.getItem('driver_id');
    return await httpService.getDriver(driverId);
  }

  @override
  void initState() {
    super.initState();
    getDriver().then((value) => driver = value);
  }

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: (() => {
        openNewPage(context, ProfilePage())
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: ShapeDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: driver?.picture !=
                            null &&
                        driver!.picture
                            !.isNotEmpty
                    ?
                    NetworkImage('${httpService.getImageUrl()}${driver?.picture}',
                      headers: {'Acept': 'image/png'})
                    : 
                    // AssetImage('assets/logo.png')
                    NetworkImage('https://ui-avatars.com/api/?name=${driver?.first_name}')

              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}