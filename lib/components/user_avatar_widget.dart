import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Pages/profile_page.dart';
import '../controllers/helpers.dart';
import '../methods.dart';

class UserAvatar extends StatefulWidget {
  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? relationId;
  String? relationName = "eta.usuarios";

  @override
  void initState() {
    super.initState();

    relationId = "${storage.getItem('relation_id')}";
    relationName = "${storage.getItem('relation_name')}";
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = httpService.getAvatarUrl(relationId, relationName);

    return GestureDetector(
        onTap: () {
          openNewPage(context, ProfilePage());
        },
        child: Stack(children: [
          Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 234, 244, 243),
                  radius: 50,
                  foregroundImage: NetworkImage(imageUrl,
                      headers: {'Accept': 'image/png'}))),
          Consumer<EmitterService>(builder: (context, emitterService, child) {
            return Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: emitterService.client().isConnected
                      ? Colors.green
                      : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            );
          }),
        ]));
  }
}
