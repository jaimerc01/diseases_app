import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DrawerApp extends StatefulWidget {
  final int? drawerValue;
  const DrawerApp({super.key, required this.drawerValue});

  @override
  State<DrawerApp> createState() => _DrawerAppState();
}

class _DrawerAppState extends State<DrawerApp> {
  final _boxLogin = Hive.box('login');

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        ListTile(
          title: const Text('Inicio'),
          selected: (0 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/');
          },
        ),
        ListTile(
          title: const Text('Clasificador'),
          selected: (1 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/classifier');
          },
        ),
        ListTile(
          title: const Text('Perfil'),
          selected: (2 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        ListTile(
          title: const Text('Historial'),
          selected: (3 == widget.drawerValue),
          onTap: () {
            Navigator.pushNamed(context, '/history');
          },
        ),
        ListTile(
          title: const Text('Cerrar sesión'),
          onTap: () {
            _boxLogin.delete(_boxLogin.get('DNI'));
            _boxLogin.put('loginStatus', false);
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    ));
  }
}
