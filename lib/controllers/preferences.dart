import 'package:shared_preferences/shared_preferences.dart';

class PreferencesSetting  {
 
 
    // Storing item to preference
    void setItem(String name, String value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(name, value);
    }

    // Retrieving item from preference
    Future<String?> getItem(String name) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(name);
    }


    
    // Storing bool value to preference
    void setBool(String name, bool value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(name, value);
    }

    
    // Retrieving item from preference
    Future<bool?> getBool(String name) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(name);
    }



}