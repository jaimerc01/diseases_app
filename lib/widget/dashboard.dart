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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: AppBar(title: Text(widget.title ?? 'Default Title')),
      drawer: const DrawerApp(drawerValue: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 150),
            Text(
              AppLocalizations.of(context).titulo_inicio,
              style: subtitleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              _boxPatients.isNotEmpty &&
                      _boxLogin.isNotEmpty &&
                      _boxPatients.containsKey(_boxLogin.get('dni'))
                  ? (_boxPatients.get(_boxLogin.get('dni'))?['name'] ?? '')
                      .toString()
                  : '',
              style: subtitleTextStyle,
            ),
            Text(
              _boxAdmins.isNotEmpty &&
                      _boxLogin.isNotEmpty &&
                      _boxAdmins.containsKey(_boxLogin.get('dni'))
                  ? (_boxAdmins.get(_boxLogin.get('dni'))?['name'] ?? '')
                      .toString()
                  : '',
              style: subtitleTextStyle,
            ),
            Text(
              _boxDoctors.isNotEmpty &&
                      _boxLogin.isNotEmpty &&
                      _boxDoctors.containsKey(_boxLogin.get('dni'))
                  ? (_boxDoctors.get(_boxLogin.get('dni'))?['name'] ?? '')
                      .toString()
                  : '',
              style: subtitleTextStyle,
            )
          ],
        ),
      ),
    );
  }
}
