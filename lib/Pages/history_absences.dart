import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Models/absence_model.dart';
import 'package:eta_school_app/components/absence_card.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';

class HistoryAbsences extends StatefulWidget {
  final int studentId;
  const HistoryAbsences({super.key, required this.studentId});

  @override
  State<HistoryAbsences> createState() => _HistoryAbsencesState();
}

class _HistoryAbsencesState extends State<HistoryAbsences> {
  final HttpService _httpService = HttpService();
  List<AbsenceModel> _absences = [];
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isInitialLoad = true; 
  
  @override
  void initState() {
    super.initState();
    _loadAbsences();
  }
  
  Future<void> _loadAbsences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final absences = await _httpService.getStudentAbsences(widget.studentId);
      
      setState(() {
        _absences = absences;
        _isLoading = false;
        _isInitialLoad = false; 
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isInitialLoad = false; 
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('error_loading_absences') + ': ' + e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _deleteAbsence(AbsenceModel absence) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      // Llamada a la API para cancelar la inasistencia
      final result = await _httpService.cancelStudentAbsence(absence);
      
      if (result['success']) {
        setState(() {
          _absences.removeWhere((a) => 
            a.idStudent == absence.idStudent && 
            a.idSchedule == absence.idSchedule && 
            a.absenceDate.toString() == absence.absenceDate.toString()
          );
          _isDeleting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.translate('absence_cancel_successfully'))),
        );
      } else {
        setState(() {
          _isDeleting = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang.translate('error_deleting_absence') + ': ' + e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  bool _isFutureDate(String? dateString) {
    if (dateString == null) return false;
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      return date.isAfter(today);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.translate('absence_history')),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAbsences,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Solo mostrar el indicador de carga si es la carga inicial
              if (_isLoading && _isInitialLoad)
                Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: DefaultTheme.default_color,
                    ),
                  ),
                )
              else if (_absences.isEmpty && !_isLoading)
                Expanded(
                  child: Center(
                    child: Text(
                      lang.translate('no_absences_registered'),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _absences.length,
                    itemBuilder: (context, index) {
                      final absence = _absences[index];
                      final isFuture = _isFutureDate(absence.absenceDate.toString());
                      
                      return AbsenceCard(
                        absence: absence,
                        isFuture: isFuture,
                        onDelete: isFuture ? () => _deleteAbsence(absence) : null,
                      );
                    },
                  ),
                ),
              
              if (_isDeleting)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: DefaultTheme.default_color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}