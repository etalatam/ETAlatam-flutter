import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/page_controller.dart' as p;

class CustomBottonNavigation extends StatelessWidget {
  const CustomBottonNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final p.PageController pageController = Get.find<p.PageController>();
    //Get.put(PageController())

    return Obx(() => BottomNavigationBar(
          currentIndex: pageController.currentIndex.value,
          selectedItemColor: Color.fromARGB(255, 59, 140, 135),
          unselectedItemColor: const Color.fromARGB(255, 61, 61, 61),
          onTap: (value) {
            pageController.changePage(value); // Cambia el índice
          },
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Configuración'),
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), label: "Inicio"),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Notificaciones"),
            BottomNavigationBarItem(
                icon: Icon(Icons.help_outline_outlined), label: 'Ayuda'),
          ],
        ));
  }
}
