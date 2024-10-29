import 'dart:core';

import 'package:localstorage/localstorage.dart';

class Lang {
  String? key;
  String? value;
  String? locale;
  List<Map> langList = [];

  Lang({
    required this.key,
    required this.value,
    required this.locale,
  }) {
    langList.addAll([esLangs, enLangs]);
  }

  factory Lang.fromJson(Map<String, dynamic> json) {
    return Lang(
      key: json['key'] as String?,
      value: json['value'] as String?,
      locale: json['value'] as String?,
    );
  }

  translate(String key) {
    final LocalStorage storage = LocalStorage('tokens.json');
    String lang = storage.getItem('lang').toString();
    Map data;

    switch (lang) {
      case 'English':
        data = enLangs;
        break;
      default:
        data = esLangs;
        break;
    }

    var item = key.replaceAll(' ', '_').toLowerCase();

    return data.containsKey(item) ? data[item] : key;
  }

  Map<String, dynamic> arLangs = {
    'sitename': 'Medians Trips',
    'error': 'خطأ',
    'first_name': 'الإسم الأول',
    'last_name': 'الإسم الاخير',
    'your_active_trip': 'رحلتك الحالية',
    'continue_trip': 'إستكمال الرحلة',
    'start_trip': 'بدء الرحلة',
    'welcome': 'مرحبا بك',
    'send_message': 'إرسال رسالة',
    'have_a_problem': 'هل لديك مشكلة ؟',
    'follow_your_upcoming_trips_from_this_list':
        'يمكنك متابعة رحلاتك القادمة و الحالية من هنا',
    'trips_history': 'سجل الرحلات السابقة',
    'your_route': 'خط السير الخاص بك',
    'route': 'خط السير',
    'send_message_if_you_need_any_help':
        'يمكنك إرسال رسالة الى الدعم الفني للمساعدة',
    'trip': 'رحلة',
    'email': 'البريد الإلكتروني',
    'view_trip': 'عرض الرحلة',
    'view_more': 'عرض المزيد',
    'end_trip': 'إنهاء الرحلة',
    'we_can_help': 'يمكننا المساعدة',
    'pickup_done': 'تم الإنهاء',
    'Delivered': 'تم التوصيل',
    'welcome_back': 'أهلا بعودتك',
    'password': 'كلمة المرور',
    'sign_in': 'تسجيل الدخول',
    'create_new_account': 'إنشاء حساب جديد',
    'route_pickup_locations': 'نقاط توقف خط السير',
    'pickup_locations': 'أماكن التوقف',
    'call': 'إتصال',
    'close': 'إغلاق',
    'show_map': 'عرض علي الخريطة',
    'get_in_contact': 'تواصل بشكل مباشر',
    'search_by_name': 'البحث عن طريق الإسم أو العنوان',
    'login_intro_message':
        'تابع ابنائك بكل أمان. \nيرجي تسجيل الدخول إلي حسابك.',
    'distance_to_pickup_location': 'المسافة بينك وبين نفطة التوقف ',
    'list_of_route_pickup_locations': 'عرض سجل جميع الرحلات السابقة',
    'view_all_trips_history': 'عرض سجل جميع الرحلات السابقة',
    'send_your_message_below':
        'إذا كان لديك أي مشكلة أو بحاجة الى المساعدة, \n أرسل رسالتك هنا',
    'subject': 'الموضوع',
    'send_now': 'إرسل الان',
    'message': 'الرسالة',
    'your_message_here': 'إكتب رسالتك هنا ...',
    'allow_recieve_notifications': 'السماح بإستلام التنبيهات',
    'notifications': 'التنبيهات',
    'language': 'اللغة',
    'languages': 'اللغات',
    'help_page': 'صفحة المساعدة',
    'select_your_language': 'إختر لغتك المفضلة',
    'trip_sueccessfully_ended': 'تم إنهاء الرحلة بنجاح',
    'trip_duration': 'مدة الرحلة',
    'trip_number': 'رقم الرحلة',
    'trip_status': 'حالة الرحلة',
    'completed': 'إنتهت',
    'pickups': 'نقاط التوقف',
    'license_number': 'رقم الرخصة',
    'contact_number': 'رقم التواصل',
    'you_have_no_route_yet': 'ليس لديك أى خطوط سير مرتبطة بحسابك',
    'no_data_here': 'لا يوجد بيانات',
    'back': 'عودة للخلف',
    'no_pickup_locations_at_this_trip': 'لا يوجد نقاط توقف في هذه الرحلة',
    'no_pickup_locations_at_this_route': 'لا يوجد نقاط توقف في خط السير',
    'no_pickup_locations_here': 'لا يوجد نقاط توقف هنا',
    'your_help_messages': 'رسائل المساعدة التي ارسلتها',
    'ticket_number': 'رقم المتابعة',
    'department': 'القسم',
    'status': 'الحالة',
    'priority': 'الأولوية',
    'time': 'الوقت',
    'support_comments': 'تعليقات الدعم الفني',
    'comment': 'التعليق',
    'view_ticket': 'عرض الرسالة',
    'notifications_list': 'قائمة التنبيهات',
    'list_of_your_notifications': 'قائمة لأحدث التنبيهات و الإشعارات الخاصة بك',
    'your_old_sent_messages_list': 'الرسائل المرسلة',
    'click_here_to_view_your_previous_sent_messages':
        'قائمة بالرسائل التي تم إرسالها من قبل',
    'new': 'جديدة',
    'all': 'الجميع',
    'logout': 'تسجيل الخروج',
    'closed': 'مغلقة',
    'app_preferences': 'إعدادات التطبيق',
    'get_permission': 'عرض الصلاحيات',
    'get_permissions': 'عرض الصلاحيات',
    'dark_mode': 'النظام الليلي',
    'show_template_in_darkmode': 'عرض التصميم بألوان داكنة',
    'next': 'التالي',
    'set_your_custom_configuration': 'قم بضبط إعداداتك الخاصة',
    'start_now': 'إبدأ الان',
    'start_with_your_account': 'إبدأ الان بحسابك الشخصي',
    'some_permissions_are_required_to_use_the_app':
        'بعض الصلاحيات مطلوبة لإستخدام التطبيق',
    'create_your_account': 'انشيْ حسابك الان',
    'forgot_password': 'نسيت كلمة المرور ؟',
    'confirm': 'تأكيد',
    'view': 'عرض',
    'updated': 'تم التحديث',
    'updated_successfully': 'تم التحديث بنجاح',
    'available_routes': 'خطوط السير المتاحة',
    'list_of_your_added_children': 'قائمة بالأطفال الذين تم إضافتهم',
    'view_details': 'عرض التفاصيل',
    'add_student': 'إضافة طالب',
    'add_new_student_now': 'إضافة طالب جديد الان',
    'start_now_with_filling_new_student_information':
        'إبدأ الان باضافة بيانات الطالب وسيتم المراجعة والرد عليك بأقرب وقت',
    'student_info_updated':
        'سيتم مراجعة البيانات و سيتم التواصل معك في أقرب وقت',
    'forgot_password_message': 'سيتم إرسال رقم التأكيد علي البريد الإلكتروني',
    'scheduled': 'تم البدء',
    'trips': 'الرحلات',
    'working_days': 'أيام الدراسة',
    'week_days_that_you_need_to_pickup': 'أيام الأسبوع التي يتم الالتقاء فيها',
    'vacations': 'الأجازات',
    'vacations_days_subtitle': 'أيام الأجازات او الغياب',
    'pickup_and_destinations': 'أماكن اللقاء و التوصيل',
    'locations': 'المواقع',
    'save': 'حفظ',
    'go_home': 'الذهاب للرئيسية',
    'approved': 'مفعل',
    'pending': 'تحت المراجعة',
    'change_password': 'تغيير كلمة المرور',
    'current_password': 'كلمة المرور الحالية',
    'new_password': 'كلمة المرور الجديدة',
    'confirm_password': 'تأكيد كلمة المرور',
    'change_password_message':
        'يمكنك تغيير كلمة المرور من هنا, ويجب ان لا تقل عن 6 حروف او ارقام',
    'required_information': 'البيانات المطلوبة',
    'you_need_to_complete_some_required_information':
        'هناك بعض البيانات المطلوبة يجب استكمالها',
    'complete_information': 'استكمال البيانات',
    'thanks_for_submitting': 'شكرا علي الإرسال',
    'distance': 'المسافة',
    'destinations': 'أماكن التوصيل',
    '': '',
    'login_copyrights': '',
  };

