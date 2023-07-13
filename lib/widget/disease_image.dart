import 'dart:io';
import 'package:flutter/material.dart';

import '../styles.dart';

class DiseaseImage extends StatelessWidget {
  final File? file;
  const DiseaseImage({super.key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      color: Colors.grey,
      child: (file == null)
          ? _emptyWidget()
          : Image.file(file!, fit: BoxFit.cover),
    );
  }

  Widget _emptyWidget() {
    return const Center(
        child: Text('Seleccione una foto', style: kAnalyzingTextStyle));
  }
}
