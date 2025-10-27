import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {
    testWidgets('Test login with valid credentials', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Look for login screen elements
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      final loginButton = find.text('sign in');

      // Verify we're on login screen
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      // Enter credentials
      await tester.enterText(emailField, 'etalatam+representante1@gmail.com');
      await tester.enterText(passwordField, 'casa1234');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(loginButton);
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Check if we navigated away from login
      // If login is successful, we should not see the login button anymore
      expect(find.text('sign in'), findsNothing);
    });
  });
}