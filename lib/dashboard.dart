import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const routeName = '/dashboard';

  final String title = 'Primera versión';

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

  int drawerValue = 0;

  void _onSelectItem(int pos) {
    setState(() {
      drawerValue = pos;
    });
  }

  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Dashboard'),
            selected: (0 == drawerValue),
            onTap: () {
              _onSelectItem(0);
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            title: const Text('Classifier'),
            selected: (1 == drawerValue),
            onTap: () {
              _onSelectItem(1);
              Navigator.pushNamed(context, '/plant');
            },
          )
        ],
      )),
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
