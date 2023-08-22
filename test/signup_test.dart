import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/main.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';

/*void main() {
  testWidgets(
      'El paciente debe ser registrado en su base de datos correspondiente',
      (WidgetTester tester) async {
    await initHive();
    //create a widget test to test the signup page
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ElevatedButton), findsNWidgets(1));
  });
}*/

void main() {
  testWidgets('Test signup', (WidgetTester widgetTester) async {
    widgetTester.pumpWidget(const MyApp());
    final button = find.byKey(const Key('signup'));
    expect(button, findsOneWidget);
    await widgetTester.tap(button);
    await widgetTester.pumpAndSettle();
    final signup = find.byKey(const Key('signup'));
    expect(signup, findsOneWidget);
    final dni = find.byKey(const Key('dni'));
    expect(dni, findsOneWidget);
    final password = find.byKey(const Key('password'));
    expect(password, findsOneWidget);
    final email = find.byKey(const Key('email'));
    expect(email, findsOneWidget);
    final name = find.byKey(const Key('name'));
    expect(name, findsOneWidget);
    final signupButton = find.byKey(const Key('signupButton'));
    expect(signupButton, findsOneWidget);
    await widgetTester.tap(dni);
    await widgetTester.enterText(dni, '00000000T');
    await widgetTester.tap(password);
    await widgetTester.enterText(password, '12345678');
    await widgetTester.tap(email);
    await widgetTester.enterText(email, 'jaimeroade@gmail.com');
  });
}
