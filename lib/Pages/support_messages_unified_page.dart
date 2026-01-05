import 'dart:convert';

import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/Pages/help_message_page.dart';
import 'package:eta_school_app/Pages/create_support_message_page.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
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
import 'package:intl/intl.dart';

class SupportMessagesUnifiedPage extends StatefulWidget {
  const SupportMessagesUnifiedPage({super.key});

  @override
  _SupportMessagesUnifiedPageState createState() => _SupportMessagesUnifiedPageState();
}

class _SupportMessagesUnifiedPageState extends State<SupportMessagesUnifiedPage>
    with SingleTickerProviderStateMixin {
  final HttpService httpService = HttpService();
  final EmitterService emitterService = EmitterService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  // Estados de la página
  bool showLoader = true;

  // Lista de mensajes
  List<HelpMessageModel>? messagesList = [];
  String? filterStatus;

  // Controladores
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // Emitter
  int? _currentUserId;
  int? _currentRelationId;
  String? _currentRelationName;
  bool _isMonitor = false;
  int? _schoolId;
  EmitterTopic? _messagesTopic;
  EmitterTopic? _commentsTopic;
  EmitterTopic? _statusTopic;

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
    _initPage();
    _notificationService.addListener(_onFCMNotification);
  }

  Future<void> _initPage() async {
    await _loadCurrentUserId();
    await loadInitialData();
    await _subscribeToEmitter();
  }

  @override
  void dispose() {
    _unsubscribeFromEmitter();
    _notificationService.removeListener(_onFCMNotification);
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onFCMNotification() {
    print('[SupportMessages._onFCMNotification] FCM notification received');
    if (messagesList == null || messagesList!.isEmpty) return;
    
    for (final message in messagesList!) {
      final commentCount = message.comments?.length ?? 0;
      if (commentCount == 0) {
        print('[SupportMessages._onFCMNotification] Ticket ${message.message_id} sin comentarios, recargando silenciosamente');
        _reloadMessageSilently(message.message_id);
      }
    }
  }

  Future<void> _reloadMessageSilently(int? messageId) async {
    if (messageId == null) return;
    try {
      final refreshed = await httpService.getHelpMessageById(messageId);
      if (refreshed != null && mounted && messagesList != null) {
        final index = messagesList!.indexWhere((m) => m.message_id == messageId);
        if (index >= 0) {
          setState(() {
            messagesList![index] = refreshed;
          });
          print('[SupportMessages._reloadMessageSilently] Ticket $messageId actualizado silenciosamente');
        }
      }
    } catch (e) {
      print('[SupportMessages._reloadMessageSilently] Error: $e');
    }
  }

  Future<void> _loadCurrentUserId() async {
    await storage.ready;
    final idUsu = await storage.getItem('id_usu');
    if (idUsu != null) {
      _currentUserId = idUsu is int ? idUsu : int.tryParse('$idUsu');
    }

    final relId = await storage.getItem('relation_id');
    if (relId != null) {
      _currentRelationId = relId is int ? relId : int.tryParse('$relId');
    }

    _currentRelationName = await storage.getItem('relation_name');
    _isMonitor = await storage.getItem('monitor') == true;

    print(
        '[SupportMessages._loadCurrentUserId] id_usu: $_currentUserId, relation_id: $_currentRelationId, relation_name: $_currentRelationName, monitor: $_isMonitor');
  }

  Future<int?> _resolveSchoolId() async {
    try {
      await storage.ready;
      final String? relationNameRaw = await storage.getItem('relation_name');
      final bool isMonitor = await storage.getItem('monitor') == true;
      final String? relationName =
          (isMonitor && relationNameRaw == 'eta.employees') ? 'eta.monitor' : relationNameRaw;
      print('[SupportMessages._resolveSchoolId] relationName: $relationName');

      if (relationName == 'eta.students') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String studentSchoolCacheKey =
            'student_school_id_${relId ?? _currentRelationId ?? _currentUserId ?? 0}';

        final cachedSchoolId = await storage.getItem(studentSchoolCacheKey);
        print('[SupportMessages._resolveSchoolId] cached $studentSchoolCacheKey: $cachedSchoolId');
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            print('[SupportMessages._resolveSchoolId] Usando cached $studentSchoolCacheKey: $parsed');
            return parsed;
          }
        }

        final student = await httpService.getStudent();
        print('[SupportMessages._resolveSchoolId] student.schoolId: ${student.schoolId}');
        if (student.schoolId != null) {
          try {
            await storage.setItem(studentSchoolCacheKey, student.schoolId);
          } catch (_) {}
          return student.schoolId;
        }

        final int? fromMessages =
            messagesList?.fold<int?>(null, (prev, m) => prev ?? m.schoolId);
        if (fromMessages != null) {
          try {
            await storage.setItem(studentSchoolCacheKey, fromMessages);
          } catch (_) {}
          return fromMessages;
        }

        return null;
      }

      if (relationName == 'eta.monitor') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String monitorSchoolCacheKey =
            'monitor_school_id_${relId ?? _currentRelationId ?? _currentUserId ?? 0}';

        final cachedSchoolId = await storage.getItem(monitorSchoolCacheKey);
        print('[SupportMessages._resolveSchoolId] cached $monitorSchoolCacheKey: $cachedSchoolId');
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            print('[SupportMessages._resolveSchoolId] Usando cached $monitorSchoolCacheKey: $parsed');
            return parsed;
          }
        }

        try {
          final trips = await httpService.getMonitorActiveTrips();
          if (trips.isNotEmpty && trips.first.school_id != null) {
            await storage.setItem(monitorSchoolCacheKey, trips.first.school_id);
            return trips.first.school_id;
          }

          final latestTrips = await httpService.getMonitorLatestTrips(limit: 1);
          if (latestTrips.isNotEmpty && latestTrips.first.school_id != null) {
            await storage.setItem(monitorSchoolCacheKey, latestTrips.first.school_id);
            return latestTrips.first.school_id;
          }
        } catch (e) {
          print('[SupportMessages._resolveSchoolId] Error getMonitorActiveTrips: $e');
        }

        final int? fromMessages =
            messagesList?.fold<int?>(null, (prev, m) => prev ?? m.schoolId);
        if (fromMessages != null) {
          try {
            await storage.setItem(monitorSchoolCacheKey, fromMessages);
          } catch (_) {}
          return fromMessages;
        }
      }

      if (relationName == 'eta.guardians') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String guardianSchoolCacheKey =
            'guardian_school_id_${relId ?? _currentRelationId ?? _currentUserId ?? 0}';

        final cachedSchoolId = await storage.getItem(guardianSchoolCacheKey);
        print('[SupportMessages._resolveSchoolId] cached $guardianSchoolCacheKey: $cachedSchoolId');
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            print('[SupportMessages._resolveSchoolId] Usando cached $guardianSchoolCacheKey: $parsed');
            return parsed;
          }
        }

        final parent = await httpService.getParent();
        if (parent.schoolId != null) {
          try {
            await storage.setItem(guardianSchoolCacheKey, parent.schoolId);
          } catch (_) {}
          return parent.schoolId;
        }

        final int? fromStudents = parent.students.fold<int?>(
            null, (prev, s) => prev ?? s.schoolId);
        if (fromStudents != null) {
          try {
            await storage.setItem(guardianSchoolCacheKey, fromStudents);
          } catch (_) {}
          return fromStudents;
        }
      }

      if (relationName == 'eta.drivers') {
        final cachedSchoolId = await storage.getItem('driver_school_id');
        print('[SupportMessages._resolveSchoolId] cachedSchoolId: $cachedSchoolId');
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            print('[SupportMessages._resolveSchoolId] Usando cached: $parsed');
            return parsed;
          }
        }

        try {
          final driver = await httpService.getDriver();
          print('[SupportMessages._resolveSchoolId] driver.schoolId: ${driver.schoolId}');
          if (driver.schoolId != null) {
            await storage.setItem('driver_school_id', driver.schoolId);
            return driver.schoolId;
          }
        } catch (e) {
          print('[SupportMessages._resolveSchoolId] Error getDriver: $e');
        }

        try {
          final activeTrip = await httpService.getActiveTrip();
          print('[SupportMessages._resolveSchoolId] activeTrip.school_id: ${activeTrip.school_id}');
          if (activeTrip.trip_id != 0 && activeTrip.school_id != null) {
            await storage.setItem('driver_school_id', activeTrip.school_id);
            return activeTrip.school_id;
          }
        } catch (e) {
          print('[SupportMessages._resolveSchoolId] Error getActiveTrip: $e');
        }

        final trips = await httpService.getDriverTrips(0);
        print('[SupportMessages._resolveSchoolId] trips.length: ${trips.length}');
        if (trips.isNotEmpty && trips.first.school_id != null) {
          await storage.setItem('driver_school_id', trips.first.school_id);
          return trips.first.school_id;
        }
      }
    } catch (e) {
      print('[SupportMessages._resolveSchoolId] Error general: $e');
    }
    return null;
  }

  Future<void> _subscribeToEmitter() async {
    _unsubscribeFromEmitter();
    _schoolId = await _resolveSchoolId();
    if (_schoolId == null) {
      print('[SupportMessages] No se pudo resolver schoolId para Emitter');
      return;
    }

    try {
      final keyModel = await httpService.emitterKeyGenEncoded('eta/+/support/#/');
      final String? key = keyModel?.key;
      if (key == null || key.isEmpty) {
        print('[SupportMessages] No se encontró key para Emitter');
        return;
      }

      if (!emitterService.isConnected()) {
        await emitterService.connect();
      }

      int attempts = 0;
      while (!emitterService.isConnected() && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }

      if (!emitterService.isConnected()) {
        print('[SupportMessages] No se pudo conectar a Emitter');
        return;
      }

      final messagesChannel = 'eta/$_schoolId/support/messages';
      final commentsChannel = 'eta/$_schoolId/support/message/+/comments';
      final statusChannel = 'eta/$_schoolId/support/message/+/status';

      _messagesTopic = EmitterTopic(messagesChannel, key);
      _commentsTopic = EmitterTopic(commentsChannel, key);
      _statusTopic = EmitterTopic(statusChannel, key);

      emitterService.subscribe(_messagesTopic!);
      emitterService.subscribe(_commentsTopic!);
      emitterService.subscribe(_statusTopic!);
      emitterService.addListener(_onEmitterUpdate);

      print('[SupportMessages] Suscrito a canales de soporte');
    } catch (e) {
      print('[SupportMessages] Error suscribiendo a Emitter: $e');
    }
  }

  void _unsubscribeFromEmitter() {
    emitterService.removeListener(_onEmitterUpdate);
    if (_messagesTopic != null) {
      try {
        emitterService.unsubscribe(_messagesTopic!);
      } catch (_) {}
      _messagesTopic = null;
    }
    if (_commentsTopic != null) {
      try {
        emitterService.unsubscribe(_commentsTopic!);
      } catch (_) {}
      _commentsTopic = null;
    }
    if (_statusTopic != null) {
      try {
        emitterService.unsubscribe(_statusTopic!);
      } catch (_) {}
      _statusTopic = null;
    }
  }

  int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse('$v');
  }

  int? _extractTargetUserId(Map<String, dynamic> decoded) {
    return _parseInt(decoded['message_creator_id']) ??
        _parseInt(decoded['messageCreatorId']) ??
        _parseInt(decoded['creator_user_id']) ??
        _parseInt(decoded['user_id']) ??
        _parseInt(decoded['id_usu_dest']) ??
        _parseInt(decoded['id_usu_receiver']);
  }

  void _onEmitterUpdate() {
    try {
      final String raw = emitterService.lastMessage();
      print('[SupportMessages._onEmitterUpdate] raw: $raw');
      if (raw.isEmpty) return;

      final Map<String, dynamic> decoded = jsonDecode(raw);
      final String? eventType = decoded['event_type'];
      final int? messageCreatorId = _extractTargetUserId(decoded);
      final int? messageId = _parseInt(decoded['message_id']);

      print(
          '[SupportMessages._onEmitterUpdate] eventType: $eventType, messageCreatorId: $messageCreatorId, messageId: $messageId, _currentUserId: $_currentUserId');

      if (_currentUserId == null) {
        print('[SupportMessages._onEmitterUpdate] Ignorando: _currentUserId null');
        return;
      }

      if (_isMonitor) {
        if (!mounted) return;
        if (eventType == 'new-message') {
          print('[SupportMessages._onEmitterUpdate] Procesando new-message (monitor)');
          _handleNewMessage(decoded);
        } else if (eventType == 'new-comment') {
          print('[SupportMessages._onEmitterUpdate] Procesando new-comment (monitor)');
          _handleNewComment(decoded);
        } else if (eventType == 'status-changed') {
          print('[SupportMessages._onEmitterUpdate] Procesando status-changed (monitor)');
          _handleStatusChange(decoded);
        }
        return;
      }

      final bool ticketEsDeEsteUsuario =
          messageId != null && messagesList?.any((m) => m.message_id == messageId) == true;

      if (messageCreatorId != null) {
        final bool creatorMatches =
            messageCreatorId == _currentUserId || messageCreatorId == _currentRelationId;
        if (!creatorMatches && !ticketEsDeEsteUsuario) {
          print('[SupportMessages._onEmitterUpdate] Ignorando: messageCreatorId no coincide');
          return;
        }
      } else {
        if (!ticketEsDeEsteUsuario && eventType != 'new-message') {
          print('[SupportMessages._onEmitterUpdate] Ignorando: messageCreatorId null y ticket no está en lista');
          return;
        }
      }

      if (!mounted) return;

      if (eventType == 'new-message') {
        print('[SupportMessages._onEmitterUpdate] Procesando new-message');
        _handleNewMessage(decoded);
      } else if (eventType == 'new-comment') {
        print('[SupportMessages._onEmitterUpdate] Procesando new-comment');
        _handleNewComment(decoded);
      } else if (eventType == 'status-changed') {
        print('[SupportMessages._onEmitterUpdate] Procesando status-changed');
        _handleStatusChange(decoded);
      }
    } catch (e) {
      print('[SupportMessages._onEmitterUpdate] Error: $e');
    }
  }

  void _handleNewMessage(Map<String, dynamic> data) {
    final int? messageId = int.tryParse('${data['message_id']}');
    if (messageId == null) return;

    if (messagesList?.any((m) => m.message_id == messageId) == true) return;

    final newMessage = HelpMessageModel(
      message_id: messageId,
      schoolId: _schoolId,
      title: data['category_name'] ?? '',
      message: data['content'],
      status: data['status'] ?? 'Pending',
      priority: '${data['priority_id'] ?? 0}',
      user_id: _isMonitor
          ? (int.tryParse('${data['message_creator_id'] ?? ''}') ??
              int.tryParse('${data['id_usu'] ?? ''}') ??
              0)
          : (_currentUserId ?? 0),
      short_date: _formatTimestamp(data['ts']),
      date: _formatTimestamp(data['ts']),
      comments: [],
    );

    setState(() {
      messagesList = [newMessage, ...?messagesList];
    });
  }

  void _handleNewComment(Map<String, dynamic> data) {
    final int? messageId = int.tryParse('${data['message_id']}');
    if (messageId == null) return;

    final int index = messagesList?.indexWhere((m) => m.message_id == messageId) ?? -1;
    if (index == -1) return;

    final int? commentId = int.tryParse('${data['comment_id']}');
    final message = messagesList![index];

    if (message.comments?.any((c) => c.id == commentId) == true) return;

    final newComment = CommentModel(
      id: commentId,
      comment: data['txt'],
      user_id: int.tryParse('${data['id_usu']}') ?? 0,
      short_date: _formatTimestamp(data['ts']),
      date: _formatTimestamp(data['ts']),
      user: CommentUserModel(
        name: '${data['user_name'] ?? ''} ${data['user_last_name'] ?? ''}'.trim(),
        email: data['user_email'],
      ),
    );

    setState(() {
      message.comments = [...?message.comments, newComment];
      final updated = messagesList!.removeAt(index);
      messagesList = [updated, ...messagesList!];
    });
  }

  void _handleStatusChange(Map<String, dynamic> data) {
    final int? messageId = int.tryParse('${data['message_id']}');
    final String? newStatus = data['new_status'];
    if (messageId == null || newStatus == null) return;

    final int index = messagesList?.indexWhere((m) => m.message_id == messageId) ?? -1;
    if (index == -1) return;

    setState(() {
      messagesList![index].status = newStatus;
    });
  }

  String _formatTimestamp(String? ts) {
    if (ts == null) return '';
    try {
      DateTime utc;
      if (ts.endsWith('Z')) {
        utc = DateTime.parse(ts);
      } else if (ts.contains('T')) {
        utc = DateTime.parse('${ts}Z');
      } else {
        utc = DateTime.parse(ts.replaceFirst(' ', 'T') + 'Z');
      }
      final local = utc.toLocal();
      return DateFormat('yyyy-MM-dd hh:mm a').format(local);
    } catch (_) {
      return ts;
    }
  }

  Future<void> loadInitialData() async {
    if (!mounted) return;
    setState(() {
      showLoader = true;
    });

    await loadMessages();

    if (!mounted) return;
    setState(() {
      showLoader = false;
      _fabAnimationController.forward();
    });
  }

  Future<void> loadMessages() async {
    try {
      final messages = await httpService.getHelpMessages();
      if (!mounted) return;
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
                          label: lang.translate('pending'),
                          count: messagesList!.where((m) => m.status == 'Pending').length,
                          selected: filterStatus == 'Pending',
                          onSelected: () => setState(() => filterStatus = 'Pending'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('in_review'),
                          count: messagesList!.where((m) => m.status == 'In Review').length,
                          selected: filterStatus == 'In Review',
                          onSelected: () => setState(() => filterStatus = 'In Review'),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: lang.translate('resolved'),
                          count: messagesList!.where((m) => m.status == 'Resolved').length,
                          selected: filterStatus == 'Resolved',
                          onSelected: () => setState(() => filterStatus = 'Resolved'),
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
    Color statusColor;
    String statusLabel;
    switch (message.status) {
      case 'Pending':
        statusColor = Colors.amber;
        statusLabel = lang.translate('pending');
        break;
      case 'In Review':
        statusColor = Colors.blue;
        statusLabel = lang.translate('in_review');
        break;
      case 'Resolved':
      case 'Completed':
        statusColor = Colors.green;
        statusLabel = lang.translate('resolved');
        break;
      default:
        statusColor = Colors.grey;
        statusLabel = message.status ?? '';
    }

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
                          statusLabel,
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