import 'package:get/get.dart';

class PageController extends GetxController {
  var currentIndex = 1.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
