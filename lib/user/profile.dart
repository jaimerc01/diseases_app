import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final _boxHistory = Hive.box('history');

  void _deleteResults(dni) {
    int index;
    for (index = 0; index < _boxHistory.length; index++) {
      if (_boxHistory.getAt(index)['dni'] == dni) {
        _boxHistory.deleteAt(index);
      }
    }
  }

  List<Widget> _getUserDetails(var dni, var name, var email,
      [var collegiateNumber]) {
    final userDetails = [
      const SizedBox(height: 150),
      Text('DNI/NIE: $dni', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text('${AppLocalizations.of(context).nombre}: $name',
          style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 10),
      Text('${AppLocalizations.of(context).correo_electronico}: $email',
          style: const TextStyle(fontSize: 18)),
    ];

    if (collegiateNumber != null) {
      userDetails.addAll([
        const SizedBox(height: 10),
        Text(
            // ignore: lines_longer_than_80_chars
            '${AppLocalizations.of(context).numero_colegiado}: $collegiateNumber',
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
          child: Text(AppLocalizations.of(context).boton_actualizar,
              style: buttonTextStyle),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/password');
            },
            child: Text(AppLocalizations.of(context).cambiar_contrasena),
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
                  title: Text(AppLocalizations.of(context).confirmar_borrado),
                  content: Text(AppLocalizations.of(context).pregunta_borrado),
                  actions: <Widget>[
                    TextButton(
                      child: Text(AppLocalizations.of(context).boton_cancelar),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(AppLocalizations.of(context).boton_confirmar),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                        if (_boxPatients.containsKey(dni)) {
                          _deleteResults(dni);
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
                            content: Center(
                              child:
                                  Text(AppLocalizations.of(context).borrado_ok),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
            child: Text(AppLocalizations.of(context).borrar_cuenta),
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
        Text('DNI/NIE: $dni', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text('${AppLocalizations.of(context).nombre}: ${admin['name']}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        Text(
            // ignore: lines_longer_than_80_chars
            '${AppLocalizations.of(context).correo_electronico}: ${admin['email']}',
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
