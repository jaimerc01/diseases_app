import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          ? Center(
              child: Text(AppLocalizations.of(context).seleccione_foto,
                  style: imageTextStyle))
          : Image.file(file!, fit: BoxFit.cover),
    );
  }
}
