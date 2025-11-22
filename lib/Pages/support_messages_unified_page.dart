import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Pages/help_message_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/empty_data.dart';
import 'package:eta_school_app/components/help_message_block.dart';
import 'package:get/get.dart';

class SupportMessagesUnifiedPage extends StatefulWidget {
  const SupportMessagesUnifiedPage({super.key});

  @override
  _SupportMessagesUnifiedPageState createState() => _SupportMessagesUnifiedPageState();
}

class _SupportMessagesUnifiedPageState extends State<SupportMessagesUnifiedPage>
    with SingleTickerProviderStateMixin {
  final HttpService httpService = HttpService();

  // Estados de la página
  bool showLoader = true;
  bool isCreatingMessage = false;

  // Lista de mensajes
  List<HelpMessageModel>? messagesList = [];
  String? filterStatus;

  // Formulario
  String message = '';
  List<SupportHelpCategory>? categories;
  int categoryId = 0;
  List<String> priorities = <String>['Normal', 'High', 'Low'];
  String priority = 'Normal';

  // Controladores
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    loadInitialData();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> loadInitialData() async {
    setState(() {
      showLoader = true;
    });

    await Future.wait([
      loadMessages(),
      loadCategories(),
    ]);

    setState(() {
      showLoader = false;
      // Mostrar FAB después de cargar
      if (messagesList!.isNotEmpty) {
        _fabAnimationController.forward();
      }
    });
  }

  Future<void> loadMessages() async {
    try {
      final messages = await httpService.getHelpMessages();
      setState(() {
        messagesList = messages;
      });
    } catch (e) {
      print('[SupportMessages.loadMessages.error] $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      final result = await httpService.supportHelpCategory();
      setState(() {
        categories = result;
        if (result.isNotEmpty) {
          categoryId = result[0].id!;
        }
      });
    } catch (e) {
      print('[SupportMessages.loadCategories.error] $e');
    }
  }

  Future<void> _refreshData() async {
    await loadInitialData();
  }

  void _toggleCreateMessage() {
    setState(() {
      isCreatingMessage = !isCreatingMessage;
      if (!isCreatingMessage) {
        _messageController.clear();
        message = '';
        priority = 'Normal';
        if (categories != null && categories!.isNotEmpty) {
          categoryId = categories![0].id!;
        }
      }
    });
  }

  Future<void> sendMessage() async {
    if (message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('Please enter a message')),
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

      // Navegar a la página del mensaje
      Get.to(() => HelpMessagePage(message: newHelpMessageModel));

      // Recargar mensajes
      await loadMessages();

      setState(() {
        showLoader = false;
        isCreatingMessage = false;
        _messageController.clear();
        message = '';
        // Mostrar FAB si ahora hay mensajes
        if (messagesList!.isNotEmpty) {
          _fabAnimationController.forward();
        }
      });
    } catch (e) {
      print('[SupportMessages.sendMessage.error] $e');
      setState(() {
        showLoader = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('Error sending message')),
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

    // Si no hay mensajes y no está creando, mostrar el formulario
    if (messagesList!.isEmpty && !isCreatingMessage) {
      return _buildFormView();
    }

    // Si está creando mensaje, mostrar el formulario
    if (isCreatingMessage) {
      return _buildFormView();
    }

    // Mostrar lista de mensajes
    return _buildMessagesListView();
  }

  Widget _buildFormView() {
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
                  // Botón de volver si hay mensajes
                  if (messagesList!.isNotEmpty) ...[
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: activeTheme.main_color),
                      onPressed: _toggleCreateMessage,
                    ),
                    const SizedBox(height: 20),
                  ],

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

                  // Formulario con diseño mejorado
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

    switch (priority) {
      case 'High':
        icon = Icons.priority_high_rounded;
        color = Colors.red;
        break;
      case 'Low':
        icon = Icons.low_priority_rounded;
        color = Colors.blue;
        break;
      default:
        icon = Icons.remove_rounded;
        color = Colors.orange;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildMessagesListView() {
    final filteredMessages = filterStatus == null
      ? messagesList
      : messagesList!.where((m) => m.status == filterStatus).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // App Bar con filtros
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      lang.translate('Support Messages'),
                      style: TextStyle(
                        color: activeTheme.main_color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      padding: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          // Estadísticas
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard(
                                  icon: Icons.message_outlined,
                                  value: messagesList!.length.toString(),
                                  label: lang.translate('Total'),
                                ),
                                _buildStatCard(
                                  icon: Icons.pending_outlined,
                                  value: messagesList!.where((m) => m.status == 'new').length.toString(),
                                  label: lang.translate('Pending'),
                                ),
                                _buildStatCard(
                                  icon: Icons.check_circle_outline,
                                  value: messagesList!.where((m) => m.status == 'completed').length.toString(),
                                  label: lang.translate('Completed'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Filtros
                SliverToBoxAdapter(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                          label: lang.translate('All'),
                          selected: filterStatus == null,
                          onSelected: () => setState(() => filterStatus = null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('New'),
                          selected: filterStatus == 'new',
                          onSelected: () => setState(() => filterStatus = 'new'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('In Progress'),
                          selected: filterStatus == 'in_progress',
                          onSelected: () => setState(() => filterStatus = 'in_progress'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('Completed'),
                          selected: filterStatus == 'completed',
                          onSelected: () => setState(() => filterStatus = 'completed'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de mensajes
                if (filteredMessages!.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: EmptyData(
                        title: lang.translate('No messages'),
                        text: lang.translate('No messages with this status'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildImprovedMessageCard(filteredMessages[index]);
                        },
                        childCount: filteredMessages.length,
                      ),
                    ),
                  ),
              ],
            ),

            // Header
            Positioned(top: 0, left: 0, right: 0, child: Header()),
          ],
        ),
      ),
      // Floating Action Button profesional
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _toggleCreateMessage,
          backgroundColor: activeTheme.buttonBG,
          elevation: 4,
          icon: Icon(Icons.add_comment_rounded, color: activeTheme.buttonColor),
          label: Text(
            lang.translate('New Message'),
            style: TextStyle(
              color: activeTheme.buttonColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: activeTheme.main_color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: activeTheme.main_color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: activeTheme.main_color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: activeTheme.buttonBG.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? activeTheme.buttonBG : activeTheme.main_color,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? activeTheme.buttonBG : activeTheme.main_color.withOpacity(0.3),
        width: selected ? 2 : 1,
      ),
    );
  }

  Widget _buildImprovedMessageCard(HelpMessageModel message) {
    final statusColor = message.status == 'new'
      ? Colors.orange
      : message.status == 'completed'
        ? Colors.green
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Get.to(() => HelpMessagePage(message: message));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del mensaje
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.title ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: activeTheme.main_color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${message.message_id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: activeTheme.main_color.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          lang.translate(message.status ?? 'new'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.short_date ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: activeTheme.main_color.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Mensaje
              Text(
                message.message ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: activeTheme.main_color.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 16,
                        color: activeTheme.main_color.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${message.comments?.length ?? 0} ${lang.translate("comments")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: activeTheme.main_color.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: activeTheme.main_color.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}