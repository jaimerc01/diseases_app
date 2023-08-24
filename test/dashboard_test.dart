import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/widget/dashboard.dart';
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
    await Hive.openBox('admins');
    await Hive.openBox('doctors');
    await Hive.openBox('login');

    final adminBox = Hive.box('admins');
    final boxLogin = Hive.box('login');
    final doctorsBox = Hive.box('doctors');
    final patientsBox = Hive.box('patients');

    await adminBox.clear();
    await doctorsBox.clear();
    await patientsBox.clear();
    await boxLogin.clear();

    await adminBox.put('00000000T', {
      'dni': '00000000T',
      'password': '12345678',
      'email': 'admin@admin.com',
      'name': 'Admin',
    });

    boxLogin.put('dni', '00000000T');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('La pantalla de inicio muestra la información correcta',
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
      home: Dashboard(title: 'Dashboard Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Dashboard Test'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
