import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:flutter/material.dart';

import '../controllers/Helpers.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});


  @override
  State<AttendancePage> createState() => _DriverPageState();
}

class _DriverPageState extends State<AttendancePage> {

  TextEditingController _queryController = TextEditingController();

  ScrollController _scrollController = ScrollController();

  String _filter = "";
  
  int _page = 1;

  List<StudentModel> list = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _page++;
      fetchData();
    }
  }

  fetchData () {
    try {
      httpService.routeStudents(
        limit: 20, 
        offset: _page * 20, 
        filter: _filter.isNotEmpty ? "$_filter=like.*${_queryController.text}*" : ""
      ).then((students) {
        setState(() {
          list = students;
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _page = 1;
              fetchData();
            },
          ),
        ],
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
          DropdownButton<String>(
            value: _filter,
            items: [
              DropdownMenuItem(value: "", child: Text("No Filter")),
              DropdownMenuItem(value: "firstname", child: Text("Nombre")),
              DropdownMenuItem(value: "school_name", child: Text("Esculea")),
              DropdownMenuItem(value: "pickup_point_name", child: Text("Parada")),
            ],
            onChanged: (value) {
              setState(() {
                _filter = value ?? "";
                _page = 1;
              });
              fetchData();
            },
          ),
          Expanded(
            // child: dataProvider.isLoading && _page == 1
            child: _page == 1
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      _page = 1;
                      // await dataProvider.fetchData();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      // itemCount: dataProvider.items.length + (dataProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        // if (index == dataProvider.items.length) {
                        //   return Center(child: CircularProgressIndicator());
                        // }
                        // final item = dataProvider.items[index];
                        // return ListTile(
                        //   leading: Image.network(item.imageUrl),
                        //   title: Text(item.name),
                        //   trailing: Checkbox(
                        //     value: item.isChecked,
                        //     onChanged: (value) {
                        //       dataProvider.toggleItemChecked(item);
                        //     },
                        //   ),
                        // );
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
