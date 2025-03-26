import 'dart:convert';

import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/absence_model.dart';
import 'package:eta_school_app/Models/trips_students_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:eta_school_app/components/trip_card.dart';
import 'package:table_calendar/table_calendar.dart';

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
  
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  
  List<TripStudentModel> _availableTrips = [];
  TripStudentModel? _selectedTrip;
  bool _isChecked = false;
  bool _isLoading = false;
  bool _isLoadingTrips = false;
  
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      setState(() {});
    });
    _rangeStart = DateTime.now();
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
    
    final formattedStartDate = DateFormat('yyyy-MM-dd').format(_rangeStart!);
    String formattedEndDate;
    if (_rangeEnd == null) {
      formattedEndDate = formattedStartDate;
    } else {
      formattedEndDate = DateFormat('yyyy-MM-dd').format(_rangeEnd!);
    }
    
    try {
      final trips = await _httpService.getTripsStudentByDate(
        widget.studentId, 
        formattedStartDate,
        formattedEndDate
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
    final result = await showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (BuildContext context) {
        return _DateRangePickerDialog(
          initialDate: _rangeStart!,
        );
      },
    );
    
    if (result != null) {
      setState(() {
        _rangeStart = result['start'];
        _rangeEnd = result['end'];
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
        final endDate = _rangeEnd ?? _rangeStart!;
        
        // Crear un solo objeto de ausencia con el rango completo de fechas
        final absence = {
          'idStudent': widget.studentId,
          'idSchedule': _selectedTrip!.scheduleId!,
          'notes': _descriptionController.text,
          'isAllTrips': _isChecked,
          'dateStart': _rangeStart!.toIso8601String(),
          'dateEnd': endDate.toIso8601String(),
        };

        final response = await _httpService.registerStudentAbsence(jsonEncode(absence));
        
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(lang.translate('absence_registered_successfully'))),
          );
          
          Navigator.of(context).pop();
        } else {
          String errorMessage = response['message'] ?? 'Error al registrar ausencia';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lang.translate(errorMessage)),
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
                          _rangeEnd == null
                              ? DateFormat('dd/MM/yyyy').format(_rangeStart!)
                              : '${DateFormat('dd/MM/yyyy').format(_rangeStart!)} - ${DateFormat('dd/MM/yyyy').format(_rangeEnd!)}',
                          style: activeTheme.normalText,
                        ),
                        Icon(Icons.calendar_today, color: DefaultTheme.default_color),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if(_availableTrips.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      activeColor: DefaultTheme.default_color,
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  Flexible(
                    child: Text(
                      lang.translate('register_absences_on_all'),
                      style: activeTheme.normalText,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],),
                const SizedBox(height: 8),     
                // Rutas disponibles
                if(!_isChecked)
                  Text(
                    lang.translate('select_trip'),
                    style: activeTheme.h6,
                  ),
                  
                if(!_isChecked)  
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
                else if(!_isChecked)
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
                        final date = trip.scheduledDatetime;
                        
                        return TripCard(
                          trip: trip,
                          isSelected: isSelected,
                          startTime: startTime,
                          endTime: endTime,
                          date: date,
                          onSelect: () {
                            setState(() {
                              _selectedTrip = trip;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  if(!_isChecked)
                  const SizedBox(height: 14),
                
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

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _DateRangePickerDialog({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      setState(() {});
    });
    _focusedDay = widget.initialDate;
    _rangeStart = widget.initialDate;
  }

  bool _isMaxRangeExceeded() {
    if (_rangeStart == null || _rangeEnd == null) return false;
    
    final difference = _rangeEnd!.difference(_rangeStart!).inDays;
    return difference > 90; // Máximo 3 meses
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_rangeStart != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    _rangeEnd == null
                        ? DateFormat('dd/MM/yyyy').format(_rangeStart!)
                        : '${DateFormat('dd/MM/yyyy').format(_rangeStart!)} - ${DateFormat('dd/MM/yyyy').format(_rangeEnd!)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: _rangeSelectionMode,
              locale: 'es_ES',
              onRangeSelected: (start, end, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  _rangeStart = start;
                  _rangeEnd = end;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: DefaultTheme.default_color.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: DefaultTheme.default_color,
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: DefaultTheme.default_color.withOpacity(0.2),
                rangeStartDecoration: BoxDecoration(
                  color: DefaultTheme.default_color,
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: BoxDecoration(
                  color: DefaultTheme.default_color,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
              ),
            ),
            if (_isMaxRangeExceeded())
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '(Máximo 3 meses)',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),  
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: DefaultTheme.default_color,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(lang.translate('cancel_absence')),
                ),
                SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: DefaultTheme.default_color,
                  ),
                  onPressed: _isMaxRangeExceeded()
                      ? null
                      : () {
                          Navigator.of(context).pop({
                            'start': _rangeStart,
                            'end': _rangeEnd,
                          });
                        },
                  child: Text(lang.translate('accept')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}