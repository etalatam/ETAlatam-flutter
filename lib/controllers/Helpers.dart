import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:localstorage/localstorage.dart';
import 'package:MediansSchoolDriver/controllers/preferences.dart';
import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/controllers/locale.dart';
import 'package:MediansSchoolDriver/controllers/langs.dart';
import 'package:google_fonts/google_fonts.dart';



/// Main API configuration options
const String apiURL = "https://trips.medianssolutions.com/";

/// Google Client API
const String googleClientId = "815917645468-uclp0ar0v8vu84s81bcqe1fo3oiljioh.apps.googleusercontent.com"; // For Map API

/// Important Note
/// Make sure to add this key at the android/app/src/main/AndroidManifest.xml file 
const String googleApiKey = "AIzaSyArS67tdH2dJB64hfE0zCh1treUYgHjNm0"; // For Places API

/// OneSignal Client API
const String oneSignalClientId = "8c316c75-1878-4bf9-99ad-3964bb83f525";

/// Firebase API Key 
const  String firebaseApiKey = '**********************************';

/// Firebase API ID 
const String firebaseAppId = '1:*****:android:*****';

/// Firebase Sender ID 
const String firebaseSenderId = '**********';

/// Firebase Project ID 
const String firebaseProjectId = '**********';

// Set
bool darkMode = true;

bool switchTheme = false;

DefaultTheme activeTheme = MediansTheme.theme;
DarkTheme darkTheme = DarkTheme();
LightTheme lightTheme = LightTheme();

/// Main locatl storage file
LocalStorage storage =  LocalStorage('tokens.json');

/// Locale controller for languages preferences  
LocaleController localeController = Get.find<LocaleController>();

/// Locale controller for languages preferences  
PreferencesSetting preferences = Get.find<PreferencesSetting>();

/// Client API Service
HttpService httpService = HttpService();


/// Language Oject
Lang lang =  Lang(key: null, value: null, locale: null);



mixin MediansTheme
{
  static DefaultTheme theme = storage.getItem('darkmode') == true ? DarkTheme() : LightTheme() ; 
}


class LightTheme implements DefaultTheme
{
    /// 
    /// Colors 
    static Color default_color = const Color(0xff1e3050);
    static Color default_bg =  Colors.white;
    @override
  Color main_color =  default_color;
    @override
  Color main_bg =  default_bg;
    @override
  Color icon_color =  const Color.fromARGB(255, 48, 75, 122);
    @override
  Color border_color =  const Color.fromARGB(255, 205, 214, 231);
    @override
  Color textColor =  const Color(0xff1e3050);
    @override
  Color shadowColor =  Colors.black.withOpacity(.2);
    @override
  Color darkBlueColor = const Color(0xff1e3050);


    /// Tabs
    @override
  Color tabContainerBG = Colors.white ;
    @override
  Color tabBG = default_bg;
    @override
  Color tabColor = default_color;

    /// Buttons
    @override
  Color buttonBG = const Color(0xff1e3050);
    @override
  Color buttonColor =  Colors.white.withOpacity(.9);
    @override
  Color buttonSecondBG = Colors.deepPurple;


    /// Test Styles
    @override
  TextStyle h1 = TextStyle(color: default_color, fontSize: 36, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily);
    @override
  TextStyle h2 = TextStyle(color: default_color, fontSize: 32, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily);
    @override
  TextStyle h3 = TextStyle(color: default_color, fontSize: 28, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily);
    @override
  TextStyle h4 = TextStyle(color: default_color, fontSize: 24, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily,);
    @override
  TextStyle h5 = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily);
    @override
  TextStyle h6 = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: GoogleFonts.cairo().fontFamily);
    @override
  TextStyle xsmallText = TextStyle(color: default_color, fontSize: 12, fontFamily: GoogleFonts.elMessiri().fontFamily); 
    @override
  TextStyle smallText = TextStyle(color: default_color, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.elMessiri().fontFamily);
    @override
  TextStyle normalText = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.elMessiri().fontFamily);
    @override
  TextStyle largeText = TextStyle(color: default_color, fontSize: 18, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.elMessiri().fontFamily);
    @override
  TextStyle xlargeText = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.elMessiri().fontFamily);
}


class DarkTheme implements DefaultTheme
{
      /// Colors 
    /// 
    
