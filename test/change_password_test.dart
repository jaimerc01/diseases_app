import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/user/change_password.dart';
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
    await Hive.openBox('admins');

    final patientBox = Hive.box('patients');
    final boxLogin = Hive.box('login');
    final doctorsBox = Hive.box('doctors');
    final adminBox = Hive.box('admins');

    await patientBox.clear();
    await boxLogin.clear();
    await doctorsBox.clear();
    await adminBox.clear();

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

  testWidgets(
      'La actualización de la contraseña muestra la información correcta',
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
      home: ChangePassword(title: 'Change Password Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Change Password Test'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byIcon(Icons.password_outlined), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Click en el botón de change sin datos introducidos
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your current password'), findsOneWidget);
    expect(find.text('Enter your password'), findsNWidgets(2));

    //Introducir datos incorrectos
    await tester.enterText(
        find.byKey(const Key('currentPassword')), '123456789');
    await tester.enterText(find.byKey(const Key('newPassword')), '1');
    await tester.enterText(find.byKey(const Key('confirmPasswordChange')), '2');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Wrong password'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
    expect(find.text('Password does not match'), findsOneWidget);
  });
}
