import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/Models/student_model.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/controllers/Helpers.dart';
import 'package:eta_school_app/methods.dart';

PickupLocationModel? pickup;
int lastId = 0;

class StudentTripsPage extends StatefulWidget {
  StudentTripsPage({super.key, this.student});

  final StudentModel? student;

  @override
  State<StudentTripsPage> createState() => _StudentTripsPageState();
}

class _StudentTripsPageState extends State<StudentTripsPage> {

  bool showLoader = true;

  List<TripModel>? trips; 

  @override
  Widget build(BuildContext context) {
    
    return Material(
          type: MaterialType.transparency,
          child:  showLoader ? Loader() : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: NetworkImage((widget.student!.picture != null)
                            ? (httpService .croppedImage(widget.student!.picture!, 800, 1200))
                            : httpService.croppedImage("/uploads/images/60x60.png" ,200, 200)),
                        fit: BoxFit.fitHeight,
                      ),
                      
                        shape: RoundedRectangleBorder(),
                    ),
                  ),
                DraggableScrollableSheet(
                  initialChildSize: .7, // The initial size of the sheet (0.2 means 20% of the screen)
                  minChildSize:
                      0.7, // Minimum size of the sheet (10% of the screen)
                  maxChildSize:
                      0.8, // Maximum size of the sheet (80% of the screen)
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return  Container( child:  Stack(children: [
                       Container(
                        width: double.infinity,
                        height: 75,
                        clipBehavior: Clip.antiAlias,
                        decoration:BoxDecoration(
                        gradient:  LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0),
                            Colors.black.withOpacity(.5),
                          ],
                        )),
                       ),
                       Container(
                        margin: EdgeInsets.only(top: 50),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: activeTheme.main_bg,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0.0, -3.0),
                              blurRadius: 5.0,
                            ),
                          ],
                        ),),
                       SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          controller: scrollController,
                          child: Container(
                          child: Stack(
                          children: [
                            Container(
                              child: Row(textDirection: isRTL() ? TextDirection.rtl : TextDirection.ltr, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [ 
                              Container(padding: EdgeInsets.symmetric(horizontal: 20), child: CircleAvatar( radius: 50, foregroundImage: NetworkImage((widget.student!.picture != null)
                              ? (httpService .croppedImage(widget.student!.picture!, 200, 200))
                              : httpService.croppedImage("/uploads/images/60x60.png" ,200,200)))),
                              Column(children: [
                                Container(padding: EdgeInsets.only(top:15), child: Text("${widget.student!.first_name}", style: TextStyle(fontSize: activeTheme.h5.fontSize, fontWeight: activeTheme.h4.fontWeight, color: Colors.white)),),
                                Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: activeTheme.buttonBG, borderRadius: BorderRadius.all(Radius.circular(10))), margin: EdgeInsets.only(top:15), child: Text("${widget.student!.status}", style: TextStyle(color: activeTheme.buttonColor, fontWeight: FontWeight.bold, )),),
                              ],),
                              Expanded(child: Center()),
                              // Expanded(child: Icon(Icons.edit, color: activeTheme.icon_color,)),
                              Padding(padding: EdgeInsets.only(top: 10, right: 20, left: 20), child: Icon(Icons.edit, color: activeTheme.icon_color,),)
                              ],)),
                            
                            Container(margin: EdgeInsets.symmetric(horizontal: 20), height: 1, color: activeTheme.main_color.withOpacity(.2),),

                            Container(
                              margin: EdgeInsets.only(top: 100),
                              padding: EdgeInsets.all(20),
                              child: Column(children: [
                                Text(lang.translate('Trips'), style: activeTheme.h5,),
                                Text(lang.translate('Trips history'), style: activeTheme.normalText,),
                                SizedBox(height: 20,),
                                tripsList()
                                
                                
                              ],),
                            ),

                          ])
                        ),
                      )])
                    );
                  },
                ),


              ]),
            ),
          );
  } 
  
  Widget tripsList()
  {
    return   trips!.length < 1 ? Center () : Container(
          height: MediaQuery.of(context).size.height / 2.2,
          padding: EdgeInsets.only(bottom: 20),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: trips!.length, // Replace with the total number of items
            itemBuilder: (BuildContext context, int index) {
              return ETAWidgets.studentTripBlock(context, trips![index]);
            }
          ) 
        
    );
  }


  ///
  /// Load devices through API
  ///
  loadTrips() async {
    final tripsQuery = await httpService.getStudentTrips(widget.student!.student_id, lastId);
    setState(()  {
      trips = tripsQuery;
      showLoader = false;
    });
  }
  


  @override
  void initState() {
    super.initState();

    loadTrips();
  }

}
