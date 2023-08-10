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
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');

  List<Widget> _checkUser() {
    if (_boxPatients.containsKey(_boxLogin.get('dni'))) {
      return <Widget>[
        const SizedBox(height: 150),
        Text('DNI/NIF: ${_boxLogin.get('dni')}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Nombre completo: ' +
                '${_boxPatients.get(_boxLogin.get('dni'))['name']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Correo electrónico: ' +
                '${_boxPatients.get(_boxLogin.get('dni'))['email']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 50),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => Navigator.pushNamed(context, '/updateProfile'),
          child: const Text('Actualizar datos'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/password');
              },
              child: const Text('Cambiar contraseña'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _boxPatients.delete(_boxLogin.get('dni'));
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Borrar cuenta'),
            ),
          ],
        ),
      ];
    } else if (_boxAdmins.containsKey(_boxLogin.get('dni'))) {
      return <Widget>[
        const SizedBox(height: 150),
        Text('DNI/NIF: ${_boxLogin.get('dni')}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Nombre completo: ' +
                '${_boxAdmins.get(_boxLogin.get('dni'))['name']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Correo electrónico: ' +
                '${_boxAdmins.get(_boxLogin.get('dni'))['email']}',
            style: const TextStyle(fontSize: 18)),
      ];
    } else {
      return <Widget>[
        const SizedBox(height: 150),
        Text('DNI/NIF: ${_boxLogin.get('dni')}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Número de colegiado: ' +
                '${_boxDoctors.get(_boxLogin.get('dni'))['collegiateNumber']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Nombre completo: ' +
                '${_boxDoctors.get(_boxLogin.get('dni'))['name']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: prefer_adjacent_string_concatenation
            'Correo electrónico: ' +
                '${_boxDoctors.get(_boxLogin.get('dni'))['email']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 50),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => Navigator.pushNamed(context, '/updateProfile'),
          child: const Text('Actualizar datos'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/password');
              },
              child: const Text('Cambiar contraseña'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _boxDoctors.delete(_boxLogin.get('dni'));
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Borrar cuenta'),
            ),
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 2),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _checkUser(),
      )),
    );
  }
}
