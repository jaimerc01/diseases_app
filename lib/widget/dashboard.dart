import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'drawer_app.dart';
import '../styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  final String? title;
  const Dashboard({super.key, required this.title});

  static const routeName = '/';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');

  // Obtiene el nombre del usuario logeado
  String? getLoggedUserName() {
    final dni = _boxLogin.get('dni');
    if (dni == null) return '';

    if (_boxPatients.containsKey(dni)) {
      return _boxPatients.get(dni)?['name'].toString();
    } else if (_boxAdmins.containsKey(dni)) {
      return _boxAdmins.get(dni)?['name'].toString();
    } else if (_boxDoctors.containsKey(dni)) {
      return _boxDoctors.get(dni)?['name'].toString();
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(title: Text(widget.title ?? 'Dashboard')),
      drawer: const DrawerApp(drawerValue: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 150),
            // Mensaje de bienvenida
            Text(
              AppLocalizations.of(context).titulo_inicio,
              style: subtitleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Nombre del usuario logeado
            Text(
              getLoggedUserName().toString(),
              style: subtitleTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
