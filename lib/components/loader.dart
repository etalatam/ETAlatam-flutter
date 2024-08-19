import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              alignment: FractionalOffset.center,
              image: AssetImage('assets/loader.gif'),
            ),
          ),
          width: double.infinity,
        )
      )
    );
  }
}