// import 'package:eta_school_app/Pages/NotificationsPage.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_avatar_widget.dart';

class Header extends StatefulWidget {

  Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header>{

  UserModel? user;

  bool connectivityNone = false;

  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;


  @override
  Widget build(BuildContext context) {
    return Center(
        widthFactor: 1,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
          ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 10),
          child: Row(
            children: [
              // if(connectivityNone)
              Expanded(
                flex: 1,
                child: AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastOutSlowIn,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20), // Cambia el valor para ajustar el radio
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white),
                        SizedBox(width: 10),
                        Text('No hay conexión a Internet', style: TextStyle(color: Colors.white)),
                      ],
                    )
                ),
              ),
              ),
            if(!connectivityNone)
              const Image(
                image: AssetImage("assets/logo.png"),
                width: 60,
                height: 60,
              ),
              const SizedBox(
                width: 10,
              ),
              if(!connectivityNone)
              Expanded(
                flex: 1,
                child: Center(
                  child: (user != null) ?
                    Text(
                    "${user?.firstName} ${user?.lastName}",
                    style: activeTheme.h6,
                  ) : Text(""),
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

    initConnectivity();

    _connectivitySubscription =
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }
  
  void fetchLoginInfo() async {
    final info = await httpService.userInfo();
    setState(() {
      user  =  info;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e.toString()}');
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    setState(() {
      connectivityNone = results.any((result) => result == ConnectivityResult.none);
    });
    // ignore: avoid_print
    print('connectivityNone: $connectivityNone');
  }  

}
