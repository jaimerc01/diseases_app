import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/doctor/check_patients.dart';
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
    await Hive.openBox('login');
    await Hive.openBox('patients');
    await Hive.openBox('doctorPatients');

    final loginBox = Hive.box('login');
    final patientsBox = Hive.box('patients');
    final doctorPatientsBox = Hive.box('doctorPatients');

    await loginBox.clear();
    await patientsBox.clear();
    await doctorPatientsBox.clear();

    await patientsBox.put('32738039T', {
      'dni': '32738039T',
      'password': '12345678',
      'email': 'patient@patient.com',
      'name': 'Patient',
      'doctor': '00000000T',
    });

    await patientsBox.put('12345678Z', {
      'dni': '12345678Z',
      'password': '12345678',
      'email': 'patient2@patient.com',
      'name': 'Patient2',
      'doctor': '00000000T',
    });

    await patientsBox.put('87654321X', {
      'dni': '87654321X',
      'password': '12345678',
      'email': 'patient3@patient.com',
      'name': 'Patient3',
      'doctor': '0',
    });

    loginBox.put('dni', '00000000T');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('Se muestran los pacientes asignados correctamente',
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
      home: CheckPatients(title: 'Check Patients Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Check Patients Test'), findsOneWidget);
    expect(find.text('DNI/NIE: 32738039T'), findsOneWidget);
    expect(find.text('DNI/NIE: 12345678Z'), findsOneWidget);
    expect(find.text('Full name: Patient'), findsOneWidget);
    expect(find.text('Full name: Patient2'), findsOneWidget);
    expect(find.text('Email: patient@patient.com'), findsOneWidget);
    expect(find.text('Email: patient2@patient.com'), findsOneWidget);

    //Los seis anteriores, el del título y el del botón flotante
    expect(find.byType(Text), findsNWidgets(8));

    //Sólo encuentra cinco botones porque el tercer paciente no está asignado
    expect(find.byType(IconButton), findsNWidgets(5));
  });
}
