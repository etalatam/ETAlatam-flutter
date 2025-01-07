// import 'package:eta_school_app/Pages/NotificationsPage.dart';
import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'user_avatar_widget.dart';

class Header extends StatefulWidget {

  Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header>{

  UserModel? user;

  @override
  Widget build(BuildContext context) {
    return Center(
        widthFactor: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Row(
            children: [
              const Image(
                image: AssetImage("assets/logo.png"),
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "${user?.firstName} ${user?.lastName}",
                    style: activeTheme.h6,
                  ),
                )                
              ),
              UserAvatar() 
            ],
          ),
        ));    
  }

    @override
  void initState() {
    super.initState();
    fetchLoginInfo();
  }
  
  void fetchLoginInfo() async {
    final info = await httpService.userInfo();
    setState(() {
      user  =  info;
    });
  }

}
