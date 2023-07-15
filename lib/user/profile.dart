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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('DNI/NIF: ${_boxLogin.get('DNI')}'),
          // ignore: prefer_adjacent_string_concatenation
          Text('Nombre completo: ' +
              '${_boxPatients.get(_boxLogin.get('DNI'))['Name']}'),
          Text('Email: ${_boxPatients.get(_boxLogin.get('DNI'))['Email']}'),
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/updateProfile'),
        tooltip: 'Press to update the data from this profile',
        label: const Text('Update profile'),
        icon: const Icon(Icons.person),
      ),
    );
  }
}
