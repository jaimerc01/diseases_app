import 'dart:io';
import 'package:flutter/material.dart';

import '../styles.dart';

class DiseaseImage extends StatelessWidget {
  final File? file;
  final double? size;
  const DiseaseImage({super.key, this.file, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.blueGrey,
      child: (file == null)
          ? _emptyWidget()
          : Image.file(file!, fit: BoxFit.cover),
    );
  }

  Widget _emptyWidget() {
    return const Center(
        child: Text('Seleccione una foto', style: imageTextStyle));
  }
}
