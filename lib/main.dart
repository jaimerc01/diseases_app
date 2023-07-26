import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'widget/dashboard.dart';
import 'user/login.dart';
import 'patient/signup.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'widget/disease_recogniser.dart';
import 'user/profile.dart';
import 'user/update_profile.dart';
import 'user/history.dart';
import 'admin/check_doctors.dart';
import 'admin/add_doctor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          Dashboard.routeName: (context) => const Dashboard(title: 'Inicio'),
          Login.routeName: (context) => const Login(),
          DiseaseRecogniser.routeName: (context) =>
              const DiseaseRecogniser(title: 'Clasificador'),
          Profile.routeName: (context) =>
              const Profile(title: 'Perfil personal'),
          Signup.routeName: (context) => const Signup(),
          UpdateProfile.routeName: (context) =>
              const UpdateProfile(title: 'Actualizar perfil'),
          History.routeName: (context) => const History(title: 'Historial'),
          CheckDoctors.routeName: (context) =>
              const CheckDoctors(title: 'Lista de doctores'),
          AddDoctor.routeName: (context) =>
              const AddDoctor(title: 'Añadir doctor'),
        });
  }
}

Future<void> _initHive() async {
  const flutterSecureStorage = FlutterSecureStorage();
  final encryptionKey = await flutterSecureStorage.read(key: 'key');

  Uint8List keyBytes;

  if (encryptionKey == null) {
    final key = Hive.generateSecureKey();
    keyBytes = Uint8List.fromList(key);
    await flutterSecureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  } else {
    keyBytes = base64Url.decode(encryptionKey);
  }
  final encryptionCipher = HiveAesCipher(keyBytes);

  await Hive.initFlutter();
  await Hive.openBox('patients', encryptionCipher: encryptionCipher);
  await Hive.openBox('admins', encryptionCipher: encryptionCipher);
  await Hive.openBox('doctors', encryptionCipher: encryptionCipher);
  await Hive.openBox('history', encryptionCipher: encryptionCipher);
  await Hive.openBox('userHistory', encryptionCipher: encryptionCipher);
  await Hive.openBox('login', encryptionCipher: encryptionCipher);

  final adminBox = Hive.box('admins');
  await adminBox.put('00000000T', {
    'dni': '00000000T',
    'password': '12345678',
    'email': 'admin@admin.com',
    'name': 'Admin',
  });

  /*final doctorBox = Hive.box('doctors');
  await doctorBox.put('62995487M', {
    'dni': '62995487M',
    'collegiateNumber': '283499999',
    'password': '12345678',
    'email': 'doctor@doctor.com',
    'name': 'Doctor Doctor',
  });*/
}
