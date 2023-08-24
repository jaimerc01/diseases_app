import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/doctor/assign_patients.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  setUp(() async {
    await Hive.initFlutter();
    await Hive.openBox('patients');
    await Hive.openBox('doctors');
    await Hive.openBox('login');

    final patientBox = Hive.box('patients');
    final boxLogin = Hive.box('login');
    final doctorsBox = Hive.box('doctors');

    await patientBox.clear();
    await boxLogin.clear();
    await doctorsBox.clear();

    await patientBox.put('32738039T', {
      'dni': '32738039T',
      'password': '12345678',
      'email': 'patient@patient.com',
      'name': 'Patient',
      'doctor': '00000000T',
    });

    await doctorsBox.put('12345678Z', {
      'dni': '12345678Z',
      'password': '12345678',
      'email': 'doctor@doctor.com',
      'name': 'Doctor',
      'collegiateNumber': '123456789',
    });

    await doctorsBox.put('00000000T', {
      'dni': '00000000T',
      'password': '12345678',
      'email': 'doctor2@doctor.com',
      'name': 'Doctor2',
      'collegiateNumber': '987654321',
    });

    boxLogin.put('dni', '12345678Z');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets(
      'La asignación de un usuario muestra los errores e información correctos',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('es'),
        Locale('gl'),
      ],
      home: AssingPatient(title: 'Assign Patients Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Assign Patients Test'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(1));
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Click en el botón de assign sin datos introducidos
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text("Enter the patient's DNI/NIE"), findsOneWidget);

    //Introducir datos incorrectos
    await tester.enterText(find.byKey(const Key('dniAssign')), '1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(
        find.text('The size does not match that of a DNI/NIE'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('dniAssign')), '32738039T');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(
        find.text('The patient already has a doctor assigned'), findsOneWidget);
  });
}
