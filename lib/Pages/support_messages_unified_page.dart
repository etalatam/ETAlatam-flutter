import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Pages/help_message_page.dart';
import 'package:eta_school_app/Pages/create_support_message_page.dart';
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

  // Lista de mensajes
  List<HelpMessageModel>? messagesList = [];
  String? filterStatus;

  // Controladores
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
    super.dispose();
  }

  Future<void> loadInitialData() async {
    setState(() {
      showLoader = true;
    });

    await loadMessages();

    setState(() {
      showLoader = false;
      // Mostrar FAB después de cargar
      _fabAnimationController.forward();
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

  Future<void> _refreshData() async {
    await loadInitialData();
  }

  void _navigateToCreateMessage() async {
    // Navegar a la página de crear mensaje
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateSupportMessagePage(),
      ),
    );
    // Recargar mensajes al volver
    await loadMessages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (showLoader) {
      return Loader();
    }

    // Si no hay mensajes, mostrar estado vacío con botón para crear
    if (messagesList!.isEmpty) {
      return _buildEmptyState();
    }

    // Mostrar lista de mensajes
    return _buildMessagesListView();
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 100,
                    color: activeTheme.main_color.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.translate('no_messages'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: activeTheme.main_color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.translate('send_your_message_below'),
                    style: TextStyle(
                      fontSize: 16,
                      color: activeTheme.main_color.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateMessage,
                    icon: Icon(Icons.add_comment_rounded, color: activeTheme.buttonColor),
                    label: Text(
                      lang.translate('new_message'),
                      style: TextStyle(
                        color: activeTheme.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activeTheme.buttonBG,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: Header()),
        ],
      ),
    );
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
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          count: messagesList!.length,
                          selected: filterStatus == null,
                          onSelected: () => setState(() => filterStatus = null),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('New'),
                          count: messagesList!.where((m) => m.status == 'new').length,
                          selected: filterStatus == 'new',
                          onSelected: () => setState(() => filterStatus = 'new'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('In Progress'),
                          count: messagesList!.where((m) => m.status == 'in_progress').length,
                          selected: filterStatus == 'in_progress',
                          onSelected: () => setState(() => filterStatus = 'in_progress'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('Completed'),
                          count: messagesList!.where((m) => m.status == 'completed').length,
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
          onPressed: _navigateToCreateMessage,
          backgroundColor: activeTheme.buttonBG,
          elevation: 4,
          icon: Icon(Icons.add_comment_rounded, color: activeTheme.buttonColor),
          label: Text(
            lang.translate('new_message'),
            style: TextStyle(
              color: activeTheme.buttonColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final displayLabel = count > 0 ? '$label ($count)' : label;

    return FilterChip(
      label: Text(displayLabel),
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