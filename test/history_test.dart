import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/patient/history.dart';
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
    await Hive.openBox('history');
    await Hive.openBox('patientHistory');

    final patientBox = Hive.box('patients');
    final boxLogin = Hive.box('login');
    final doctorsBox = Hive.box('doctors');
    final historyBox = Hive.box('history');
    final patientHistoryBox = Hive.box('patientHistory');

    await patientBox.clear();
    await boxLogin.clear();
    await doctorsBox.clear();
    await historyBox.clear();
    await patientHistoryBox.clear();

    await patientBox.put('32738039T', {
      'dni': '32738039T',
      'password': '12345678',
      'email': 'patient@patient.com',
      'name': 'Patient',
    });

    await historyBox.put('/example', {
      'dni': '32738039T',
      'path': '/example',
      'date': '01/01/2000',
      'result': 'normal',
      'accuracy': 1,
    });

    await patientHistoryBox.put('/example', {
      'dni': '32738039T',
      'path': '/example',
      'date': '01/01/2000',
      'result': 'normal',
      'accuracy': 1,
    });

    boxLogin.put('dni', '32738039T');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('El historial muestra la información correcta',
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
      home: History(title: 'History Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('History Test'), findsOneWidget);
    expect(find.text('Date: 01/01/2000'), findsOneWidget);
    expect(find.text('Accuracy: 100.00%'), findsOneWidget);
    expect(find.text('Result: normal'), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(2));
  });
}
