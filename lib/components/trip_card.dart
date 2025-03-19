import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/trips_students_model.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class TripCard extends StatelessWidget {
  final TripStudentModel trip;
  final bool isSelected;
  final Function onSelect;
  final String startTime;
  final String endTime;

  const TripCard({
    Key? key,
    required this.trip,
    required this.isSelected,
    required this.onSelect,
    required this.startTime,
    required this.endTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? DefaultTheme.default_color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => onSelect(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildBusInfo(),
              const SizedBox(height: 4),
              _buildDriverInfo(),
              if (isSelected) _buildSelectionIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            trip.routeName ?? 'Sin nombre',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isSelected ? DefaultTheme.default_color : null,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildTimeContainer(),
      ],
    );
  }

  Widget _buildTimeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? DefaultTheme.default_color : Colors.grey[200],
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
          color: isSelected ? Colors.white : Colors.black87,
        ),
        const SizedBox(width: 4),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
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
            '${trip.busName ?? 'Sin bus'} (${trip.busPlate ?? 'Sin placa'})',
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
            trip.driverFullname ?? 'Sin conductor',
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

  Widget _buildSelectionIndicator() {
    return Align(
      alignment: Alignment.centerRight,
      child: Icon(
        Icons.check_circle,
        color: DefaultTheme.default_color,
        size: 20,
      ),
    );
  }
}
