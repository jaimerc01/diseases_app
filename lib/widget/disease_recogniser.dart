import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../classifier/classifier.dart';
import '../styles.dart';
import 'disease_image.dart';
import 'drawer_app.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

const _labelsFileName = 'assets/labels.txt';
const _modelFileName = 'model_unquant.tflite';

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
  bool _analyzing = false;
  File? _imageFile;
  final picker = ImagePicker();
  final double _bigSize = 250;
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

  Future<void> _loadClassifier() async {
    final classifier = await Classifier.loadClassifier(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier;
  }

  Widget _buildAnalyzingText() {
    if (!_analyzing) {
      return const SizedBox.shrink();
    }
    return const Text('Analizando...', style: analyzingTextStyle);
  }

  Widget _buildTitle() {
    return const Text(
      'Clasificador de enfermedades',
      style: titleTextStyle,
      textAlign: TextAlign.center,
    );
  }

  void _setAnalyzing(bool value) {
    setState(() {
      _analyzing = value;
    });
  }

  void _onPickImage(ImageSource source) async {
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage == null) {
      return;
    }

    final imageFile = File(pickedImage.path);
    setState(() {
      _imageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier!.predict(imageInput);

    final diseaseLabel = resultCategory.label;
    final accuracy = resultCategory.score;
    final result = resultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;

    _setAnalyzing(false);

    setState(() {
      _resultStatus = result;
      _diseaseLabel = diseaseLabel;
      _accuracy = accuracy;
    });
  }

  void _storeInHistory() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    final formattedDate = formatter.format(now);
    _boxHistory.put(_imageFile.toString(), {
      'dni': '${_boxLogin.get('DNI')}',
      'path': _imageFile?.path,
      'date': formattedDate,
      'result': _diseaseLabel,
      'accuracy': _accuracy,
    });
  }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'No se ha reconocido';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _diseaseLabel;
    } else {
      title = '';
    }

    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Precisión: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    _storeInHistory();

    return Column(
      children: [
        Text(title, style: resultTextStyle),
        const SizedBox(height: 10),
        Text(accuracyLabel, style: accuracyTextStyle)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 1),
        backgroundColor: darkGreen,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 35),
                child: _buildTitle(),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  DiseaseImage(file: _imageFile, size: _bigSize),
                  _buildAnalyzingText(),
                ],
              ),
              const SizedBox(height: 10),
              _buildResultView(),
              const Spacer(flex: 4),
              TextButton(
                onPressed: () => _onPickImage(ImageSource.gallery),
                child: Container(
                  width: 270,
                  height: 50,
                  color: brown,
                  child: const Center(
                      child: Text('Abrir galería',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: cream,
                          ))),
                ),
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
