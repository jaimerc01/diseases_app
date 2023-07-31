import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  final _boxLogin = Hive.box('login');
  final _boxPatients = Hive.box('patients');
  final _boxPatientHistory = Hive.box('patientHistory');
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');

  @override
  Widget build(BuildContext context) {
    _boxPatientHistory.clear();
    /*if (_boxLogin.get('loginStatus') == false) {
      Navigator.pushNamed(context, '/dashboard');
    }*/

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150),
              Text(
                'Inicie sesión en su cuenta',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 100),
              TextFormField(
                controller: _controllerDni,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'DNI/NIF',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onEditingComplete: () => _focusNodePassword.requestFocus(),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca su DNI/NIF';
                  } else if (!_boxPatients.containsKey(value) &&
                      !_boxAdmins.containsKey(value) &&
                      !_boxDoctors.containsKey(value)) {
                    return 'Su DNI/NIF no está registrado';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controllerPassword,
                focusNode: _focusNodePassword,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_outlined)
                          : const Icon(Icons.visibility_off_outlined)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduzca la contraseña';
                  } else if (_boxPatients.containsKey(_controllerDni.text) &&
                      value !=
                          _boxPatients.get(_controllerDni.text)['password']) {
                    return 'Contraseña incorrecta';
                  } else if (_boxAdmins.containsKey(_controllerDni.text) &&
                      value !=
                          _boxAdmins.get(_controllerDni.text)['password']) {
                    return 'Contraseña incorrecta';
                  } else if (_boxDoctors.containsKey(_controllerDni.text) &&
                      value !=
                          _boxDoctors.get(_controllerDni.text)['password']) {
                    return 'Contraseña incorrecta';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 60),
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
                        _boxLogin.put('loginStatus', true);
                        _boxLogin.put('dni', _controllerDni.text);

                        Navigator.pushNamed(context, '/');
                      }
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No tienes cuenta?'),
                      TextButton(
                        onPressed: () {
                          _formKey.currentState?.reset();

                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text('Registrarse'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerDni.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
