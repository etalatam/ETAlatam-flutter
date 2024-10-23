import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
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

  String _filter = "";
  
  int _page = 1;

  List<StudentModel> list = [];

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
        title: Text('Attendance'),
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
                labelText: "Search",
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
                          // leading: Image.network(item.),
                          title: Text(item.first_name!),
                          trailing: Checkbox(
                            value: item.first_name?.isEmpty,
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
