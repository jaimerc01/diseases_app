import '/user/encrypt_password.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> insertDataHive() async {
  final adminBox = Hive.box('admins');
  await adminBox.put('00000000T', {
    'dni': '00000000T',
    'password': encryptPassword('12345678'),
    'email': 'admin@admin.com',
    'name': 'Admin',
  });

  /*final doctorBox = Hive.box('doctors');
  await doctorBox.put('32727485A', {
    'dni': '32727485A',
    'collegiateNumber': '123456789',
    'password': encryptPassword('12345678'),
    'email': 'doctor@doctor.com',
    'name': 'Doctor Doctor',
  });
  await doctorBox.put('87654321X', {
    'dni': '87654321X',
    'collegiateNumber': '987654321',
    'password': encryptPassword('12345678'),
    'email': 'doctor2@doctor2.com',
    'name': 'Doctor2 Doctor2',
  });

  final patientBox = Hive.box('patients');
  await patientBox.put('32738039T', {
    'dni': '32738039T',
    'password': encryptPassword('12345678'),
    'email': 'jaime@doctor.com',
    'name': 'Jaime Paciente',
    'doctor': '32727485A',
  });
  await patientBox.put('12345678Z', {
    'dni': '12345678Z',
    'password': encryptPassword('12345678'),
    'email': 'paciente2@paciente2.com',
    'name': 'paciente 2',
    'doctor': '32727485A',
  });*/
}
