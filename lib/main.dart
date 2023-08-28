import 'package:flutter/material.dart';
import 'widget/dashboard.dart';
import 'user/login.dart';
import 'patient/signup.dart';
import 'classifier/disease_recogniser.dart';
import 'user/profile.dart';
import 'user/update_profile.dart';
import 'patient/history.dart';
import 'admin/check_doctors.dart';
import 'admin/add_doctor.dart';
import 'doctor/check_patients.dart';
import 'doctor/assign_patients.dart';
import 'user/change_password.dart';
import 'styles.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'database/init_hive.dart';
import 'database/data_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de Hive
  await initHive();
  // Inserción de datos en Hive
  await insertDataHive();
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
            seedColor: pantoneBlueVeryPeryVariant,
          ),
        ),
        //Se establecen los idiomas disponibles
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('es'),
          Locale('gl'),
        ],
        //Se establecen la ruta inicial y las rutas de la aplicación
        initialRoute: Login.routeName,
        routes: {
          Dashboard.routeName: (context) =>
              Dashboard(title: AppLocalizations.of(context).titulo_dashboard),
          Login.routeName: (context) => const Login(),
          DiseaseRecogniser.routeName: (context) => DiseaseRecogniser(
              title: AppLocalizations.of(context).titulo_clasificador),
          Profile.routeName: (context) =>
              Profile(title: AppLocalizations.of(context).titulo_profile),
          Signup.routeName: (context) => const Signup(),
          UpdateProfile.routeName: (context) =>
              UpdateProfile(title: AppLocalizations.of(context).titulo_update),
          History.routeName: (context) =>
              History(title: AppLocalizations.of(context).titulo_history),
          CheckDoctors.routeName: (context) =>
              CheckDoctors(title: AppLocalizations.of(context).titulo_doctors),
          AddDoctor.routeName: (context) =>
              AddDoctor(title: AppLocalizations.of(context).titulo_add),
          CheckPatients.routeName: (context) => CheckPatients(
              title: AppLocalizations.of(context).titulo_patients),
          AssingPatient.routeName: (context) =>
              AssingPatient(title: AppLocalizations.of(context).titulo_assign),
          ChangePassword.routeName: (context) =>
              ChangePassword(title: AppLocalizations.of(context).titulo_change),
        });
  }
}
