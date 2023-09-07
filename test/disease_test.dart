import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diseases_app/classifier/disease_recogniser.dart';
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
    await Hive.openBox('history');

    final boxLogin = Hive.box('login');
    final historyBox = Hive.box('history');

    await boxLogin.clear();
    await historyBox.clear();

    boxLogin.put('dni', '32738039T');
  });

  tearDown(() {
    Hive.close();
  });

  testWidgets('El clasificador de enfermedades muestra la información correcta',
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
      home: DiseaseRecogniser(title: 'Disease Recogniser Test'),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Disease Recogniser Test'), findsOneWidget);
    expect(find.text('Digestive diseases classifier'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
