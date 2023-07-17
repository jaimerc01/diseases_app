import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../widget/drawer_app.dart';

class UpdateProfile extends StatefulWidget {
  final String? title;
  const UpdateProfile({super.key, required this.title});

  static const routeName = '/updateProfile';

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  late final String _dni = '${_boxLogin.get('DNI')}';
  late final String _name = '${_boxPatients.get(_boxLogin.get('DNI'))['Name']}';
  late final String _email =
      '${_boxPatients.get(_boxLogin.get('DNI'))['Email']}';
  late final String _password =
      '${_boxPatients.get(_boxLogin.get('DNI'))['Password']}';

  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerDni.text = _dni;
    _controllerName.text = _name;
    _controllerEmail.text = _email;
  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 2),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(children: [
                  const SizedBox(height: 50),
                  TextFormField(
                    controller: _controllerEmail,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca el correo electrónico';
                      } else if (!(value.contains('@') &&
                          value.contains('.'))) {
                        return 'Correo electrónico no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controllerName,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca su nombre completo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _boxPatients.put(_controllerDni.text, {
                              'DNI': _controllerDni.text,
                              'Password': _password,
                              'Email': _controllerEmail.text,
                              'Name': _controllerName.text,
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                width: 200,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                behavior: SnackBarBehavior.floating,
                                content: const Text(
                                    'Perfil actualizado correctamente'),
                              ),
                            );

                            _formKey.currentState?.reset();

                            Navigator.pushNamed(context, '/profile');
                          }
                        },
                        child: const Text('Actualizar'),
                      ),
                    ],
                  ),
                ]))));
  }

  @override
  void dispose() {
    _controllerDni.dispose();
    _controllerEmail.dispose();
    _controllerName.dispose();
    super.dispose();
  }
}
