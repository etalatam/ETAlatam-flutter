import 'dart:async';
import 'package:eta_school_app/Models/route_model.dart';
import 'package:eta_school_app/Pages/student_page.dart';
// import 'package:eta_school_app/Pages/AddStudentPage.dart';
import 'package:eta_school_app/Pages/trip_page.dart';
import 'package:eta_school_app/components/active_trip.dart';
import 'package:eta_school_app/components/home_route_block.dart';
import 'package:eta_school_app/components/widgets.dart';
// import 'package:eta_school_app/Pages/TripPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/ParentModel.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/controllers/Helpers.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/Header.dart';
// import 'package:eta_school_app/components/AddStudentBlock.dart';
// import 'package:eta_school_app/components/HomeRouteBlock.dart';
// import 'package:eta_school_app/components/ActiveTrip.dart';
import 'package:eta_school_app/Models/EventModel.dart';




class GuardiansHome extends StatefulWidget {

  @override
  State<GuardiansHome> createState() => _GuardiansHomeState();
}

class _GuardiansHomeState extends State<GuardiansHome> with ETAWidgets, MediansTheme, WidgetsBindingObserver
{

  final widgets =  ETAWidgets;

  late GoogleMapController mapController;

  bool hasActiveTrip = false;

  ParentModel? parentModel =
      ParentModel(parentId: 0, firstName: '', contactNumber: "", students: []);

  Location location = Location();

  bool showLoader = true;

  List<EventModel> eventsList = [];
  List<RouteModel> routesList = [];
  List<TripModel> oldTripsList = [];
  
  TripModel? activeTrip;

  @override
  Widget build(BuildContext context) {
    
    activeTheme = storage.getItem('darkmode') == true ? DarkTheme() : LightTheme();
    return showLoader 
        ? Loader() 
        : Material(
          type: MaterialType.transparency,
          child: Scaffold(
            body: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              onRefresh: _refreshData, // Function to be called on pull-to-refresh
              child: 
              Stack(
                children: [
                  Container(
                    color: activeTheme.main_bg,
                    height: MediaQuery.of(context).size.height,
                    child:
                 SingleChildScrollView(
                  padding: EdgeInsets.only(bottom:100),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Stack(children: <Widget>[
                    Container(
                  color: activeTheme.main_bg,
                  margin: EdgeInsets.only(top: 120),
                  child: Column(children: [
                    

                    // Row(children:[ Container(
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    //   child: Text(
                    //   "${lang.translate('welcome')}  ${parentModel!.first_name!}",
                    //   style: activeTheme.h4,
                    //   textAlign: TextAlign.start,
                    // ))]),
                    
                    /// Parent profile
                    parentProfileInfoBlock(parentModel!, context),
                    
                    /// Last Trips
                    hasActiveTrip ? ActiveTrip(openTrip, activeTrip) : Center() ,

                    ETAWidgets.svgTitle("assets/svg/fire.svg", lang.translate("List of your added children")),

                    SizedBox( height: 10),

                    /// Students list
                    parentModel!.students.isEmpty ? Center() :  SizedBox(
                      height: 280,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: parentModel!.students.length, // Replace with the total number of items
                        itemBuilder: (BuildContext context, int index) {

                          /// Student block
                          return GestureDetector(
                            onTap: () {
                              openNewPage(context, StudentPage(student: parentModel!.students[index]));
                            },
                            child: ETAWidgets.homeStudentBlock(context, parentModel!.students[index])
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 40,),
                    ETAWidgets.svgTitle("assets/svg/route.svg", lang.translate('Available routes')),
  
                    /// Available Routes
                    Container(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: routesList.length, // Replace with the total number of items
                        itemBuilder: (BuildContext context, int index) {

                          return Container(
                            width: 400,
                            height: 400,
                            child: HomeRouteBlock(route: routesList[index]),
                          );
                        }
                      ) 
                    ),

                    /// Add student block
                    // !hasPending() 
                    // ? InfoButtonBlock(
                    //   addStudent, 
                    //   lang.translate('Add new student now'), 
                    //   lang.translate('Start now with filling new student information'), 
                    //   lang.translate('Add student') ,
                    //   SvgPicture.asset("assets/svg/multi.svg",
                    //     width: 30,
                    //     height: 30,
                    //     color: activeTheme.icon_color,
                    //   ))
                    // : InfoButtonBlock(
                    //   addStudent, 
                    //   lang.translate('Required information'), 
                    //   lang.translate('You need to complete some required information'), 
                    //   lang.translate('Complete information') ,
                    //   SvgPicture.asset("assets/svg/multi.svg",
                    //     width: 30,
                    //     height: 30,
                    //     color: activeTheme.icon_color,
                    //   )
                    // ) ,

                    SizedBox(height: 30,),
                    ETAWidgets.svgTitle("assets/svg/bus.svg", lang.translate('trips_history')),
                    
                    /// Last Trips
                    oldTripsList.length < 1 ? Center () : Container(
                      height: 330,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: oldTripsList.length, // Replace with the total number of items
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              openNewPage(context, TripPage(trip: oldTripsList[index]));
                            },
                            child: 
                            ETAWidgets.homeTripBlock(context, oldTripsList[index])
                          );
                        }
                      ) 
                    ),
                    SizedBox(height: 30,),
                    
                    
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text(
                      "${lang.translate('Events and News')}",
                      style: activeTheme.h3,
                      textAlign: TextAlign.start,
                    )),
                    
                    /// Events carousel
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child:  ETAWidgets.eventCarousel(eventsList, context),
                    ),

                    
                    /// Help / Support Block
                    ETAWidgets.homeHelpBlock(),
                    
                  ]),
                ),

              ]),
            )),

            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Header(lang.translate('sitename'))
            ),
            // Positioned(
            //   bottom: 20,
            //   left: 20,
            //   right: 20,
            //   child: BottomMenu('home', openNewPage)
            // )
          ],
        )
    )));

  }

  // Function to simulate data retrieval or refresh
  Future<void> _refreshData() async {
    setState(() {
      showLoader = true;
    });

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      loadParent();
    });
  }

  loadParent() async {

    Timer(Duration(seconds: 2), ()  async {
      await storage.getItem('darkmode');
      setState(()  {
        darkMode = storage.getItem('darkmode') == true ? true : false;
        showLoader = false;
      });
    });

    // final parentId = await storage.getItem('parent_id');
    // final eventsQuery = await httpService.getEvents();
    // setState(()  {
    //     eventsList = eventsQuery;
    // });

    final parentQuery = await httpService.getParent();
    setState(()  {
        parentModel = parentQuery; 
    });

    final routesQuery = await httpService.getRoutes();
    setState(()  {
        routesList = routesQuery;
    });
    
    TripModel? activeTrip_ = await httpService.getActiveTrip();
    setState(()  {
        activeTrip = activeTrip_;
        hasActiveTrip = activeTrip_.trip_id! > 0 ? true : false;
    });

    List<TripModel>? oldTrips = await httpService.getStudentTrips(parentModel!.students[0].student_id, 0);
    setState(()  {
        oldTripsList = oldTrips;
    });
  }

  // addStudent()
  // {
  //   Get.to(AddStudentPage(parent: parentModel));
  // }

  openTrip(trip)
  {
    Get.to(TripPage(trip: trip,));
  }

  
  @override
  void initState() {
    super.initState();
    loadParent();
  }
}

