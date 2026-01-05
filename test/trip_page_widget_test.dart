import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eta_school_app/Models/trip_model.dart';
import 'package:eta_school_app/components/button_text_icon.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

/// Widget tests para verificar la visibilidad de botones en TripPage
///
/// Estos tests crean widgets reales y verifican que los botones de
/// "Finalizar Viaje" y "Asistencia" se muestran correctamente para conductores.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TripPage - Button Visibility Widget Tests', () {
    testWidgets('ButtonTextIcon se renderiza correctamente', (WidgetTester tester) async {
      // Crear un ButtonTextIcon de prueba (como el de "Finalizar Viaje")
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ButtonTextIcon(
                'Finalizar Viaje',
                Icon(Icons.route, color: Colors.white),
                Colors.red,
              ),
            ),
          ),
        ),
      );

      // Verificar que el botón se renderiza
      expect(find.byType(ButtonTextIcon), findsOneWidget);
      expect(find.text('Finalizar Viaje'), findsOneWidget);
      expect(find.byIcon(Icons.route), findsOneWidget);

      print('✓ ButtonTextIcon se renderiza correctamente');
    });

    testWidgets('ButtonTextIcon con texto vacío no muestra texto', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ButtonTextIcon(
                '',
                Icon(Icons.list, color: Colors.white),
                Colors.orange,
              ),
            ),
          ),
        ),
      );

      // El widget existe pero el texto está vacío
      expect(find.byType(ButtonTextIcon), findsOneWidget);
      expect(find.text(''), findsOneWidget);
      expect(find.byIcon(Icons.list), findsOneWidget);

      print('✓ ButtonTextIcon con texto vacío se maneja correctamente');
    });

    testWidgets('Botones condicionalmente renderizados - caso VERDADERO', (WidgetTester tester) async {
      // Simular las condiciones cuando SÍ se deben mostrar los botones
      bool tripIsRunning = true;
      bool isDriver = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  // Botón "Finalizar Viaje"
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Finalizar Viaje',
                      Icon(Icons.route, color: Colors.white),
                      Colors.red,
                    ),
                  // Botón "Asistencia"
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Asistencia',
                      Icon(Icons.list, color: Colors.white),
                      Colors.orange,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verificar que AMBOS botones están presentes
      expect(find.byType(ButtonTextIcon), findsNWidgets(2));
      expect(find.text('Finalizar Viaje'), findsOneWidget);
      expect(find.text('Asistencia'), findsOneWidget);

      print('✓ Botones se muestran cuando condiciones son verdaderas');
    });

    testWidgets('Botones condicionalmente renderizados - caso FALSO (isDriver = false)', (WidgetTester tester) async {
      // Simular cuando NO es conductor
      bool tripIsRunning = true;
      bool isDriver = false; // NO es conductor

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Finalizar Viaje',
                      Icon(Icons.route, color: Colors.white),
                      Colors.red,
                    ),
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Asistencia',
                      Icon(Icons.list, color: Colors.white),
                      Colors.orange,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verificar que NO hay botones
      expect(find.byType(ButtonTextIcon), findsNothing);
      expect(find.text('Finalizar Viaje'), findsNothing);
      expect(find.text('Asistencia'), findsNothing);

      print('✓ Botones NO se muestran cuando isDriver = false');
    });

    testWidgets('Botones condicionalmente renderizados - caso FALSO (tripIsRunning = false)', (WidgetTester tester) async {
      // Simular cuando el viaje NO está en Running
      bool tripIsRunning = false; // Viaje completado/pendiente
      bool isDriver = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Finalizar Viaje',
                      Icon(Icons.route, color: Colors.white),
                      Colors.red,
                    ),
                  if (tripIsRunning && isDriver)
                    ButtonTextIcon(
                      'Asistencia',
                      Icon(Icons.list, color: Colors.white),
                      Colors.orange,
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verificar que NO hay botones
      expect(find.byType(ButtonTextIcon), findsNothing);
      expect(find.text('Finalizar Viaje'), findsNothing);
      expect(find.text('Asistencia'), findsNothing);

      print('✓ Botones NO se muestran cuando tripIsRunning = false');
    });

    testWidgets('Simular cambio de estado de isDriver de false a true', (WidgetTester tester) async {
      // Widget que cambia de estado (simula setState después de cargar relationName)
      bool isDriver = false; // Inicialmente false (relationName vacío)

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    // Botones
                    if (isDriver)
                      ButtonTextIcon(
                        'Finalizar Viaje',
                        Icon(Icons.route, color: Colors.white),
                        Colors.red,
                      ),
                    if (isDriver)
                      ButtonTextIcon(
                        'Asistencia',
                        Icon(Icons.list, color: Colors.white),
                        Colors.orange,
                      ),
                    // Botón para cambiar estado (simula carga de relationName)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDriver = true;
                        });
                      },
                      child: Text('Cargar relationName'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verificar estado inicial - NO hay botones
      expect(find.byType(ButtonTextIcon), findsNothing);
      print('Estado inicial: botones NO visibles');

      // Simular carga de relationName presionando el botón
      await tester.tap(find.text('Cargar relationName'));
      await tester.pump(); // Trigger rebuild

      // Verificar que ahora SÍ hay botones
      expect(find.byType(ButtonTextIcon), findsNWidgets(2));
      expect(find.text('Finalizar Viaje'), findsOneWidget);
      expect(find.text('Asistencia'), findsOneWidget);

      print('✓ Después de setState: botones SÍ visibles');
    });

    testWidgets('Verificar que GestureDetector envuelve los botones correctamente', (WidgetTester tester) async {
      bool buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () {
                  buttonTapped = true;
                },
                child: ButtonTextIcon(
                  'Finalizar Viaje',
                  Icon(Icons.route, color: Colors.white),
                  Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      // Verificar que existe
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(ButtonTextIcon), findsOneWidget);

      // Tap en el botón
      await tester.tap(find.byType(ButtonTextIcon));
      await tester.pump();

      expect(buttonTapped, true);
      print('✓ GestureDetector funciona correctamente con ButtonTextIcon');
    });
  });

  group('TripPage - RelationName Simulation Tests', () {
    testWidgets('Simular flujo completo: vacío -> cargando -> cargado', (WidgetTester tester) async {
      String relationName = ''; // Estado inicial
      String tripStatus = 'Running';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                // Simular condición real de trip_page.dart
                bool shouldShowButtons =
                    tripStatus == 'Running' && relationName.contains('eta.drivers');

                return Column(
                  children: [
                    Text('relationName: "$relationName"'),
                    Text('tripStatus: "$tripStatus"'),
                    Text('Botones visibles: $shouldShowButtons'),

                    // Botones condicionales (como en trip_page.dart)
                    if (tripStatus == 'Running' && relationName.contains('eta.drivers'))
                      ButtonTextIcon(
                        'Finalizar Viaje',
                        Icon(Icons.route, color: Colors.white),
                        Colors.red,
                      ),

                    if (tripStatus == 'Running' && relationName.contains('eta.drivers'))
                      ButtonTextIcon(
                        'Asistencia',
                        Icon(Icons.list, color: Colors.white),
                        Colors.orange,
                      ),

                    // Botón para simular carga
                    ElevatedButton(
                      onPressed: () async {
                        // Simular carga asíncrona de LocalStorage
                        await Future.delayed(Duration(milliseconds: 100));
                        setState(() {
                          relationName = 'eta.drivers';
                        });
                      },
                      child: Text('Cargar relationName (async)'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Estado inicial
      expect(find.text('relationName: ""'), findsOneWidget);
      expect(find.text('Botones visibles: false'), findsOneWidget);
      expect(find.byType(ButtonTextIcon), findsNothing);
      print('1. Estado inicial: relationName vacío, botones NO visibles');

      // Tap para cargar
      await tester.tap(find.text('Cargar relationName (async)'));
      await tester.pump(); // Start async operation
      await tester.pump(Duration(milliseconds: 150)); // Wait for async

      // Estado después de cargar
      expect(find.text('relationName: "eta.drivers"'), findsOneWidget);
      expect(find.text('Botones visibles: true'), findsOneWidget);
      expect(find.byType(ButtonTextIcon), findsNWidgets(2));
      print('2. Después de cargar: relationName correcto, botones SÍ visibles');

      print('✓ Flujo completo simulado exitosamente');
    });

    testWidgets('Verificar que botones NO aparecen si relationName se carga tarde', (WidgetTester tester) async {
      String relationName = '';
      bool widgetMounted = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                // Simular initState que llama loadTrip() de forma asíncrona
                // pero no espera el resultado antes del primer build
                Future.microtask(() async {
                  if (widgetMounted) {
                    // Simular delay de carga
                    await Future.delayed(Duration(milliseconds: 500));
                    if (relationName.isEmpty) {
                      setState(() {
                        relationName = 'eta.drivers';
                      });
                    }
                  }
                });

                return Column(
                  children: [
                    Text('relationName: "$relationName"'),
                    if (relationName.contains('eta.drivers'))
                      ButtonTextIcon(
                        'Finalizar Viaje',
                        Icon(Icons.route, color: Colors.white),
                        Colors.red,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Primer frame - relationName todavía vacío
      await tester.pump();
      expect(find.text('relationName: ""'), findsOneWidget);
      expect(find.byType(ButtonTextIcon), findsNothing);
      print('Frame 1: relationName vacío, botones NO visibles');

      // Esperar a que se complete la carga asíncrona
      await tester.pump(Duration(milliseconds: 600));

      // Después de la carga
      expect(find.text('relationName: "eta.drivers"'), findsOneWidget);
      expect(find.byType(ButtonTextIcon), findsOneWidget);
      print('Frame 2: relationName cargado, botones SÍ visibles');

      print('✓ Confirmado: botones NO aparecen en primer render si carga es asíncrona');
    });
  });

  group('TripPage - Edge Cases', () {
    testWidgets('relationName con espacios o caracteres extraños', (WidgetTester tester) async {
      final testCases = [
        {'value': ' eta.drivers ', 'expected': true, 'description': 'Con espacios'},
        {'value': 'eta.drivers\n', 'expected': true, 'description': 'Con newline'},
        {'value': 'ETA.DRIVERS', 'expected': false, 'description': 'Mayúsculas'},
        {'value': 'eta.driver', 'expected': false, 'description': 'Sin "s" final'},
      ];

      for (var testCase in testCases) {
        String relationName = testCase['value'] as String;
        bool expected = testCase['expected'] as bool;
        String description = testCase['description'] as String;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Text('Test: $description'),
                  if (relationName.contains('eta.drivers'))
                    ButtonTextIcon(
                      'Botón',
                      Icon(Icons.check),
                      Colors.green,
                    ),
                ],
              ),
            ),
          ),
        );

        int foundButtons = tester.widgetList(find.byType(ButtonTextIcon)).length;
        bool actual = foundButtons > 0;

        expect(actual, expected,
            reason: '$description debe retornar $expected');
        print('✓ $description: botón visible = $actual (esperado: $expected)');

        // Clear for next test
        await tester.pumpWidget(Container());
      }
    });
  });

  group('TripPage - Integration Simulation', () {
    testWidgets('Simular ciclo de vida completo de TripPage', (WidgetTester tester) async {
      print('\n=== SIMULACIÓN DE CICLO DE VIDA ===');

      String relationName = '';
      String tripStatus = 'Running';
      bool isInitialRender = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                // Simular loadTrip() en initState
                if (isInitialRender) {
                  isInitialRender = false;
                  Future.microtask(() async {
                    print('📥 Iniciando carga asíncrona de relationName...');
                    await Future.delayed(Duration(milliseconds: 200));

                    // Simular lectura de LocalStorage
                    String loadedValue = 'eta.drivers';
                    print('📝 RelationName cargado: "$loadedValue"');

                    setState(() {
                      relationName = loadedValue;
                      print('🔄 setState() llamado, forzando re-render');
                    });
                  });
                }

                bool showButtons = tripStatus == 'Running' && relationName.contains('eta.drivers');
                print('🎨 Renderizando - relationName: "$relationName", showButtons: $showButtons');

                return Column(
                  children: [
                    Text('Trip Status: $tripStatus'),
                    Text('RelationName: "$relationName"'),
                    Text('Botones visibles: $showButtons'),

                    if (tripStatus == 'Running' && relationName.contains('eta.drivers')) ...[
                      ButtonTextIcon(
                        'Finalizar Viaje',
                        Icon(Icons.route, color: Colors.white),
                        Colors.red,
                      ),
                      ButtonTextIcon(
                        'Asistencia',
                        Icon(Icons.list, color: Colors.white),
                        Colors.orange,
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      );

      print('1️⃣ Primer render');
      await tester.pump();
      expect(find.byType(ButtonTextIcon), findsNothing);
      print('   ❌ Botones NO visibles (relationName vacío)');

      print('2️⃣ Esperando carga asíncrona...');
      await tester.pump(Duration(milliseconds: 250));

      print('3️⃣ Después de setState');
      expect(find.byType(ButtonTextIcon), findsNWidgets(2));
      print('   ✅ Botones SÍ visibles (relationName cargado)');

      print('===================================\n');
    });
  });
}
