import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/page_controller.dart' as p;

class CustomBottonNavigation extends StatelessWidget {
  const CustomBottonNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final p.PageController pageController = Get.find<p.PageController>();

    return Obx(() => BottomNavigationBar(
          currentIndex: pageController.currentIndex.value,
          onTap: (value) {
            pageController.changePage(value); // Cambia el índice
          },
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Configuración'),
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Inicio"),
            BottomNavigationBarItem(
                icon: Icon(Icons.help_outline_outlined), label: 'Ayuda'),
          ],
        ));
  }
}
