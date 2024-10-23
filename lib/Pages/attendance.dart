import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controllers/Helpers.dart';

class AttendancePage extends StatefulWidget {

  TripModel trip;

  AttendancePage({super.key, required this.trip});

  @override
  State<AttendancePage> createState() => _DriverPageState();
}

class _DriverPageState extends State<AttendancePage> {

  TextEditingController _queryController = TextEditingController();

  ScrollController _scrollController = ScrollController();
  
  List<StudentModel> list = [];

  int _page = 1;

  bool loading = true;

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

  fetchData () {
    print('[Attendance.fetchData]');
    try {
      httpService.routeStudents(
        routeID: widget.trip.route_id,
        limit: 20, 
        offset: (_page - 1) * 20, 
        filter: _queryController.text
      ).then((students) {
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
      body: Column(
        children: [
          TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: lang.translate('Search'),
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
                ? Center(child: CircularProgressIndicator())
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                              'https://ui-avatars.com/api/?background=random&name=${item.first_name!}'
                            )
                          ),
                            
                          title: Text(item.first_name!),
                          trailing: Checkbox(
                            activeColor: Colors.green,
                            checkColor: Colors.white,
                            value: true,
                            onChanged: (value) {
                              print('value');
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
