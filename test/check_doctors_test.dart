import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/admin/check_doctors.dart';
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
    await Hive.openBox('doctors');
    final doctorsBox = Hive.box('doctors');
    await doctorsBox.clear();

    await doctorsBox.put('32738039T', {
      'dni': '32738039T',
      'password': '12345678',
      'email': 'doctor@doctor.com',
      'name': 'Doctor',
      'collegiateNumber': '123456789',
    });

    await doctorsBox.put('12345678Z', {
      'dni': '12345678Z',
      'password': '12345678',
      'email': 'doctor2@doctor.com',
      'name': 'Doctor2',
      'collegiateNumber': '987654321',
    });

    await doctorsBox.put('87654321X', {
      'dni': '87654321X',
      'password': '12345678',
      'email': 'doctor3@doctor.com',
      'name': 'Doctor3',
      'collegiateNumber': '112233445',
    });
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('Se muestran los doctores correctamente',
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
      home: CheckDoctors(title: 'Check Doctors Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Check Doctors Test'), findsOneWidget);
    expect(find.text('DNI/NIE: 32738039T'), findsOneWidget);
    expect(find.text('DNI/NIE: 12345678Z'), findsOneWidget);
    expect(find.text('DNI/NIE: 87654321X'), findsOneWidget);
    expect(find.text('Full name: Doctor'), findsOneWidget);
    expect(find.text('Full name: Doctor2'), findsOneWidget);
    expect(find.text('Full name: Doctor3'), findsOneWidget);
    expect(find.text('Collegiate number: 123456789'), findsOneWidget);
    expect(find.text('Collegiate number: 987654321'), findsOneWidget);
    expect(find.text('Collegiate number: 112233445'), findsOneWidget);
    expect(find.text('Email: doctor@doctor.com'), findsOneWidget);
    expect(find.text('Email: doctor2@doctor.com'), findsOneWidget);
    expect(find.text('Email: doctor3@doctor.com'), findsOneWidget);
    expect(find.byType(IconButton), findsNWidgets(4));
  });
}
