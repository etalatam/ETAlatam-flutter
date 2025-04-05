import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class NoActiveTripPage extends StatelessWidget {
  NoActiveTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: 250, // Aumenté la altura para mejorar la distribución del contenido
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: const EdgeInsets.fromLTRB(25, 0, 25, 10),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              shadows: [
                  BoxShadow(
                    color: activeTheme.main_color.withOpacity(.3),
                    blurRadius: 10,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Icon(
                  Icons.timer,
                  color: activeTheme.main_color,
                  size: 50,
                ),
                Text(
                  lang.translate("does_not_have_active_trips"),
                  style: TextStyle(
                    color: activeTheme.main_color,
                    fontSize: activeTheme.h5.fontSize,
                    fontFamily: activeTheme.h6.fontFamily,
                    fontWeight: activeTheme.h6.fontWeight,
                  ),
                ),
                Text(
                  lang.translate("please_wait_for_a_trip"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: activeTheme.main_color.withOpacity(0.8),
                    fontFamily: activeTheme.h6.fontFamily,
                    fontWeight: activeTheme.h6.fontWeight,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeTheme.buttonBG,
                    foregroundColor: activeTheme.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                     Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text(lang.translate("refresh")),
                ),
              ],
            ),
          ),
          ),
           Positioned(left: 0, right: 0, top: 0, child: Header())
        ],
      ),
    );
  }
  
}
