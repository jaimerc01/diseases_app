import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  List<Widget> _checkUser() {
    final drawerItems = <Widget>[
      ListTile(
        leading: const Icon(
          Icons.home,
          color: Colors.white,
        ),
        title: const Text(
          'Inicio',
          style: drawerTextStyle,
        ),
        selected: (0 == widget.drawerValue),
        onTap: () {
          Navigator.pushNamed(context, '/');
        },
      ),
    ];
    if (_boxPatients.containsKey(_boxLogin.get('dni'))) {
      drawerItems.addAll([
        ListTile(
          leading: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          title: const Text(
            'Clasificador',
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
          title: const Text(
            'Historial',
            style: drawerTextStyle,
          ),
          selected: (3 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/history');
          },
        ),
      ]);
    } else if (_boxAdmins.containsKey(_boxLogin.get('dni'))) {
      drawerItems.addAll([
        ListTile(
          leading: const Icon(
            Icons.history,
            color: Colors.white,
          ),
          title: const Text(
            'Consultar doctores',
            style: drawerTextStyle,
          ),
          selected: (4 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/doctors');
          },
        ),
      ]);
    } else {
      drawerItems.add(ListTile(
        leading: const Icon(
          Icons.list_alt_outlined,
          color: Colors.white,
        ),
        title: const Text(
          'Consultar pacientes',
          style: drawerTextStyle,
        ),
        selected: (5 == widget.drawerValue),
        onTap: () {
          Navigator.pushNamed(context, '/patients');
        },
      ));
    }

    drawerItems.addAll([
      ListTile(
        leading: const Icon(
          Icons.person,
          color: Colors.white,
        ),
        title: const Text(
          'Perfil',
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
        title: const Text(
          'Cerrar sesión',
          style: drawerTextStyle,
        ),
        onTap: () {
          _boxLogin.delete(_boxLogin.get('dni'));
          _boxLogin.put('loginStatus', false);
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
