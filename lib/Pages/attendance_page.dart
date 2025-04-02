import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eta_school_app/components/image_default.dart';
import 'package:flutter/material.dart';

import '../components/icon_button_with_text.dart';
import '../controllers/helpers.dart';

class AttendancePage extends StatefulWidget {
  final TripModel trip;
  final bool isMonitor;
  AttendancePage({super.key, required this.trip, this.isMonitor = false});

  @override
  State<AttendancePage> createState() => _DriverPageState();
}

class _DriverPageState extends State<AttendancePage> {
  TextEditingController _queryController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  List<StudentModel> list = [];

  int _page = 1;

  bool loading = true;

  int? _editingIndex;
  int? _viewNoteIndex;

  int? _loadingIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    fetchData();
  }

  void _scrollListener() {
    // if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
    //   _page++;
    //   fetchData();
    // }
  }

  fetchData() {
    print('[Attendance.fetchData]');
    try {
      httpService
          .routeStudents(
              tripId: widget.trip.trip_id,
              limit: 20,
              offset: (_page - 1) * 20,
              filter: _queryController.text.trim())
          .then((students) {
        setState(() {
          list = students;
          loading = false;
        });
      });
    } catch (e) {
      print('[Attendance.fetchData] ${e.toString()}');
      loading = false;
    }
  }

  updateAttendance(StudentModel student, String statusCode, int index) async {
    print('[Attendance.updateAttendance] ${student.toJson()}');
    try {
      setState(() {
        _loadingIndex = index;
        list[index].statusCode = statusCode;
      });
      final result =
          await httpService.updateAttendance(widget.trip, student, statusCode);

      print('[Attendance.updateAttendance] $result');

      setState(() {
        _editingIndex = null;
        _loadingIndex = null;
        _viewNoteIndex = null;
        list[index].statusCode = result.statusCode;
      });
    } catch (e) {
      print('[Attendance.updateAttendance] ${e.toString()}');
      setState(() {
        _loadingIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('Attendance')),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: () {
        //       _page = 1;
        //       fetchData();
        //     },
        //   ),
        // ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            if (widget.isMonitor)
              Text(widget.trip.route?.route_name ?? '', style: activeTheme.h5),
            TextField(
              controller: _queryController,
              onSubmitted: (value) {
                _page = 1;
                fetchData();
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: lang.translate('Search'),
                labelStyle: TextStyle(color: Colors.black),
                // focusedBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.black),
        
                // ),
                // enabledBorder: OutlineInputBorder(
                //   borderSide: BorderSide(color: Colors.grey),
                // ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _page = 1;
                    fetchData();
                  },
                ),
              ),
            ),
            Expanded(
              child: loading && _page == 1
                  ? Center(
                      child: CircularProgressIndicator(
                          color: activeTheme.main_color))
                  : RefreshIndicator(
                      onRefresh: () async {
                        _page = 1;
                        fetchData();
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: list.length + (loading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == list.length) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final item = list[index];
                          return GestureDetector(
                              onTap: widget.trip.trip_status != 'Running'
                                  ? null
                                  : () => {
                                        setState(() {
                                          _editingIndex = index;
                                          _viewNoteIndex = null;
                                        })
                                      },
                              child: Card(
                                  color: _editingIndex == index
                                      ? Color.fromARGB(255, 245, 243, 236)
                                      : Colors.white,
                                  margin: EdgeInsets.all(8.0),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Column(children: [
                                        ListTile(
                                            leading: item.avatar == true ? 
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: Image.network(
                                                httpService.getImage(
                                                    item.student_id,'eta.students'),
                                                fit: BoxFit.fill,
                                                height: 50,
                                                width: 50,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return CircularProgressIndicator();
                                                },
                                                errorBuilder: (context, error, stackTrace) => ImageDefault(name: item.first_name!, height: 50, width: 50),
                                              ),
                                            ) : 
                                            ImageDefault(name: item.first_name!, height: 50, width: 50),
                                            title: Text(
                                                '${item.first_name!} ${item.last_name}', style: activeTheme.normalText),
                                            trailing: Row(
                                               mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if(item.statusCode == 'WILL_NOT_BOARD' && item.notes != null &&
                                                  item.notes!.isNotEmpty &&
                                                  _viewNoteIndex != index &&
                                                  _editingIndex != index)
                                                IconButton(
                                                  icon: Icon(Icons.note_alt_rounded, color: Colors.grey),
                                                  onPressed: () {
                                                    setState(() {
                                                      _viewNoteIndex = index;
                                                      _editingIndex = null;
                                                    });
                                                  },
                                                ),
                                                if (_editingIndex != index && _viewNoteIndex != index)
                                                  IconButton(
                                                    icon: Icon(Icons.check_circle,
                                                        color: getStatusColor(
                                                            item.statusCode)),
                                                    onPressed: null,
                                                  ),
                                              ],
                                            )),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if (_editingIndex == index || _viewNoteIndex == index)
                                          Container(
                                            width: 350.0,
                                            height: 1.0,
                                            color: Colors.grey,
                                          ),
                                        if (_editingIndex == index)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16, horizontal: 16.0),
                                            child: _loadingIndex == index
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                    color: activeTheme.main_color,
                                                  ))
                                                : Row(
                                                    children: [
                                                      IconButtonWithText(
                                                        label: Text(lang.translate(
                                                            'Will not board'), style: activeTheme.smallText),
                                                        icon: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.orange),
                                                        onPressed: () =>
                                                            updateAttendance(
                                                                item,
                                                                'WILL_NOT_BOARD',
                                                                index),
                                                      ),
                                                      SizedBox(
                                                        width: 30,
                                                      ),
                                                      IconButtonWithText(
                                                        label: Text(
                                                            lang.translate(
                                                                'Not boarding'), style: activeTheme.smallText),
                                                        icon: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.red),
                                                        onPressed: () =>
                                                            updateAttendance(
                                                                item,
                                                                'NOT_BOARDING',
                                                                index),
                                                      ),
                                                      SizedBox(
                                                        width: 30,
                                                      ),
                                                      IconButtonWithText(
                                                        label: Text(
                                                            lang.translate(
                                                                'Boarding'), style: activeTheme.smallText),
                                                        icon: Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green),
                                                        onPressed: () =>
                                                            updateAttendance(
                                                                item,
                                                                'BOARDING',
                                                                index),
                                                      ),
                                                      Spacer(),
                                                      IconButton(
                                                        icon: Icon(Icons.close),
                                                        onPressed: () {
                                                          setState(() {
                                                            _editingIndex = null;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                          ),
                                          if(_viewNoteIndex==index)
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            alignment: Alignment.center, 
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              mainAxisSize: MainAxisSize.min,                    
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(width: 320, 
                                                child: Text(item.notes!, style: activeTheme.smallText)
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    setState(() {
                                                      _viewNoteIndex = null;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                      ]))));
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color getStatusColor(String? statusCode) {

    Color color = Color.fromARGB(255, 149, 148, 146);

    if (statusCode == 'WILL_NOT_BOARD') {
      color = Colors.orange;
    } else if (statusCode == 'BOARDING') {
      color = Colors.green;
    } else if (statusCode == 'NOT_BOARDING') {
      color = Colors.red;
    }

    return color;
  }
  
}
