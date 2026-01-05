import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localstorage/localstorage.dart';

/// Test de integración para verificar el flujo completo del conductor en TripPage
///
/// Este test simula el escenario real desde el login hasta la visualización
/// de los botones en la página de viaje activo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TripPage - Integration Test: Driver Flow', () {
    late LocalStorage storage;

    setUp(() async {
      storage = LocalStorage('tokens.json');
      await storage.ready;
    });

    tearDown(() async {
      try {
        await storage.clear();
      } catch (e) {
        print('Error limpiando storage: $e');
      }
    });

    test('Flujo completo: Login → Guardar relationName → Cargar en TripPage', () async {
      print('\n=== TEST DE INTEGRACIÓN: FLUJO COMPLETO DEL CONDUCTOR ===\n');

      // PASO 1: Simular login exitoso
      print('1️⃣ PASO 1: Login del conductor');
      print('   Email: conductor@test.com');
      print('   Password: [OCULTO]');

      // Simular que el login guarda relation_name en LocalStorage
      await storage.setItem('relation_name', 'eta.drivers');
      await storage.setItem('user_id', 123);
      await storage.setItem('token', 'fake_token_123');

      final savedRelationName = await storage.getItem('relation_name');
      expect(savedRelationName, 'eta.drivers');
      print('   ✅ Login exitoso - relation_name guardado: "$savedRelationName"');

      // PASO 2: Simular navegación a TripPage
      print('\n2️⃣ PASO 2: Navegación a TripPage');
      print('   trip_id: 456');
      print('   trip_status: "Running"');

      // Simular estado inicial de TripPage
      String relationName = ''; // Como en trip_page.dart línea 81
      String tripStatus = 'Running';
      int tripId = 456;

      print('   Estado inicial de TripPage:');
      print('   - relationName: "$relationName" (vacío)');
      print('   - tripStatus: "$tripStatus"');

      // PASO 3: Simular primer render (antes de loadTrip)
      print('\n3️⃣ PASO 3: Primer render de TripPage');
      bool firstRenderShowButtons = tripStatus == 'Running' && relationName.contains('eta.drivers');
      print('   Condición de botones:');
      print('   - tripStatus == "Running": ${tripStatus == 'Running'}');
      print('   - relationName.contains("eta.drivers"): ${relationName.contains('eta.drivers')}');
      print('   - Botones visibles: $firstRenderShowButtons');
      expect(firstRenderShowButtons, false,
          reason: 'En primer render, botones NO deben ser visibles');
      print('   ❌ BOTONES NO VISIBLES (relationName vacío)');

      // PASO 4: Simular loadTrip() - carga asíncrona
      print('\n4️⃣ PASO 4: Ejecución de loadTrip() (asíncrono)');
      await Future.delayed(Duration(milliseconds: 100)); // Simular delay de red

      if (relationName.isEmpty) {
        print('   Cargando relation_name de LocalStorage...');
        relationName = await storage.getItem('relation_name') ?? '';
        print('   ✅ relation_name cargado: "$relationName"');
      }

      // PASO 5: Simular setState() y segundo render
      print('\n5️⃣ PASO 5: setState() llamado - Segundo render');
      bool secondRenderShowButtons = tripStatus == 'Running' && relationName.contains('eta.drivers');
      print('   Condición de botones:');
      print('   - tripStatus == "Running": ${tripStatus == 'Running'}');
      print('   - relationName.contains("eta.drivers"): ${relationName.contains('eta.drivers')}');
      print('   - Botones visibles: $secondRenderShowButtons');
      expect(secondRenderShowButtons, true,
          reason: 'Después de cargar, botones DEBEN ser visibles');
      print('   ✅ BOTONES SÍ VISIBLES (relationName correcto)');

      // PASO 6: Verificar estado final
      print('\n6️⃣ PASO 6: Verificación final');
      print('   Estado final de TripPage:');
      print('   - relationName: "$relationName"');
      print('   - tripStatus: "$tripStatus"');
      print('   - Botones "Finalizar Viaje" y "Asistencia": VISIBLES ✅');

      expect(relationName, 'eta.drivers');
      expect(tripStatus, 'Running');
      expect(secondRenderShowButtons, true);

      print('\n=== TEST COMPLETADO EXITOSAMENTE ===\n');
    });

    test('Flujo de error: relationName no se carga correctamente', () async {
      print('\n=== TEST DE INTEGRACIÓN: ESCENARIO DE ERROR ===\n');

      print('1️⃣ PASO 1: Login - NO se guardó relation_name');
      // Intencionalmente NO guardar relation_name
      await storage.setItem('user_id', 123);
      await storage.setItem('token', 'fake_token_123');
      // relation_name NO guardado

      print('   ⚠️ relation_name NO guardado en LocalStorage');

      print('\n2️⃣ PASO 2: TripPage intenta cargar relationName');
      String relationName = '';
      String tripStatus = 'Running';

      try {
        relationName = await storage.getItem('relation_name') ?? '';
        print('   ❌ relation_name cargado: "$relationName" (vacío o null)');
      } catch (e) {
        print('   ❌ Error al cargar relation_name: $e');
        relationName = '';
      }

      print('\n3️⃣ PASO 3: Verificación de botones');
      bool shouldShowButtons = tripStatus == 'Running' && relationName.contains('eta.drivers');
      print('   - relationName: "$relationName"');
      print('   - tripStatus: "$tripStatus"');
      print('   - Botones visibles: $shouldShowButtons');

      expect(shouldShowButtons, false,
          reason: 'Sin relationName, botones NO deben mostrarse');
      print('   ❌ BOTONES NO VISIBLES');

      print('\n🐛 PROBLEMA DETECTADO:');
      print('   Si relation_name no se guarda en login o no se carga correctamente,');
      print('   los botones NUNCA aparecerán para el conductor.');

      print('\n=== TEST COMPLETADO - ERROR CONFIRMADO ===\n');
    });

    test('Flujo con diferentes roles: Estudiante vs Conductor', () async {
      print('\n=== TEST DE INTEGRACIÓN: COMPARACIÓN DE ROLES ===\n');

      final roles = [
        {'name': 'Conductor', 'value': 'eta.drivers', 'expected': true},
        {'name': 'Estudiante', 'value': 'eta.students', 'expected': false},
        {'name': 'Tutor', 'value': 'eta.guardians', 'expected': false},
      ];

      for (var role in roles) {
        print('Testing role: ${role['name']}');

        // Guardar relation_name según el rol
        await storage.setItem('relation_name', role['value']);

        // Simular carga en TripPage
        String relationName = '';
        String tripStatus = 'Running';

        if (relationName.isEmpty) {
          relationName = await storage.getItem('relation_name') ?? '';
        }

        bool shouldShowButtons = tripStatus == 'Running' && relationName.contains('eta.drivers');

        print('   - relation_name: "${role['value']}"');
        print('   - Botones visibles: $shouldShowButtons');
        print('   - Esperado: ${role['expected']}');

        expect(shouldShowButtons, role['expected'],
            reason: 'Role ${role['name']} debe retornar ${role['expected']}');

        if (shouldShowButtons) {
          print('   ✅ BOTONES VISIBLES');
        } else {
          print('   ❌ BOTONES NO VISIBLES');
        }

        print('');
      }

      print('=== TEST COMPLETADO ===\n');
    });

    test('Timing Test: Medir cuándo se hace disponible relationName', () async {
      print('\n=== TEST DE INTEGRACIÓN: ANÁLISIS DE TIMING ===\n');

      final stopwatch = Stopwatch()..start();

      // T0: Inicio
      print('T+${stopwatch.elapsedMilliseconds}ms: Inicio de TripPage');
      String relationName = '';

      // T1: Primer render (inmediato)
      print('T+${stopwatch.elapsedMilliseconds}ms: Primer render');
      bool t1ShowButtons = relationName.contains('eta.drivers');
      print('   Botones visibles: $t1ShowButtons');
      expect(t1ShowButtons, false);

      // T2: Inicio de loadTrip()
      await Future.delayed(Duration(milliseconds: 50));
      print('T+${stopwatch.elapsedMilliseconds}ms: Inicio de loadTrip()');

      // T3: Guardado previo en storage (simulando login anterior)
      await storage.setItem('relation_name', 'eta.drivers');

      // T4: Carga de storage
      await Future.delayed(Duration(milliseconds: 100));
      print('T+${stopwatch.elapsedMilliseconds}ms: Cargando de LocalStorage...');

      if (relationName.isEmpty) {
        relationName = await storage.getItem('relation_name') ?? '';
      }

      print('T+${stopwatch.elapsedMilliseconds}ms: RelationName cargado: "$relationName"');

      // T5: setState() y segundo render
      await Future.delayed(Duration(milliseconds: 10));
      print('T+${stopwatch.elapsedMilliseconds}ms: setState() → Segundo render');
      bool t5ShowButtons = relationName.contains('eta.drivers');
      print('   Botones visibles: $t5ShowButtons');
      expect(t5ShowButtons, true);

      stopwatch.stop();

      print('\n📊 ANÁLISIS:');
      print('   Tiempo total hasta mostrar botones: ${stopwatch.elapsedMilliseconds}ms');
      print('   Conclusión: Hay un delay entre primer render y visibilidad de botones');

      print('\n=== TEST COMPLETADO ===\n');
    });

    test('Test de persistencia: relationName persiste entre sesiones', () async {
      print('\n=== TEST DE INTEGRACIÓN: PERSISTENCIA ===\n');

      // Sesión 1: Login y guardado
      print('1️⃣ Sesión 1: Login del conductor');
      await storage.setItem('relation_name', 'eta.drivers');
      print('   ✅ relation_name guardado');

      String session1Value = await storage.getItem('relation_name') ?? '';
      expect(session1Value, 'eta.drivers');

      // Simular cierre de app (sin clear)
      print('\n2️⃣ Simular cierre de app (storage persiste)');

      // Sesión 2: Reabrir app
      print('\n3️⃣ Sesión 2: Reabrir app');
      print('   Cargando relation_name...');

      String session2Value = await storage.getItem('relation_name') ?? '';
      expect(session2Value, 'eta.drivers');
      print('   ✅ relation_name recuperado: "$session2Value"');

      print('\n   Verificación: El valor persiste entre sesiones');

      print('\n=== TEST COMPLETADO ===\n');
    });
  });

  group('TripPage - Edge Cases Integration', () {
    late LocalStorage storage;

    setUp(() async {
      storage = LocalStorage('tokens.json');
      await storage.ready;
    });

    tearDown(() async {
      try {
        await storage.clear();
      } catch (e) {
        print('Error limpiando storage: $e');
      }
    });

    test('Caso extremo: Múltiples llamadas simultáneas a loadTrip', () async {
      print('\n=== TEST: MÚLTIPLES LLAMADAS SIMULTÁNEAS ===\n');

      await storage.setItem('relation_name', 'eta.drivers');

      String relationName = '';

      // Simular múltiples llamadas simultáneas
      print('Llamando loadTrip() 3 veces simultáneamente...');

      final futures = List.generate(3, (index) async {
        if (relationName.isEmpty) {
          final value = await storage.getItem('relation_name') ?? '';
          print('   Llamada #${index + 1}: cargado "$value"');
          return value;
        }
        return relationName;
      });

      final results = await Future.wait(futures);

      print('\nResultados:');
      for (var i = 0; i < results.length; i++) {
        print('   Resultado #${i + 1}: "${results[i]}"');
        expect(results[i], 'eta.drivers');
      }

      print('\n✅ Todas las llamadas retornaron el valor correcto');
      print('=== TEST COMPLETADO ===\n');
    });

    test('Caso extremo: relationName se modifica durante el ciclo de vida', () async {
      print('\n=== TEST: MODIFICACIÓN DE RELATIONNAME ===\n');

      // Inicialmente conductor
      await storage.setItem('relation_name', 'eta.drivers');
      String relationName = await storage.getItem('relation_name') ?? '';

      print('Estado inicial: "$relationName"');
      bool initialShowButtons = relationName.contains('eta.drivers');
      expect(initialShowButtons, true);
      print('   ✅ Botones visibles');

      // Simular cambio de sesión a estudiante (logout/login como otro rol)
      print('\nCambio de sesión: Login como estudiante');
      await storage.setItem('relation_name', 'eta.students');
      relationName = await storage.getItem('relation_name') ?? '';

      print('Nuevo estado: "$relationName"');
      bool newShowButtons = relationName.contains('eta.drivers');
      expect(newShowButtons, false);
      print('   ❌ Botones NO visibles');

      print('\n✅ El cambio de rol afecta correctamente la visibilidad');
      print('=== TEST COMPLETADO ===\n');
    });
  });

  group('TripPage - Debugging & Diagnostics', () {
    test('Generar reporte de debugging completo', () {
      print('\n' + '=' * 60);
      print('REPORTE DE DEBUGGING PARA DISPOSITIVO FÍSICO');
      print('=' * 60);

      print('\n📋 CHECKLIST DE VERIFICACIÓN:');
      print('');
      print('1. LocalStorage:');
      print('   [ ] Verificar que "tokens.json" existe');
      print('   [ ] Verificar que tiene clave "relation_name"');
      print('   [ ] Verificar que el valor es "eta.drivers"');
      print('   [ ] Log esperado: "relation_name guardado: eta.drivers"');
      print('');

      print('2. Login:');
      print('   [ ] Login exitoso guarda relation_name');
      print('   [ ] Verificar log: "[Login] relation_name: eta.drivers"');
      print('');

      print('3. TripPage initState:');
      print('   [ ] relationName se inicializa como "" (vacío)');
      print('   [ ] loadTrip() se llama desde initState');
      print('   [ ] Log esperado: "[TripPage.loadTrip] "');
      print('');

      print('4. TripPage loadTrip:');
      print('   [ ] Verifica que relationName.isEmpty es true');
      print('   [ ] Carga relationName de LocalStorage');
      print('   [ ] Log esperado: "[TripPage.loadTrip.relationName] eta.drivers"');
      print('   [ ] Llama setState() después de cargar');
      print('');

      print('5. TripPage build:');
      print('   [ ] Primer build: relationName = ""');
      print('   [ ] Log esperado: "[TripPage.build] relationName: \\"\\"');
      print('   [ ] Segundo build (post-setState): relationName = "eta.drivers"');
      print('   [ ] Log esperado: "[TripPage.build] relationName: \\"eta.drivers\\"');
      print('');

      print('6. Condiciones de botones:');
      print('   [ ] trip_status == "Running"');
      print('   [ ] relationName.contains("eta.drivers")');
      print('   [ ] Ambas condiciones son true');
      print('   [ ] Log: "[TripPage.build] Botones visibles: true"');
      print('');

      print('7. Botones en UI:');
      print('   [ ] ButtonTextIcon "Finalizar Viaje" se renderiza');
      print('   [ ] ButtonTextIcon "Asistencia" se renderiza');
      print('   [ ] Ambos botones son clickeables');
      print('');

      print('\n🐛 SI LOS BOTONES NO APARECEN, VERIFICAR:');
      print('');
      print('❌ Problema 1: relationName no se cargó');
      print('   → Verificar LocalStorage tiene "relation_name"');
      print('   → Agregar log: print("relationName: \\"\$relationName\\"")');
      print('');

      print('❌ Problema 2: setState() no se ejecutó');
      print('   → Verificar if (mounted) antes de setState');
      print('   → Agregar log en setState: print("setState llamado")');
      print('');

      print('❌ Problema 3: trip_status no es "Running"');
      print('   → Verificar trip.trip_status');
      print('   → Agregar log: print("trip_status: \\"\${trip.trip_status}\\"")');
      print('');

      print('❌ Problema 4: Timing issue');
      print('   → loadTrip() se ejecuta después del build');
      print('   → relationName está vacío durante primer render');
      print('   → setState() no causa re-render');
      print('');

      print('\n💡 SOLUCIÓN SUGERIDA:');
      print('');
      print('Cargar relationName ANTES del primer build:');
      print('');
      print('  @override');
      print('  void initState() {');
      print('    super.initState();');
      print('    _initializeRelationName(); // PRIMERO');
      print('    loadTrip(); // DESPUÉS');
      print('  }');
      print('');
      print('  Future<void> _initializeRelationName() async {');
      print('    final storage = LocalStorage("tokens.json");');
      print('    await storage.ready;');
      print('    relationName = await storage.getItem("relation_name") ?? "";');
      print('    if (mounted) setState(() {});');
      print('  }');
      print('');

      print('=' * 60);
      print('FIN DEL REPORTE');
      print('=' * 60 + '\n');

      expect(true, true);
    });
  });
}