    static Color default_color =  Colors.white;
    static Color default_bg =  const Color(0xff1e3050);
    @override
  Color main_color =  default_color;
    @override
  Color main_bg =  default_bg;
    @override
  Color border_color =  const Color.fromARGB(255, 13, 23, 40);
    @override
  Color icon_color =  Colors.white;
    @override
  Color textColor =  Colors.white.withOpacity(.9);
    @override
  Color shadowColor =  Colors.black.withOpacity(.2);
    @override
  Color darkBlueColor = const Color(0xff1e3050);
    @override
  Color tabContainerBG =  default_bg;
    @override
  Color tabBG =  const Color(0xff1e3050); 
    @override
  Color tabColor =  Colors.white; 

    /// Buttons
    @override
  Color buttonBG =  Colors.white.withOpacity(.9) ;
    @override
  Color buttonColor =  const Color(0xff1e3050) ;
    @override
  Color buttonSecondBG = Colors.deepPurple;

    /// Test Styles
    @override
  TextStyle h1 = TextStyle(color: default_color, fontSize: 36, fontWeight: FontWeight.w600);
    @override
  TextStyle h2 = TextStyle(color: default_color, fontSize: 32, fontWeight: FontWeight.w600);
    @override
  TextStyle h3 = TextStyle(color: default_color, fontSize: 28, fontWeight: FontWeight.w600);
    @override
  TextStyle h4 = TextStyle(color: default_color, fontSize: 24, fontWeight: FontWeight.w600);
    @override
  TextStyle h5 = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w600);
    @override
  TextStyle h6 = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w600);
    @override
  TextStyle xsmallText = TextStyle(color: default_color, fontSize: 12);
    @override
  TextStyle smallText = TextStyle(color: default_color, fontSize: 14, fontWeight: FontWeight.w400);
    @override
  TextStyle normalText = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w400);
    @override
  TextStyle largeText = TextStyle(color: default_color, fontSize: 18, fontWeight: FontWeight.w400);
    @override
  TextStyle xlargeText = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w400);
}

abstract class DefaultTheme
{
      /// Colors 
    /// 
    
    static Color default_color =  Colors.transparent;
    static Color default_bg =  Colors.transparent;
    Color main_color =  Colors.transparent;
    Color main_bg =  Colors.transparent;
    Color border_color =  Colors.transparent;
    Color icon_color =  Colors.transparent;
    Color textColor =  Colors.transparent;
    Color shadowColor =  Colors.transparent;
    Color darkBlueColor = Colors.transparent;
    Color tabContainerBG =  default_bg;
    Color tabBG =  Colors.transparent; 
    Color tabColor =  Colors.transparent; 

    /// Buttons
    Color buttonBG =  Colors.transparent ;
    Color buttonColor =  Colors.transparent ;
    Color buttonSecondBG = Colors.transparent;

    /// Test Styles
    TextStyle h1 = TextStyle(color: default_color, fontSize: 36, fontWeight: FontWeight.w600);
    TextStyle h2 = TextStyle(color: default_color, fontSize: 32, fontWeight: FontWeight.w600);
    TextStyle h3 = TextStyle(color: default_color, fontSize: 28, fontWeight: FontWeight.w600);
    TextStyle h4 = TextStyle(color: default_color, fontSize: 24, fontWeight: FontWeight.w600);
    TextStyle h5 = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w600);
    TextStyle h6 = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w600);
    TextStyle xsmallText = TextStyle(color: default_color, fontSize: 12);
    TextStyle smallText = TextStyle(color: default_color, fontSize: 14, fontWeight: FontWeight.w400);
    TextStyle normalText = TextStyle(color: default_color, fontSize: 16, fontWeight: FontWeight.w400);
    TextStyle largeText = TextStyle(color: default_color, fontSize: 18, fontWeight: FontWeight.w400);
    TextStyle xlargeText = TextStyle(color: default_color, fontSize: 20, fontWeight: FontWeight.w400);
}

Color shadowColor =  Colors.black.withOpacity(.2);
Color darkBlueColor = const Color(0xff1e3050);

setColors()
{
    storage =   LocalStorage('tokens.json');
    darkMode = storage.getItem('darkmode') == true ? true : false;

      /// Custom  color
}