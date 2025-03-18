import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:fishpond/app.dart';
import 'package:mockito/mockito.dart';

// Create a simple mock for GoRouter
class MockRouter extends Mock implements GoRouter {}

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Create a mock router
    final mockRouter = MockRouter();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(FishpondApp(router: mockRouter));

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}