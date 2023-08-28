import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/admin/add_doctor.dart';
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

    final adminBox = Hive.box('admins');
    final doctorsBox = Hive.box('doctors');
    final patientsBox = Hive.box('patients');

    await adminBox.clear();
    await doctorsBox.clear();
    await patientsBox.clear();

    await adminBox.put('00000000T', {
      'dni': '00000000T',
      'password': encryptPassword('12345678'),
      'email': 'admin@admin.com',
      'name': 'Admin',
    });

    await patientsBox.put('32738039T', {
      'dni': '32738039T',
      'password': encryptPassword('qwertyui'),
      'email': 'patient@patient.com',
      'name': 'Patient',
      'doctor': '0',
    });

    await doctorsBox.put('12345678Z', {
      'dni': '12345678Z',
      'password': encryptPassword('87654321'),
      'email': 'doctor@doctor.com',
      'name': 'Doctor',
      'collegiateNumber': '123456789',
    });
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('La pantalla de add doctor muestra formulario y errores',
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
      home: AddDoctor(title: 'Add doctor Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Add doctor Test'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.text('Collegiate number'), findsOneWidget);
    expect(find.text('DNI/NIE'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsNWidgets(2));
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.password_outlined), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Click en el botón de add doctor con datos incorrectos
    await tester.enterText(find.byKey(const Key('dniAdd')), '1');
    await tester.enterText(find.byKey(const Key('collegiateNumberAdd')), '1');
    await tester.enterText(find.byKey(const Key('emailAdd')), '1');
    await tester.enterText(find.byKey(const Key('nameAdd')), '1');
    await tester.enterText(find.byKey(const Key('passwordAdd')), '1');
    await tester.enterText(find.byKey(const Key('confirmPasswordAdd')), '2');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(
        find.text('The size does not match that of a DNI/NIE'), findsOneWidget);
    expect(find.text('The size does not match that of a collegiate number'),
        findsOneWidget);
    expect(find.text('Invalid email'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Password does not match'), findsOneWidget);
  });
}
