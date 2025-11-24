import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Pages/help_message_page.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:get/get.dart';

class CreateSupportMessagePage extends StatefulWidget {
  const CreateSupportMessagePage({super.key});

  @override
  _CreateSupportMessagePageState createState() => _CreateSupportMessagePageState();
}

class _CreateSupportMessagePageState extends State<CreateSupportMessagePage> {
  final HttpService httpService = HttpService();

  // Estado de la página
  bool showLoader = true;

  // Formulario
  String message = '';
  List<SupportHelpCategory>? categories;
  int categoryId = 0;
  List<String> priorities = <String>['normal', 'high', 'low'];
  String priority = 'normal';

  // Controladores
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final result = await httpService.supportHelpCategory();
      setState(() {
        categories = result;
        if (result.isNotEmpty) {
          categoryId = result[0].id!;
        }
        showLoader = false;
      });
    } catch (e) {
      print('[CreateSupportMessage.loadCategories.error] $e');
      setState(() {
        showLoader = false;
      });
    }
  }

  Future<void> sendMessage() async {
    if (message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('please_enter_a_message')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      showLoader = true;
    });

    try {
      final newHelpMessageModel = await httpService.sendMessage(
        categoryId,
        message,
        priorities.indexOf(priority)
      );

      // Navegar a la página del mensaje y eliminar esta página del stack
      Get.off(() => HelpMessagePage(message: newHelpMessageModel));

      // Informar que se creó exitosamente
      Get.snackbar(
        lang.translate('Success'),
        lang.translate('Message sent successfully'),
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('[CreateSupportMessage.sendMessage.error] $e');
      setState(() {
        showLoader = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('error_sending_message')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showLoader) {
      return Loader();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 100, bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título con animación
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.translate("We can help") + " 👋",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: activeTheme.main_color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang.translate('send_your_message_below'),
                          style: TextStyle(
                            fontSize: 16,
                            color: activeTheme.main_color.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Formulario
                  _buildImprovedForm(),
                ],
              ),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: Header()),
        ],
      ),
    );
  }

  Widget _buildImprovedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoría
        _buildFormField(
          label: lang.translate("Subject"),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeTheme.main_color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: categoryId,
                  isExpanded: true,
                  icon: Icon(Icons.expand_more, color: activeTheme.main_color),
                  style: TextStyle(
                    color: activeTheme.main_color,
                    fontSize: 16,
                  ),
                  onChanged: (int? value) {
                    setState(() {
                      categoryId = value!;
                    });
                  },
                  items: categories?.map<DropdownMenuItem<int>>(
                    (SupportHelpCategory item) {
                      return DropdownMenuItem<int>(
                        value: item.id,
                        child: Text(item.name!),
                      );
                    }
                  ).toList() ?? [],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Mensaje
        _buildFormField(
          label: lang.translate("Message"),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeTheme.main_color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _messageController,
              maxLines: 5,
              style: TextStyle(
                color: activeTheme.main_color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: lang.translate('Your message here'),
                hintStyle: TextStyle(
                  color: activeTheme.main_color.withOpacity(0.4),
                ),
              ),
              onChanged: (val) => setState(() {
                message = val;
              }),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Prioridad
        _buildFormField(
          label: lang.translate("Priority"),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activeTheme.main_color.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: priority,
                  isExpanded: true,
                  icon: Icon(Icons.expand_more, color: activeTheme.main_color),
                  style: TextStyle(
                    color: activeTheme.main_color,
                    fontSize: 16,
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      priority = value!;
                    });
                  },
                  items: priorities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          _getPriorityIcon(value),
                          const SizedBox(width: 8),
                          Text(lang.translate(value)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Botón de enviar mejorado
        Container(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: activeTheme.buttonBG,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, color: activeTheme.buttonColor),
                const SizedBox(width: 8),
                Text(
                  lang.translate("Send now"),
                  style: TextStyle(
                    color: activeTheme.buttonColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: activeTheme.main_color,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _getPriorityIcon(String priority) {
    IconData icon;
    Color color;

    switch (priority.toLowerCase()) {
      case 'high':
        icon = Icons.priority_high_rounded;
        color = Colors.red;
        break;
      case 'low':
        icon = Icons.low_priority_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.remove_rounded;
        color = Colors.orange;
    }

    return Icon(icon, size: 20, color: color);
  }
}
