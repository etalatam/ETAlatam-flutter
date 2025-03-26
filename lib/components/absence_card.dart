import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/absence_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:intl/intl.dart';

class AbsenceCard extends StatelessWidget {
  final AbsenceModel absence;
  final bool isFuture;
  final Function? onDelete;

  const AbsenceCard({
    super.key,
    required this.absence,
    required this.isFuture,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: activeTheme.main_bg,
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildRouteInfo(),
              const SizedBox(height: 4),
              _buildBusInfo(),
              const SizedBox(height: 4),
              _buildDriverInfo(),
              if (absence.notes != null && absence.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildNotes(),
              ],
              if (isFuture) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: _buildDeleteButton(context),
                ),
              ],
            ],
          ),
        ),
        // Línea divisoria
        Container(
          color: activeTheme.main_color.withOpacity(.4),
          width: double.infinity,
          height: 1,
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    String formattedDate = '';
    try {
      DateTime date = DateTime.parse(absence.absenceDate.toString());
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDate = absence.absenceDate.toString();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            formattedDate,
            style: activeTheme.h6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildTimeContainer(),
      ],
    );
  }

  Widget _buildTimeContainer() {
    String formatTimeToAmPm(String? timeString) {
      if (timeString == null) return '--:-- --';
      
      try {
        return DateFormat('h:mm a').format(
          DateFormat('HH:mm:ss').parse(timeString)
        );
      } catch (e) {
        return '--:-- --';
      }
    }
    
    final startTime = formatTimeToAmPm(absence.scheduleStartTime);
    final endTime = formatTimeToAmPm(absence.scheduleEndTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: DefaultTheme.default_color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRow(Icons.play_circle_outline, startTime),
          const SizedBox(height: 2),
          _buildTimeRow(Icons.stop_circle_outlined, endTime),
        ],
      ),
    );
  }

  Widget _buildTimeRow(IconData icon, String time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          time,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Row(
      children: [
        Icon(Icons.route, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            absence.routeName ?? 'Sin ruta',
            style: activeTheme.normalText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBusInfo() {
    return Row(
      children: [
        Icon(Icons.directions_bus, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${absence.busName ?? 'Sin bus'} (${absence.busPlate ?? 'Sin placa'})',
            style: activeTheme.normalText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        Icon(Icons.person, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            absence.driverFullname ?? 'Sin conductor',
            style: activeTheme.normalText,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.note, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              absence.notes ?? '',
              style: activeTheme.normalText,
              maxLines: 3,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 100, // Ancho fijo para el botón
      child: ElevatedButton.icon(
        onPressed: () {
          if (onDelete != null) {
            onDelete!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          minimumSize: const Size(0, 24),
          textStyle: const TextStyle(fontSize: 12),
        ),
        icon: const Icon(Icons.delete, size: 12),
        label: Text(lang.translate('cancel_absence')),
      ),
    );
  }
}
