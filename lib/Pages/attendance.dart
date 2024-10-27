import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/TripModel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../components/IconButtonWithText.dart';
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

  int? _editingIndex;

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
              routeID: widget.trip.route_id,
              limit: 20,
              offset: (_page - 1) * 20,
              filter: _queryController.text)
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

  void _setStatus(int status) {
    // setState(() {
    //   if (_editingIndex != null) {
    //     items[_editingIndex!].status = status;
    //   }
    //   _editingIndex = null;
    // });
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
                        return GestureDetector(
                            onTap: () => {
                                  setState(() {
                                    _editingIndex = index;
                                  })
                                },
                            child: Card(
                                color: _editingIndex == index ? Color.fromARGB(255, 245, 243, 236) : Colors.white,
                                margin: EdgeInsets.all(8.0),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Column(children: [
                                      ListTile(
                                          leading: CircleAvatar(
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      'https://ui-avatars.com/api/?background=random&name=${item.first_name!}')),
                                          title: Text('${item.first_name!} ${item.last_name}'),
                                          trailing: Column(
                                            children: [
                                              if (_editingIndex == null)
                                                IconButton(
                                                  icon: Icon(Icons.check_circle,
                                                      color: Colors.orange),
                                                  onPressed: () => {},
                                                ),
                                            ],
                                          )),
                                        SizedBox(height: 10,),
                                        if (_editingIndex == index)
                                        Container(
                                          width: 350.0,
                                          height: 1.0,
                                          color: Colors.grey,
                                        ),
                                        if (_editingIndex == index)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              IconButtonWithText(
                                                label: Text('No abordó'),
                                                icon: Icon(Icons.check_circle,
                                                    color: Colors.red),
                                                onPressed: () => _setStatus(0),
                                              ),
                                              SizedBox(
                                                width: 30,
                                              ),
                                              IconButtonWithText(
                                                label: Text('Permiso'),
                                                icon: Icon(Icons.check_circle,
                                                    color: Colors.orange),
                                                onPressed: () => _setStatus(1),
                                              ),
                                              SizedBox(
                                                width: 30,
                                              ),
                                              IconButtonWithText(
                                                label: Text('Abordó'),
                                                icon: Icon(Icons.check_circle,
                                                    color: Colors.green),
                                                onPressed: () => _setStatus(2),
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
                                    ]))));
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
