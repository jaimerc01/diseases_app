import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/user/update_profile.dart';
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
    await Hive.openBox('doctors');
    await Hive.openBox('login');

    final patientsBox = Hive.box('patients');
    final loginBox = Hive.box('login');
    final doctorsBox = Hive.box('doctors');

    await patientsBox.clear();
    await loginBox.clear();
    await doctorsBox.clear();

    await doctorsBox.put('12345678Z', {
      'dni': '12345678Z',
      'password': encryptPassword('12345678'),
      'email': 'doctor@doctor.com',
      'name': 'Doctor',
      'collegiateNumber': '123456789',
    });

    final boxLogin = Hive.box('login');
    boxLogin.put('dni', '12345678Z');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('La actualización del perfil muestra la información correcta',
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
      home: UpdateProfile(title: 'Update Profile Test'),
    ));

    await tester.pumpAndSettle();

    final emailTextField = find
        .byKey(const Key('emailUpdate'))
        .evaluate()
        .first
        .widget as TextFormField;
    expect(emailTextField.controller!.text, equals('doctor@doctor.com'));

    final nameTextField = find
        .byKey(const Key('nameUpdate'))
        .evaluate()
        .first
        .widget as TextFormField;
    expect(nameTextField.controller!.text, equals('Doctor'));

    expect(find.text('Update Profile Test'), findsOneWidget);
    expect(find.byKey(const Key('emailUpdate')), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Click en el botón de update sin datos introducidos
    await tester.enterText(find.byKey(const Key('emailUpdate')), '');
    await tester.enterText(find.byKey(const Key('nameUpdate')), '');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your full name'), findsOneWidget);

    //Introducir datos incorrectos
    await tester.enterText(find.byKey(const Key('emailUpdate')), '1');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Invalid email'), findsOneWidget);
  });
}
