import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/user/profile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:diseases_app/user/encrypt_password.dart';

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
    await Hive.openBox('admins');
    await Hive.openBox('doctors');
    await Hive.openBox('login');
    await Hive.openBox('history');
    await Hive.openBox('patientHistory');
    await Hive.openBox('doctorPatients');

    final patientBox = Hive.box('patients');
    final boxLogin = Hive.box('login');
    final doctorsBox = Hive.box('doctors');
    final adminsBox = Hive.box('admins');
    final historyBox = Hive.box('history');
    final boxPatientsHistory = Hive.box('patientHistory');
    final boxDoctorPatients = Hive.box('doctorPatients');

    await patientBox.clear();
    await boxLogin.clear();
    await doctorsBox.clear();
    await adminsBox.clear();
    await historyBox.clear();
    await boxPatientsHistory.clear();
    await boxDoctorPatients.clear();

    await patientBox.put('32738039T', {
      'dni': '32738039T',
      'password': encryptPassword('12345678'),
      'email': 'patient@patient.com',
      'name': 'Patient',
    });

    boxLogin.put('dni', '32738039T');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('La pantalla del perfil muestra la información correcta',
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
      home: Profile(title: 'Profile Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Profile Test'), findsOneWidget);
    expect(find.text('DNI/NIE: 32738039T'), findsOneWidget);
    expect(find.text('Full name: Patient'), findsOneWidget);
    expect(find.text('Email: patient@patient.com'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
