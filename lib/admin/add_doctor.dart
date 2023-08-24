import 'package:dni_nie_validator/dni_nie_validator.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widget/drawer_app.dart';
import '../styles.dart';
import '../user/encrypt_password.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddDoctor extends StatefulWidget {
  final String? title;
  const AddDoctor({super.key, required this.title});

  static const routeName = '/addDoctor';

  @override
  State<AddDoctor> createState() => _AddDoctorState();
}

class _AddDoctorState extends State<AddDoctor> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodeCollegiateNumber = FocusNode();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeNombre = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerDni = TextEditingController();
  final TextEditingController _controllerCollegiateNumber =
      TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword =
      TextEditingController();

  final _boxPatients = Hive.box('patients');
  final _boxAdmins = Hive.box('admins');
  final _boxDoctors = Hive.box('doctors');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 4),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              TextFormField(
                key: const Key('dniAdd'),
                style: formFieldTextStyle,
                controller: _controllerDni,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: 'DNI/NIE',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).introduzca_dni;
                  } else if (value.length != 9) {
                    return AppLocalizations.of(context).tamano_dni;
                  } else if (!value.isValidDNI() && !value.isValidNIE()) {
                    return AppLocalizations.of(context).correctamente_dni;
                  } else if (_boxPatients.containsKey(value) ||
                      _boxAdmins.containsKey(value) ||
                      _boxDoctors.containsKey(value)) {
                    return AppLocalizations.of(context).ya_registrado;
                  }

                  return null;
                },
                onEditingComplete: () =>
                    _focusNodeCollegiateNumber.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('collegiateNumberAdd'),
                style: formFieldTextStyle,
                controller: _controllerCollegiateNumber,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).numero_colegiado,
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)
                        .introduzca_numero_colegiado;
                  } else if (value.length != 9) {
                    // ignore: lines_longer_than_80_chars
                    return AppLocalizations.of(context).tamano_numero_colegiado;
                  } else {
                    for (var index = 0; _boxDoctors.length > index; index++) {
                      if (_boxDoctors.getAt(index)['collegiateNumber'] ==
                          value) {
                        return AppLocalizations.of(context)
                            .ya_registrado_numero_colegiado;
                      }
                    }
                  }

                  return null;
                },
                onEditingComplete: () => _focusNodeEmail.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('emailAdd'),
                style: formFieldTextStyle,
                controller: _controllerEmail,
                focusNode: _focusNodeEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).correo_electronico,
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
                    return AppLocalizations.of(context).introduzca_correo;
                  } else if (!(value.contains('@') && value.contains('.'))) {
                    return AppLocalizations.of(context).no_valido_correo;
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodeNombre.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('nameAdd'),
                style: formFieldTextStyle,
                controller: _controllerName,
                focusNode: _focusNodeNombre,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).nombre,
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
                    return AppLocalizations.of(context).introduzca_nombre;
                  }
                  return null;
                },
                onEditingComplete: () => _focusNodePassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('passwordAdd'),
                style: formFieldTextStyle,
                controller: _controllerPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).contrasena,
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
                    return AppLocalizations.of(context).introduzca_contrasena;
                  } else if (value.length < 8) {
                    return AppLocalizations.of(context).tamano_contrasena;
                  }
                  return null;
                },
                onEditingComplete: () =>
                    _focusNodeConfirmPassword.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextFormField(
                key: const Key('confirmPasswordAdd'),
                style: formFieldTextStyle,
                controller: _controllerConFirmPassword,
                obscureText: _obscurePassword,
                focusNode: _focusNodeConfirmPassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  errorStyle: errorTextStyle,
                  labelText: AppLocalizations.of(context).confirmar_contrasena,
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
                    return AppLocalizations.of(context).introduzca_contrasena;
                  } else if (value != _controllerPassword.text) {
                    return AppLocalizations.of(context).no_coincide_contrasena;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _boxDoctors.put(_controllerDni.text, {
                            'dni': _controllerDni.text,
                            'collegiateNumber':
                                _controllerCollegiateNumber.text,
                            'password': encryptPassword(
                                _controllerConFirmPassword.text),
                            'email': _controllerEmail.text,
                            'name': _controllerName.text,
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
                              content: Center(
                                child: Text(
                                    AppLocalizations.of(context).registro_ok),
                              ),
                            ),
                          );

                          _formKey.currentState?.reset();

                          Navigator.pushNamed(context, '/doctors');
                        }
                      },
                      child: Text(
                          AppLocalizations.of(context).boton_anadir_medico),
                    ),
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
    _focusNodeCollegiateNumber.dispose();
    _focusNodeEmail.dispose();
    _focusNodeNombre.dispose();
    _focusNodePassword.dispose();
    _focusNodeConfirmPassword.dispose();
    _controllerDni.dispose();
    _controllerCollegiateNumber.dispose();
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerName.dispose();
    _controllerConFirmPassword.dispose();
    super.dispose();
  }
}
