import 'dart:async';
import 'dart:convert';

import 'package:eta_school_app/components/header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/comment_block.dart';
import 'package:eta_school_app/components/full_text_button.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';

class HelpMessagePage extends StatefulWidget {
  final HelpMessageModel? message;

  const HelpMessagePage({super.key, this.message});

  @override
  _SentMessageState createState() => _SentMessageState();
}

class _SentMessageState extends State<HelpMessagePage>
    with WidgetsBindingObserver {
  final HttpService httpService = HttpService();
  final EmitterService emitterService = EmitterService.instance;

  List<CommentModel> commentsList = [];
  HelpMessageModel? message;
  int? currentUserId;

  EmitterTopic? _supportCommentsTopic;
  EmitterTopic? _supportStatusTopic;
  bool _refreshing = false;
  bool _sending = false;

  String? reply;
  bool showLoader = true;

  TextEditingController replyController = TextEditingController();

  Widget _infoRow(String title, String value) {
    final TextStyle titleStyle = activeTheme.smallText.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    final TextStyle valueStyle = activeTheme.smallText.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: titleStyle,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Scaffold(
            body: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: activeTheme.main_bg,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    primary: true,
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        color: activeTheme.main_bg,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 120,
                              padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
                              child: const Center(),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: double.infinity,
                                    color: activeTheme.main_bg,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Row(children: [
                                      Container(
                                          child: SvgPicture.asset(
                                              "assets/svg/help.svg",
                                              width: 30,
                                              height: 30,
                                              color: activeTheme.main_color)),
                                      const SizedBox(width: 15),
                                      Text(lang.translate('your_help_messages'),
                                          style: activeTheme.h5.copyWith(fontSize: 18),
                                          textAlign: TextAlign.left),
                                    ])),
                                const SizedBox(height: 20),
                                _infoRow(
                                  lang.translate('Ticket Number'),
                                  "${message?.message_id ?? widget.message!.message_id}",
                                ),
                                _infoRow(
                                  lang.translate('subject'),
                                  "${message?.title ?? widget.message!.title}",
                                ),
                                // CustomRow(lang.translate('Status'),
                                //     "${widget.message!.status}"),
                                _infoRow(
                                  lang.translate('Priority'),
                                  "${message?.priority ?? widget.message!.priority}",
                                ),
                                _infoRow(
                                  lang.translate('Time'),
                                  "${message?.date ?? widget.message!.date}",
                                ),
                                const SizedBox(height: 25),
                                Text("${message?.message ?? widget.message!.message}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: activeTheme.main_color,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.left),
                                const SizedBox(height: 25),
                                const SizedBox(height: 15),
                                Row(children: [
                                  Container(
                                      child: SvgPicture.asset(
                                          "assets/svg/comments.svg",
                                          width: 30,
                                          height: 30,
                                          color: activeTheme.main_color)),
                                  const SizedBox(width: 15),
                                  Text(lang.translate('Support Comments'),
                                      style: activeTheme.h6.copyWith(fontSize: 16),
                                      textAlign: TextAlign.left),
                                ]),
                                const SizedBox(height: 15),
                                for (var i = 0; i < commentsList.length; i++)
                                  CommentBlock(commentsList[i], currentUserId: currentUserId)
                              ],
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.translate("Comment"),
                                    style: activeTheme.h6.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: replyController,
                                    maxLines: 4,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        filled: true,
                                        hintStyle:
                                            TextStyle(color: Colors.grey[800]),
                                        hintText:
                                            lang.translate('Your message here'),
                                        fillColor: const Color.fromRGBO(
                                            233, 235, 235, 1)),
                                    onChanged: (val) => setState(() {
                                      reply = val;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            FullTextButton(
                              sendReply,
                              lang.translate('Send now'),
                              fontSize: 18,
                            ),
                            const SizedBox(height: 100),
                          ],
                        ))),
              ),
              Positioned(left: 0, right: 0, top: 0, child: Header()),
              // Positioned(
              //     top: 0,
              //     left: 0,
              //     right: 0,
              //     child: Header(lang.translate('Help page'))),
              // Positioned(
              //     bottom: 20,
              //     left: 20,
              //     right: 20,
              //     child: BottomMenu('help', openPage))
            ],
          ));
  }

  openPage(context, page) {
    setState(() => openNewPage(context, page));
  }

  Future<void> loadMessage({bool showSpinner = true}) async {
    final int? messageId = widget.message?.message_id;
    if (messageId == null) {
      if (mounted && showSpinner) {
        setState(() {
          showLoader = false;
        });
      }
      return;
    }

    if (_refreshing) {
      return;
    }
    _refreshing = true;

    if (mounted && showSpinner) {
      setState(() {
        showLoader = true;
      });
    }

    try {
      final HelpMessageModel? refreshed =
          await httpService.getHelpMessageById(messageId);

      if (!mounted) {
        return;
      }

      setState(() {
        message = refreshed ?? message ?? widget.message;
        commentsList = message?.comments ?? [];
        showLoader = false;
      });
    } catch (e) {
      if (mounted && showSpinner) {
        setState(() {
          showLoader = false;
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _refreshData() async {
    await loadMessage(showSpinner: true);
  }

  Future<int?> _resolveSchoolIdForEmitter() async {
    try {
      await storage.ready;
      final String? relationNameRaw = await storage.getItem('relation_name');
      final bool isMonitor = await storage.getItem('monitor') == true;
      final String? relationName =
          (isMonitor && relationNameRaw == 'eta.employees') ? 'eta.monitor' : relationNameRaw;

      if (relationName == 'eta.students') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String studentSchoolCacheKey = 'student_school_id_${relId ?? 0}';

        final cachedSchoolId = await storage.getItem(studentSchoolCacheKey);
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            return parsed;
          }
        }
        final student = await httpService.getStudent();
        if (student.schoolId != null) {
          try {
            await storage.setItem(studentSchoolCacheKey, student.schoolId);
          } catch (_) {}
        }
        return student.schoolId;
      }

      if (relationName == 'eta.guardians') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String guardianSchoolCacheKey = 'guardian_school_id_${relId ?? 0}';

        final cachedSchoolId = await storage.getItem(guardianSchoolCacheKey);
        if (cachedSchoolId != null) {
          final int? parsed =
              cachedSchoolId is int ? cachedSchoolId : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
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

        final int? fromStudents =
            parent.students.fold<int?>(null, (prev, s) => prev ?? s.schoolId);
        if (fromStudents != null) {
          try {
            await storage.setItem(guardianSchoolCacheKey, fromStudents);
          } catch (_) {}
          return fromStudents;
        }
      }

      if (relationName == 'eta.drivers') {
        final cachedSchoolId = await storage.getItem('driver_school_id');
        if (cachedSchoolId != null) {
          final int? parsed =
              cachedSchoolId is int ? cachedSchoolId : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            return parsed;
          }
        }

        try {
          final driver = await httpService.getDriver();
          if (driver.schoolId != null) {
            await storage.setItem('driver_school_id', driver.schoolId);
            return driver.schoolId;
          }
        } catch (_) {}

        try {
          final activeTrip = await httpService.getActiveTrip();
          if (activeTrip.trip_id != 0 && activeTrip.school_id != null) {
            await storage.setItem('driver_school_id', activeTrip.school_id);
            return activeTrip.school_id;
          }
        } catch (_) {}
        
        final trips = await httpService.getDriverTrips(0);
        if (trips.isNotEmpty && trips.first.school_id != null) {
          await storage.setItem('driver_school_id', trips.first.school_id);
          return trips.first.school_id;
        }
      }

      if (relationName == 'eta.monitor') {
        final dynamic relIdRaw = await storage.getItem('relation_id');
        final int? relId = relIdRaw is int ? relIdRaw : int.tryParse('$relIdRaw');
        final String monitorSchoolCacheKey = 'monitor_school_id_${relId ?? 0}';

        final cachedSchoolId = await storage.getItem(monitorSchoolCacheKey);
        if (cachedSchoolId != null) {
          final int? parsed = cachedSchoolId is int
              ? cachedSchoolId
              : int.tryParse('$cachedSchoolId');
          if (parsed != null) {
            return parsed;
          }
        }

        final trips = await httpService.getMonitorActiveTrips();
        if (trips.isNotEmpty && trips.first.school_id != null) {
          try {
            await storage.setItem(monitorSchoolCacheKey, trips.first.school_id);
          } catch (_) {}
          return trips.first.school_id;
        }

        final latestTrips = await httpService.getMonitorLatestTrips(limit: 1);
        if (latestTrips.isNotEmpty && latestTrips.first.school_id != null) {
          try {
            await storage.setItem(monitorSchoolCacheKey, latestTrips.first.school_id);
          } catch (_) {}
          return latestTrips.first.school_id;
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> _subscribeToSupportComments() async {
    final int? messageId = widget.message?.message_id;
    if (messageId == null) {
      return;
    }

    emitterService.removeListener(_onEmitterUpdate);
    if (_supportCommentsTopic != null) {
      try {
        emitterService.unsubscribe(_supportCommentsTopic!);
      } catch (_) {}
      _supportCommentsTopic = null;
    }
    if (_supportStatusTopic != null) {
      try {
        emitterService.unsubscribe(_supportStatusTopic!);
      } catch (_) {}
      _supportStatusTopic = null;
    }

    try {
      final int? schoolId =
          message?.schoolId ?? widget.message?.schoolId ?? await _resolveSchoolIdForEmitter();
      if (schoolId == null) {
        return;
      }

      final channel = 'eta/$schoolId/support/message/$messageId/comments';
      final statusChannel = 'eta/$schoolId/support/message/$messageId/status';

      final keyModel = await httpService.emitterKeyGenEncoded('eta/+/support/#/');

      final String? key = keyModel?.key;
      if (key == null || key.isEmpty) {
        print('[HelpMessagePage] No se encontró key para Emitter');
        return;
      }

      print('[HelpMessagePage] Key encontrada para canal patrón: ${keyModel?.channel}');

      if (!emitterService.isConnected()) {
        await emitterService.connect();
      }

      int attempts = 0;
      while (!emitterService.isConnected() && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }

      if (!emitterService.isConnected()) {
        return;
      }

      if (_supportCommentsTopic != null && _supportCommentsTopic!.name == channel) {
        return;
      }

      _supportCommentsTopic = EmitterTopic(channel, key);
      emitterService.subscribe(_supportCommentsTopic!);

      _supportStatusTopic = EmitterTopic(statusChannel, key);
      emitterService.subscribe(_supportStatusTopic!);

      emitterService.addListener(_onEmitterUpdate);
    } catch (_) {}
  }

  void _onEmitterUpdate() {
    final raw = emitterService.lastMessage();
    print('[HelpMessagePage._onEmitterUpdate] raw: $raw');
    if (raw.isEmpty) {
      return;
    }

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return;
      }

      final String? eventType = decoded['event_type']?.toString();
      final int? msgId = int.tryParse('${decoded['message_id']}');
      final int? currentMsgId = widget.message?.message_id;
      print('[HelpMessagePage._onEmitterUpdate] eventType: $eventType, msgId: $msgId, currentMsgId: $currentMsgId');
      if (currentMsgId == null || msgId == null || msgId != currentMsgId) {
        return;
      }

      if (eventType == 'new-comment') {
        final int? commentId = int.tryParse('${decoded['comment_id']}');
        if (commentId != null &&
            commentsList.any((c) => c.id != null && c.id == commentId)) {
          return;
        }

        final mapped = {
          'id': decoded['comment_id'],
          'ts': decoded['ts'],
          'id_usu': decoded['id_usu'],
          'txt': decoded['txt'],
          'message_id': decoded['message_id'],
          'user_email': decoded['user_email'],
          'user_name': decoded['user_name'],
          'user_last_name': decoded['user_last_name'],
        };

        final CommentModel newComment = CommentModel.fromJson(mapped);

        if (!mounted) {
          return;
        }

        setState(() {
          commentsList.add(newComment);
          commentsList.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        });
      } else if (eventType == 'status-changed') {
        loadMessage(showSpinner: false);
      }
    } catch (_) {}
  }

  sendReply() async {
    if (_sending) {
      return;
    }

    final String text = replyController.text.trim();
    if (text.isEmpty) {
      return;
    }
    // Comentado: showLoader = true causa rebuild completo y scroll salta al top
    // setState(() {
    //   showLoader = true;
    // });

    try {
      _sending = true;
      FocusScope.of(context).unfocus();
      final newComment = await httpService.sendMessageComment(
          text, widget.message!.message_id!);

      setState(() {
        // Evitar duplicado si Emitter ya insertó el comentario antes de que respondiera la API
        final int? newId = newComment.id;
        final bool exists = newId != null &&
            commentsList.any((c) => c.id != null && c.id == newId);
        if (!exists) {
          commentsList.add(newComment);
          commentsList.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        }
        reply = '';
        replyController.clear();
      });
    } catch (e) {
      print(e.toString());
    } finally {
      _sending = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadMessage(showSpinner: false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    message = widget.message;
    commentsList = widget.message?.comments ?? [];
    _loadCurrentUserId();
    loadMessage(showSpinner: true).then((_) {
      _subscribeToSupportComments();
    });
  }

  Future<void> _loadCurrentUserId() async {
    final dynamic userId = await storage.getItem('id_usu');
    if (userId != null && mounted) {
      setState(() {
        currentUserId = userId is int ? userId : int.tryParse('$userId');
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    emitterService.removeListener(_onEmitterUpdate);
    if (_supportCommentsTopic != null) {
      try {
        emitterService.unsubscribe(_supportCommentsTopic!);
      } catch (_) {}
    }
    if (_supportStatusTopic != null) {
      try {
        emitterService.unsubscribe(_supportStatusTopic!);
      } catch (_) {}
    }
    replyController.dispose();
    super.dispose();
  }
}
