import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../widget/drawer_app.dart';

class Profile extends StatefulWidget {
  final String? title;
  const Profile({super.key, required this.title});

  static const routeName = '/profile';

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 2),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 150),
          Text('DNI/NIF: ${_boxLogin.get('DNI')}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text(
              // ignore: prefer_adjacent_string_concatenation
              'Nombre completo: ' +
                  '${_boxPatients.get(_boxLogin.get('DNI'))['Name']}',
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text(
              // ignore: prefer_adjacent_string_concatenation
              'Correo electrónico: ' +
                  '${_boxPatients.get(_boxLogin.get('DNI'))['Email']}',
              style: const TextStyle(fontSize: 18)),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/updateProfile'),
        tooltip: 'Presione para actualizar la información del perfil',
        label: const Text('Actualizar perfil'),
        icon: const Icon(Icons.person),
      ),
    );
  }
}
