import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'drawer_app.dart';

class Dashboard extends StatefulWidget {
  final String? title;
  const Dashboard({super.key, required this.title});

  static const routeName = '/dashboard';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Me has presionado tantas veces:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(_boxPatients.get(_boxLogin.get('DNI'))['Email'].toString())
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        tooltip: 'Incrementar',
        label: const Text('Incrementar'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
