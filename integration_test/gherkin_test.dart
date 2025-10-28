import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';
import 'step_definitions/login_steps.dart';

Future<void> main() {
  final config = FlutterTestConfiguration()
    ..features = [RegExp('integration_test/features/.*\.feature')]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      JsonReporter(path: './report.json'),
      StdoutReporter()
    ]
    ..stepDefinitions = [
      // Given steps
      AppIsRunning(),
      NoActiveSession(),
      OnLoginScreen(),

      // When steps
      EnterEmail(),
      EnterPassword(),
      PressLoginButton(),

      // Then steps
      ShouldSeeHomeScreen(),
      ShouldBeAuthenticatedAs(),
      MyRoleShouldBe(),
      ShouldSeeErrorMessage(),
      MessageShouldContain(),
      ShouldRemainOnLoginScreen(),
      TokenShouldBeSaved(),
      UserIdShouldBe(),
      RelationNameShouldBe(),
      RelationIdShouldBe(),
      ShouldNotReturnToLogin(),
      ShouldStayOnHomeScreen(),
      ShouldNotSeeFlickering(),
    ]
    ..restartAppBetweenScenarios = true
    ..targetAppPath = "integration_test/app_test.dart"
    ..runningAppProtocolEndpointUri = "http://127.0.0.1:46851"
    // Configuración para diferentes tags
    ..tagExpression = '@smoke or @critical' // Ejecutar solo pruebas críticas
    ..exitAfterTestRun = true;

  return GherkinRunner().execute(config);
}