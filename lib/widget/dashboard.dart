import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'drawer_app.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 150),
            Text(
              'Bienvenido de nuevo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              _boxPatients.isNotEmpty
                  ? _boxPatients.get(_boxLogin.get('DNI'))['Name'].toString()
                  : '',
              style: Theme.of(context).textTheme.headlineSmall,
            )
          ],
        ),
      ),
    );
  }
}
