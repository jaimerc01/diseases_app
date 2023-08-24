import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/user/login.dart';
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
    await Hive.openBox('patientHistory');
    await Hive.openBox('admins');
    await Hive.openBox('doctors');
    await Hive.openBox('login');

    final adminBox = Hive.box('admins');
    final doctorsBox = Hive.box('doctors');
    final patientsBox = Hive.box('patients');
    final historyBox = Hive.box('patientHistory');
    final loginBox = Hive.box('login');

    await adminBox.clear();
    await doctorsBox.clear();
    await patientsBox.clear();
    await historyBox.clear();
    await loginBox.clear();

    await adminBox.put('00000000T', {
      'dni': '00000000T',
      'password': '12345678',
      'email': 'admin@admin.com',
      'name': 'Admin',
    });
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('La pantalla de login muestra correctamente formulario y errores',
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
      home: Login(),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Log in your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('DNI/NIE'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card), findsOneWidget);
    expect(find.byIcon(Icons.password_outlined), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    //Click en el botón de login sin datos introducidos
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Enter your DNI/NIE'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);

    //Introducir datos incorrectos
    await tester.enterText(find.byKey(const Key('dni')), '12345678');
    await tester.enterText(find.byKey(const Key('password')), '11111111');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text("Your DNI/NIE isn't registered"), findsOneWidget);

    await tester.enterText(find.byKey(const Key('dni')), '00000000T');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Wrong password'), findsOneWidget);
  });
}
