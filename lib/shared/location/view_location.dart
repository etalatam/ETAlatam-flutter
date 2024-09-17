import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './provider/location_notifier.dart';

class LocatorView extends ConsumerStatefulWidget {
  const LocatorView({super.key});

  @override
  ConsumerState<LocatorView> createState() => _LocatorViewState();
}

class _LocatorViewState extends ConsumerState<LocatorView> {
  @override
  void initState() {
    ref.read(locationNotifierProvider.notifier).init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Rastreo de ubicación')),
      body: Center(
        child: locationState.isTracking
            ? locationState.location != null
                ? Text('Ubicación actual: ${locationState.location!.latitude}, ${locationState.location!.longitude}')
                : Text('Iniciando rastreo...')
            : Text('Rastreo detenido'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (locationState.isTracking) {
            locationNotifier.stopTracking();
          } else {
            locationNotifier.startTracking();
          }
        },
        child: Icon(locationState.isTracking ? Icons.stop : Icons.play_arrow),
      ),
    );

  }
}
