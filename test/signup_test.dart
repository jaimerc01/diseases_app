import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/patient/signup.dart';
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

  testWidgets('La pantalla de signup muestra formulario y errores',
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
      home: Signup(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Create your personal account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
    expect(find.text('DNI/NIE'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.password_outlined), findsNWidgets(2));
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Hacemos scroll para ver el botón de signup
    await tester.drag(
        find.byKey(const Key('passwordSignup')), const Offset(0, -50));

    //Click en el botón de sign up sin datos introducidos
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your DNI/NIE'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your password'), findsNWidgets(2));
  });
}