  Map<String, dynamic> enLangs = {
    'sitename': 'Medians Trips',
    'trips_history': 'Trips log history',
    'show_map': 'Show map route',
    'login_intro_message':
        'Please create your account with your valid information. \nSign in to manage your account.',
    'send_your_message_below':
        'If you have any issue or need any help. \nSend your message below.',
    'your_message_here': 'Type your message ...',
    'you_have_no_route_yet': "You don't have any route yet",
    'login_copyrights': '',
    'forgot_password': 'Forgot your password ?',
    'student_info_updated':
        "We'll review your information, and we'll contact you ASAP",
    'vacations_days_subtitle': 'Vacations & absense days',
    'pickup_and_destinations': 'Pickup & Destination places',
    'you_need_to_complete_some_required_information':
        'you need to complete some required information',
    'forgot_password_message':
        'Add your email and we will send you reset password code through email',
    'change_password_message':
        'You can find your token at your email, and change your password and confirmation',
    '': '',
  };

  Map<String, dynamic> esLangs = {
    'sitename': 'ETA Latam',
    'trips_history': 'Historial de viajes',
    'show_map': 'Mostrar ruta en el mapa',
    'login_intro_message': 'Inicie sesión con su usuario y contraseña.',
    'send_your_message_below':
        'Si tiene algún problema o necesita ayuda. \nEnvíe su mensaje a continuación.',
    'your_message_here': 'Escribe tu mensaje...',
    'you_have_no_route_yet': "Aún no tienes ninguna ruta",
    'login_copyrights': '',
    'forgot_password': '¿ Olvidaste tu contraseña ?',
    'student_info_updated':
        "Revisaremos su información y nos comunicaremos con usted lo antes posible.",
    'vacations_days_subtitle': 'Vacaciones y días de ausencia',
    'pickup_and_destinations': 'Lugares de recogida y destino',
    'you_need_to_complete_some_required_information':
        'Necesitas completar alguna información requerida',
    'forgot_password_message':
        'Enviaremos un enlace de restablecimiento de contraseña a tu correo electrónico.',
    'change_password_message':
        'Puede encontrar su token en su correo electrónico y cambiar su contraseña y confirmación.',
    'select_your_language': 'Selecciona tu idioma',
    'language': 'Idioma',
    'notifications': 'Notificaciones',
    'app_preferences': 'Preferencias',
    'set_your_custom_configuration': 'Establece tu configuración personalizada',
    'get_permissions': 'Permisos',
    'get_permission': 'Obtener permisos',
    'some_permissions_are_required_to_use_the_app':
        'Se requieren algunos permisos para utilizar la aplicación.',
    'start_now': 'Comenzar',
    'start_with_your_account': 'Comience con su cuenta',
    'dark_mode': 'Modo oscuro',
    'show_template_in_darkmode': 'Usar el modo oscuro',
    'next': 'Continuar',
    'sign_in': 'Ingresar',
    'welcome_back': 'Bienvenido',
    'email': 'Correo electrónico',
    'password': 'Contraseña',
    'confirm': 'Confirmar',
    'recovery_password_mail_sended':
        '¡Correo de recuperación de contraseña enviado!',
    'we_can_help': 'Necesitas ayuda?',
    'message':'Mensaje',
    'subject': 'Asunto',
    'your_old_sent_messages_list': 'Mensajes enviados',
    'click_here_to_view_your_previous_sent_messages':'Haga clic aquí para ver sus mensajes enviados anteriormente',
    'send_now':'Enviar',
    'locations': 'Paradas',
    'have_a_problem': 'Tiene un problema?',
    'send_message_if_you_need_any_help': 'Envía un mensaje si necesitas ayuda',
    'send_message': 'Enviar mensaje',
    'welcome': 'Bienvenido',
    'Route': 'Rutas',
    'priority': 'Prioridad',
    'first_name': 'Nombre',
    'last_name': 'Apellido',
    'contact_number': 'Teléfono',
    'logout': 'Salir',
    'change_password': 'Cambiar contraseña',
    'high': 'Alta',
    'low': 'baja',
    'support': 'Soporte',
    'problems_on_the_road': 'Problemas en la vía',
    'crashed_bus': 'Autobus accidentado',
    'other': 'Otro',
    'routes': 'Rutas',
    'driver_is_running_a_trips': 'El conductor está ejecutando un viaje',
    'your_active_trip': 'Ruta activa',
    'start_trip': 'Comenzar',
    'sueccessfully_ended': 'Finalizado',
    'trip_number': 'Viaje número',
    'trip_duration': 'Tiempo',
    'distance': 'Distancia',
    'pickup_locations': 'Paradas',
    'pickups': 'Paradas',
    'trip': 'Viaje',
    'trips': 'Viajes',
    'end_trip': 'Finalizar',
    'trip_status': '',
    'does_not_have_active_trips': 'No hay viajes activos.',
    'attendance': 'Asistencia',
    'search': 'Buscar',
    'will_not_board': 'No abordará',
    'not_boarding': 'No abordó',
    'boarding': 'Abordó'
  };
}
