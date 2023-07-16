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
  bool _isAnalyzing = false;
  final picker = ImagePicker();
  File? _selectedImageFile;
  final double _bigSize = 250;
  final _boxHistory = Hive.box('history');
  final _boxLogin = Hive.box('login');

  // Result
  _ResultStatus _resultStatus = _ResultStatus.notStarted;
  String _diseaseLabel = '';
  double _accuracy = 0.0;

  late Classifier? _classifier;

  @override
  void initState() {
    super.initState();
    _loadClassifier();
  }

  Future<void> _loadClassifier() async {
    final classifier = await Classifier.loadWith(
      labelsFileName: _labelsFileName,
      modelFileName: _modelFileName,
    );
    _classifier = classifier;
  }

  Widget _buildImageView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        DiseaseImage(file: _selectedImageFile, size: _bigSize),
        _buildAnalyzingText(),
      ],
    );
  }

  Widget _buildAnalyzingText() {
    if (!_isAnalyzing) {
      return const SizedBox.shrink();
    }
    return const Text('Analyzing...', style: kAnalyzingTextStyle);
  }

  Widget _buildTitle() {
    return const Text(
      'Disease Recogniser',
      style: kTitleTextStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPickPhotoButton({
    required ImageSource source,
    required String title,
  }) {
    return TextButton(
      onPressed: () => _onPickImage(source),
      child: Container(
        width: 300,
        height: 50,
        color: kColorBrown,
        child: Center(
            child: Text(title,
                style: const TextStyle(
                  fontFamily: kButtonFont,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                  color: kColorLightYellow,
                ))),
      ),
    );
  }

  void _setAnalyzing(bool flag) {
    setState(() {
      _isAnalyzing = flag;
    });
  }

  void _onPickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) {
      return;
    }

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
    });

    _analyzeImage(imageFile);
  }

  void _analyzeImage(File image) {
    _setAnalyzing(true);

    final imageInput = img.decodeImage(image.readAsBytesSync())!;

    final resultCategory = _classifier!.predict(imageInput);

    final result = resultCategory.score >= 0.8
        ? _ResultStatus.found
        : _ResultStatus.notFound;
    final diseaseLabel = resultCategory.label;
    final accuracy = resultCategory.score;

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
    _boxHistory.put(_selectedImageFile.toString(), {
      'dni': '${_boxLogin.get('DNI')}',
      'contenido': _selectedImageFile?.path,
      'fecha': formattedDate,
      'resultado': _diseaseLabel,
      'precision': _accuracy,
    });
  }

  Widget _buildResultView() {
    var title = '';

    if (_resultStatus == _ResultStatus.notFound) {
      title = 'Fail to recognise';
    } else if (_resultStatus == _ResultStatus.found) {
      title = _diseaseLabel;
    } else {
      title = '';
    }

    var accuracyLabel = '';
    if (_resultStatus == _ResultStatus.found) {
      accuracyLabel = 'Accuracy: ${(_accuracy * 100).toStringAsFixed(2)}%';
    }

    _storeInHistory();

    return Column(
      children: [
        Text(title, style: kResultTextStyle),
        const SizedBox(height: 10),
        Text(accuracyLabel, style: kResultRatingTextStyle)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title!)),
        drawer: const DrawerApp(drawerValue: 1),
        backgroundColor: kBgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: _buildTitle(),
              ),
              const SizedBox(height: 20),
              _buildImageView(),
              const SizedBox(height: 10),
              _buildResultView(),
              const Spacer(flex: 5),
              /*_buildPickPhotoButton(
                title: 'Take a photo',
                source: ImageSource.camera,
              ),*/
              _buildPickPhotoButton(
                title: 'Pick from gallery',
                source: ImageSource.gallery,
              ),
              const Spacer(),
            ],
          ),
        ));
  }
}
