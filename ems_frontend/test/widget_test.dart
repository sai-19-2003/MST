import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ems_frontend/screens/home.dart';

void main() {
  testWidgets('Check if Home Page loads with Login Button', (WidgetTester tester) async {
    // Build the HomeScreen and trigger a frame.
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Check if "MS TRANSPORTS" title is present
    expect(find.text("MS TRANSPORTS"), findsOneWidget);

    // Check if the Login button is present
    expect(find.widgetWithText(ElevatedButton, "Employee Login"), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, "Admin Login"), findsOneWidget);
  });
}
