import 'dart:convert';
import 'dart:typed_data';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initHive() async {
  //Se encriptan las cajas de Hive
  const flutterSecureStorage = FlutterSecureStorage();
  final encryptionKey = await flutterSecureStorage.read(key: 'key');

  Uint8List keyBytes;

  if (encryptionKey == null) {
    final key = Hive.generateSecureKey();
    keyBytes = Uint8List.fromList(key);
    await flutterSecureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  } else {
    keyBytes = base64Url.decode(encryptionKey);
  }
  final encryptionCipher = HiveAesCipher(keyBytes);

  //Se inicializan las cajas de Hive
  await Hive.initFlutter();
  await Hive.openBox('patients', encryptionCipher: encryptionCipher);
  await Hive.openBox('admins', encryptionCipher: encryptionCipher);
  await Hive.openBox('doctors', encryptionCipher: encryptionCipher);
  await Hive.openBox('history', encryptionCipher: encryptionCipher);
  await Hive.openBox('patientHistory', encryptionCipher: encryptionCipher);
  await Hive.openBox('login', encryptionCipher: encryptionCipher);
  await Hive.openBox('doctorPatients', encryptionCipher: encryptionCipher);
}
