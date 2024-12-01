import 'package:flutter/material.dart';
import '../Pages/profile_page.dart';
import '../controllers/helpers.dart';
import '../methods.dart';

class UserAvatar extends StatefulWidget {
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {

  String? userId;

  @override
  void initState() {
    super.initState();
    
    storage.getItem('id_usu').then((value) => {
      setState(() {
        userId = value;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = httpService.getAvatarUrl(userId);
    print (imageUrl);

    return GestureDetector(
        onTap: () {
          openNewPage(context, ProfilePage());
        },
        child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.symmetric(
                horizontal: 5),
            child: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 234,244,243),
                radius: 50,
                foregroundImage: NetworkImage(imageUrl,headers: {'Accept': 'image/png'})
    )));
    // return  GestureDetector(
    //   onTap: (() => {
    //     openNewPage(context, ProfilePage())
    //   }),
    //   child: Row(
    //     mainAxisSize: MainAxisSize.min,
    //     mainAxisAlignment:
    //         MainAxisAlignment.start,
    //     crossAxisAlignment:
    //         CrossAxisAlignment.center,
    //     children: [
    //       Container(
    //         width: 60,
    //         height: 60,
    //         decoration: ShapeDecoration(
    //           image: DecorationImage(
    //             fit: BoxFit.fill,
    //             image: driver?.picture !=
    //                         null &&
    //                     driver!.picture
    //                         !.isNotEmpty
    //                 ?
    //                 NetworkImage('${httpService.getImageUrl()}${driver?.picture}',
    //                   headers: {'Accept': 'image/png'})
    //                 : 
    //                 // AssetImage('assets/logo.png')
    //                 NetworkImage('https://ui-avatars.com/api/?name=${driver?.first_name}')

    //           ),
    //           shape: RoundedRectangleBorder(
    //             borderRadius:
    //                 BorderRadius.circular(50),
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}