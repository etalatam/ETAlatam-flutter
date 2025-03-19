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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: DefaultTheme.default_color,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
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
              const SizedBox(height: 12),
              _buildDeleteButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String formattedDate = '';
    try {
      DateTime date = DateTime.parse(absence.absenceDate.toString());
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      formattedDate = absence.absenceDate.toString();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            formattedDate,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: DefaultTheme.default_color,
            ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              absence.notes ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: () {
          if (onDelete != null) {
            onDelete!();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: const Icon(Icons.delete, size: 16),
        label: Text(lang.translate('cancel_absence')),
      ),
    );
  }
}
