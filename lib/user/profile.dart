import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../styles.dart';
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

  List<Widget> _getUserDetails(var dni, var name, var email,
      [var collegiateNumber]) {
    final userDetails = [
      const SizedBox(height: 150),
      Text('DNI/NIF: $dni', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text('Nombre completo: $name', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text('Correo electrónico: $email', style: const TextStyle(fontSize: 18)),
    ];

    if (collegiateNumber != null) {
      userDetails.addAll([
        const SizedBox(height: 10),
        Text('Número de colegiado: $collegiateNumber',
            style: const TextStyle(fontSize: 18)),
      ]);
    }

    userDetails.addAll([
      const SizedBox(height: 50),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => Navigator.pushNamed(context, '/updateProfile'),
          child: const Text('ACTUALIZAR DATOS', style: buttonTextStyle),
        ),
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
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Confirmar borrado de cuenta'),
                  content: const Text(
                      // ignore: lines_longer_than_80_chars
                      '¿Está seguro de que desea borrar su cuenta permanentemente?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('CANCELAR'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('CONFIRMAR'),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                        if (_boxPatients.containsKey(dni)) {
                          _boxPatients.delete(dni);
                        } else {
                          _boxDoctors.delete(dni);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            width: 240,
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            behavior: SnackBarBehavior.floating,
                            content: const Center(
                              child: Text('Cuenta borrada correctamente'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Text('Borrar cuenta'),
          ),
        ],
      ),
    ]);

    return userDetails;
  }

  List<Widget> _checkUser() {
    final dni = _boxLogin.get('dni');

    if (_boxPatients.containsKey(dni)) {
      final patient = _boxPatients.get(dni);
      return _getUserDetails(dni, patient['name'], patient['email']);
    } else if (_boxAdmins.containsKey(dni)) {
      final admin = _boxAdmins.get(dni);
      return [
        const SizedBox(height: 150),
        Text('DNI/NIF: $dni', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text('Nombre completo: ${admin['name']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text('Correo electrónico: ${admin['email']}',
            style: const TextStyle(fontSize: 18)),
      ];
    } else {
      final doctor = _boxDoctors.get(dni);
      return _getUserDetails(
          dni, doctor['name'], doctor['email'], doctor['collegiateNumber']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
