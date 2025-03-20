import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/absence_model.dart';
import 'package:eta_school_app/Models/trips_students_model.dart';
import 'package:intl/intl.dart';
import 'package:eta_school_app/components/trip_card.dart';

class RegisterAbsences extends StatefulWidget {
  final int studentId;
  const RegisterAbsences({super.key, required this.studentId});

  @override
  State<RegisterAbsences> createState() => _RegisterAbsencesState();
}

class _RegisterAbsencesState extends State<RegisterAbsences> {
  final HttpService _httpService = HttpService();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  DateTime _selectedDate = DateTime.now();
  
  List<TripStudentModel> _availableTrips = [];
  TripStudentModel? _selectedTrip;
  bool _isLoading = false;
  bool _isLoadingTrips = false;
  
  @override
  void initState() {
    super.initState();
    _loadTripsForDate();
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTripsForDate() async {
    setState(() {
      _isLoadingTrips = true;
      _selectedTrip = null;
    });
    
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    try {
      final trips = await _httpService.getTripsStudentByDate(
        widget.studentId, 
        formattedDate
      );
      
      setState(() {
        _availableTrips = trips;
        _isLoadingTrips = false;
        if (trips.isNotEmpty) {
          _selectedTrip = trips.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingTrips = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar rutas: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate,
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(primary: DefaultTheme.default_color),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
    });
    _loadTripsForDate();
  }
}
  
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedTrip != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final absence = AbsenceModel(
          idStudent: widget.studentId,
          idSchedule: _selectedTrip!.scheduleId!,
          absenceDate: _selectedDate,
          notes: _descriptionController.text,
        );
        
        final response = await _httpService.registerStudentAbsence(absence);
        
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lang.translate('absence_registered_successfully'))),
          );
          
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate(response['message'])),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.translate('error_registering_absence') + ': ' + e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('register_absences')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha
                Text(
                  lang.translate('select_date'),
                  style: activeTheme.h6,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: DefaultTheme.default_color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: activeTheme.normalText,
                        ),
                        Icon(Icons.calendar_today, color: DefaultTheme.default_color),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Rutas disponibles
                Text(
                  lang.translate('select_trip'),
                  style: activeTheme.h6,
                ),
                const SizedBox(height: 8),
                
                if (_isLoadingTrips)
                  Center(child: CircularProgressIndicator(
                    color: DefaultTheme.default_color,
                  ))
                else if (_availableTrips.isEmpty)
                  Center(
                    child: Text(
                      lang.translate('no_trips_available'),
                      style: activeTheme.normalText.copyWith(color: Colors.red),
                    ),
                  )
                else
                  // Lista de tarjetas seleccionables para los viajes
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 300, // Altura máxima para la lista
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _availableTrips.length,
                      itemBuilder: (context, index) {
                        final trip = _availableTrips[index];
                        final isSelected = _selectedTrip?.scheduleId == trip.scheduleId;
                        
                        // Formatear las horas para mostrar en formato 12 horas con AM/PM
                        String formatTimeToAmPm(String? timeString) {
                          if (timeString == null) return '--:-- --';
                          
                          try {
                            // Método más eficiente usando directamente DateFormat
                            return DateFormat('h:mm a').format(
                              DateFormat('HH:mm').parse(timeString)
                            );
                          } catch (e) {
                            return '--:-- --';
                          }
                        }
                        
                        final startTime = formatTimeToAmPm(trip.scheduleStartTime);
                        final endTime = formatTimeToAmPm(trip.scheduleEndTime);
                        
                        return TripCard(
                          trip: trip,
                          isSelected: isSelected,
                          startTime: startTime,
                          endTime: endTime,
                          onSelect: () {
                            setState(() {
                              _selectedTrip = trip;
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Descripción
                Text(
                  lang.translate('note_optional'),
                  style: activeTheme.h6,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: lang.translate('absence_reason'),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: DefaultTheme.default_color, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: DefaultTheme.default_color, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: DefaultTheme.default_color, width: 2.0),
                    ),
                  ),
                  maxLines: 3,
                  style: activeTheme.normalText,
                  maxLength: 500,
                  validator: (value) {
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botón de envío
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DefaultTheme.default_color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(lang.translate('submit')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}