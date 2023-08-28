import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../styles.dart';

class DrawerApp extends StatefulWidget {
  final int? drawerValue;
  const DrawerApp({super.key, required this.drawerValue});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxAdmins = Hive.box('admins');
  final _boxPatientsHistory = Hive.box('patientHistory');
  final _boxDoctorPatients = Hive.box('doctorPatients');

  // Función para comprobar el usuario y mostrar las opciones del menú
  // dependiendo de si es un paciente, un doctor o un administrador
  List<Widget> _checkUser() {
    final dni = _boxLogin.get('dni');
    if (dni == null) return [];
    final drawerItems = <Widget>[
      // Opción de inicio común en todos
      ListTile(
        leading: const Icon(
          Icons.home,
          color: Colors.white,
        ),
        title: Text(
          AppLocalizations.of(context).drawer_inicio,
          style: drawerTextStyle,
        ),
        selected: (0 == widget.drawerValue),
        onTap: () {
          Navigator.pushNamed(context, '/');
        },
      ),
    ];
    // Si el usuario es un paciente, se añaden las opciones de clasificador e
    // historial
    if (_boxPatients.containsKey(dni)) {
      drawerItems.addAll([
        ListTile(
          leading: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          title: Text(
            AppLocalizations.of(context).drawer_clasificador,
            style: drawerTextStyle,
          ),
          selected: (1 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/classifier');
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.history,
            color: Colors.white,
          ),
          title: Text(
            AppLocalizations.of(context).drawer_historial,
            style: drawerTextStyle,
          ),
          selected: (3 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/history');
          },
        ),
      ]);
      // Si el usuario es un administrador, se añaden las opciones de ver los
      // los doctores
    } else if (_boxAdmins.containsKey(dni)) {
      drawerItems.addAll([
        ListTile(
          leading: const Icon(
            Icons.history,
            color: Colors.white,
          ),
          title: Text(
            AppLocalizations.of(context).drawer_doctores,
            style: drawerTextStyle,
          ),
          selected: (4 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/doctors');
          },
        ),
      ]);
      // Si el usuario es un doctor, se añaden las opciones de ver los pacientes
      // asignados
    } else {
      drawerItems.add(ListTile(
        leading: const Icon(
          Icons.list_alt_outlined,
          color: Colors.white,
        ),
        title: Text(
          AppLocalizations.of(context).drawer_pacientes,
          style: drawerTextStyle,
        ),
        selected: (5 == widget.drawerValue),
        onTap: () {
          Navigator.pushNamed(context, '/patients');
        },
      ));
    }

    // Opciones comunes a todos los usuarios, que son ver el perfil y cerrar
    // sesión
    drawerItems.addAll([
      ListTile(
        leading: const Icon(
          Icons.person,
          color: Colors.white,
        ),
        title: Text(
          AppLocalizations.of(context).drawer_perfil,
          style: drawerTextStyle,
        ),
        selected: (2 == widget.drawerValue),
        onTap: () {
          Navigator.pushNamed(context, '/profile');
        },
      ),
      ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        title: Text(
          AppLocalizations.of(context).drawer_cerrar_sesion,
          style: drawerTextStyle,
        ),
        onTap: () {
          _boxLogin.clear();
          _boxPatientsHistory.clear();
          _boxDoctorPatients.clear();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
    ]);

    return drawerItems;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        color: pantoneBlueVeryPeryVariant,
        child: ListView(
          children: _checkUser(),
        ),
      ),
    );
  }
}
