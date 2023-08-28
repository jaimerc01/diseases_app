import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';
import '../styles.dart';
import '../widget/drawer_app.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const _labelsFile = 'assets/labels.txt';
const _modelFile = 'model_unquant.tflite';

class DiseaseRecogniser extends StatefulWidget {
  final String? title;
  const DiseaseRecogniser({super.key, required this.title});

  static const routeName = '/classifier';

  @override
  State<DiseaseRecogniser> createState() => _DiseaseRecogniserState();
}

enum _ResultStatus {
  notStarted,
  notFound,
  found,
}

class _DiseaseRecogniserState extends State<DiseaseRecogniser> {
  File? _imageFile;
  final picker = ImagePicker();
  double _imageSize(BuildContext context) =>
      MediaQuery.of(context).size.width * 0.65;
  final _boxHistory = Hive.box('history');
  final _boxLogin = Hive.box('login');
  String _diseaseLabel = '';
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  double _accuracy = 0.0;

  late Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  // Carga e inicializa el clasificador
  Future<void> _loadClassifier() async {
    final classifier = await Classifier.loadClassifier(
      labelsFileName: _labelsFile,
      modelFileName: _modelFile,
    );
    _classifier = classifier;
  }

  // Función para seleccionar una imagen de la galería
  void _selectImage(ImageSource source) async {
    final selectedImage = await picker.pickImage(source: source);

    if (selectedImage == null) {
      return null;
    }

    final imageFile = File(selectedImage.path);
    setState(() {
      _imageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    // Clasifica la imagen
    final resultCategory = _classifier!.classify(imageInput);

    // Obtiene el resultado
    final diseaseLabel = resultCategory.label;
    final accuracy = resultCategory.score;
    final result = resultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;

    setState(() {
      _resultStatus = result;
      _diseaseLabel = diseaseLabel;
      _accuracy = accuracy;
    });
  }

  // Almacena el resultado en el historial
  void _storeInHistory() {
    final dni = _boxLogin.get('dni');
    if (dni == null) return;
    if (!_boxHistory.containsKey(_imageFile.toString())) {
      final now = DateTime.now();
      final formatter = DateFormat('dd-MM-yyyy');
      final formattedDate = formatter.format(now);
      _boxHistory.put(_imageFile.toString(), {
        'dni': '${_boxLogin.get('dni')}',
        'path': _imageFile?.path,
        'date': formattedDate,
        'result': _diseaseLabel,
        'accuracy': _accuracy,
      });
    }
  }

  Widget _buildResultView() {
    var title = '';

    // Si no obtiene más de un 80% de precisión, no se reconoce la enfermedad
    if (_resultStatus == _ResultStatus.notFound) {
      title = AppLocalizations.of(context).no_reconocido;
    } else if (_resultStatus == _ResultStatus.found) {
      title = _diseaseLabel;
    } else {
      title = '';
    }

    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel =
          // ignore: lines_longer_than_80_chars
          '${AppLocalizations.of(context).precision}: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    _storeInHistory();

    // Muestra el resultado
    return Column(
      children: [
        Text(title, style: classifierTextStyle),
        const SizedBox(height: 10),
        Text(accuracyLabel, style: classifierTextStyle)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      drawer: const DrawerApp(drawerValue: 1),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                // Título de la página
                child: Text(
                  AppLocalizations.of(context).titulo_clasificador,
                  style: titleTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  // Contenedor de la imagen donde se muestra
                  Container(
                    width: _imageSize(context),
                    height: _imageSize(context),
                    color: Colors.blueGrey,
                    child: (_imageFile == null)
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context).seleccione_foto,
                                style: imageTextStyle))
                        : Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Muestra el resultado
              _buildResultView(),
              const SizedBox(height: 30),
              // Botón para abrir la galería
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => _selectImage(ImageSource.gallery),
                  child: Text(AppLocalizations.of(context).boton_galeria,
                      style: buttonTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
