import 'dart:convert';
import 'package:flutter/material.dart';
import 'widget/dashboard.dart';
import 'user/login.dart';
import 'user/signup.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'widget/disease_recogniser.dart';
import 'user/profile.dart';
import 'user/update_profile.dart';
import 'user/history.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final String? title = 'Segunda versión';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 28, 92, 28),
          ),
        ),
        initialRoute: Login.routeName,
        routes: {
          Dashboard.routeName: (context) => Dashboard(title: title),
          Login.routeName: (context) => const Login(),
          DiseaseRecogniser.routeName: (context) =>
              DiseaseRecogniser(title: title),
          Profile.routeName: (context) => Profile(title: title),
          Signup.routeName: (context) => const Signup(),
          UpdateProfile.routeName: (context) => UpdateProfile(title: title),
          History.routeName: (context) => History(title: title),
        });
  }
}

Future<void> _initHive() async {
  const flutterSecureStorage = FlutterSecureStorage();
  final encryptionKey = await flutterSecureStorage.read(key: 'key');
  if (encryptionKey == null) {
    final key = Hive.generateSecureKey();
    await flutterSecureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }
  final key = await flutterSecureStorage.read(key: 'key');
  final encryptionKeyDecoded = base64Url.decode(key!);

  await Hive.initFlutter();
  await Hive.openBox('patients',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
  await Hive.openBox('admins',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
  await Hive.openBox('doctors',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
  await Hive.openBox('history',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
  await Hive.openBox('userHistory',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
  await Hive.openBox('login',
      encryptionCipher: HiveAesCipher(encryptionKeyDecoded));
}
