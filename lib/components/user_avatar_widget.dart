import 'package:eta_school_app/components/image_default.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String? nomUsu;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    relationId = "${await storage.getItem('relation_id')}";
    relationName = "${await storage.getItem('relation_name')}";
    nomUsu = await storage.getItem('nom_usu') ?? "sn";
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = httpService.getImage(relationId, relationName);
    return GestureDetector(
        onTap: () {
          openNewPage(context, ProfilePage());
        },
        child: Stack(children: [
          SizedBox(
              width: 44,
              height: 44,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  imageUrl,
                  headers: {
                    'Accept': 'image/png'
                  },
                  fit: BoxFit.fill,
                  height: 44,
                  width: 44,
                 loadingBuilder: (context, child, loadingProgress){
                    if (loadingProgress == null) {
                      return child;
                    }
                    return CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace){
                    return  ImageDefault(name: nomUsu!, height: 44, width: 44);
                    },
                ),
              ),
          ),
          Consumer<EmitterService>(builder: (context, emitterService, child) {
            return Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: emitterService.isConnected()
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
