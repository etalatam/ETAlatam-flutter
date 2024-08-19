import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  Rx<Locale> selectedLocale = const Locale('en').obs; // Default locale

  void changeLocale(Locale newLocale) {
    selectedLocale.value = newLocale;
    _saveLocale(newLocale); // Save the selected locale to local storage
    Get.updateLocale(newLocale); // Update the locale for the entire app
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      selectedLocale.value = Locale(savedLocale);
    }
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', locale.toString());
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      selectedLocale.value = Locale(savedLocale.split('_')[0], savedLocale.split('_')[1]);
    }
  }
}