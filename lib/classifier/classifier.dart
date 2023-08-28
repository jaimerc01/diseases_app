import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'dart:math';

typedef ClassifierLabels = List<String>;

// Clase que representa el modelo de clasificación
class ClassifierModel {
  Interpreter interpreter;

  List<int> inputShape;
  List<int> outputShape;

  TfLiteType inputType;
  TfLiteType outputType;

  ClassifierModel({
    required this.interpreter,
    required this.inputShape,
    required this.outputShape,
    required this.inputType,
    required this.outputType,
  });
}

class ClassifierCategory {
  final String label;
  final double score;

  ClassifierCategory(this.label, this.score);
}

// Clase que representa el clasificador
class Classifier {
  final ClassifierLabels _classifierLabels;
  final ClassifierModel _classifierModel;

  // Constructor privado
  Classifier._({
    required ClassifierLabels labels,
    required ClassifierModel model,
  })  : _classifierLabels = labels,
        _classifierModel = model;

  static Future<Classifier?> loadClassifier({
    required String labelsFileName,
    required String modelFileName,
  }) async {
    try {
      final labels = await _loadLabels(labelsFileName);
      // Inicializa el modelo con el que se va a trabajar
      final model = await _loadModel(modelFileName);
      // Ya tenemos el clasificador preparado
      return Classifier._(labels: labels, model: model);
    } catch (e) {
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      return null;
    }
  }

  ClassifierCategory classify(Image image) {
    // Carga la imagen y la convierte a TensorImage para el TensorFlow Input
    final inputImage = _preProcessInput(image);

    // Define el búfer de salida
    final outputBuffer = TensorBuffer.createFixedSize(
      _classifierModel.outputShape,
      _classifierModel.outputType,
    );

    // Realiza la deducción
    _classifierModel.interpreter.run(inputImage.buffer, outputBuffer.buffer);

    // Obtiene el resultado
    final resultCategories = _postProcessOutput(outputBuffer);
    final topResult = resultCategories.first;

    return topResult;
  }

  static Future<ClassifierLabels> _loadLabels(String labelsFile) async {
    final rawLabels = await FileUtil.loadLabels(labelsFile);

    // Elimina el número de etiqueta del archivo de etiquetas
    final labels = rawLabels
        .map((label) => label.substring(label.indexOf(' ')).trim())
        .toList();

    return labels;
  }

  static Future<ClassifierModel> _loadModel(String modelFile) async {
    final interpreter = await Interpreter.fromAsset(modelFile);

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    final inputType = interpreter.getInputTensor(0).type;
    final outputType = interpreter.getOutputTensor(0).type;

    return ClassifierModel(
      interpreter: interpreter,
      inputShape: inputShape,
      outputShape: outputShape,
      inputType: inputType,
      outputType: outputType,
    );
  }

  // Preprocesa la imagen
  TensorImage _preProcessInput(Image image) {
    final inputTensor = TensorImage(_classifierModel.inputType);
    inputTensor.loadImage(image);

    final minSize = min(inputTensor.height, inputTensor.width);
    final crop = ResizeWithCropOrPadOp(minSize, minSize);

    final shapeSize = _classifierModel.inputShape[1];
    final resize = ResizeOp(shapeSize, shapeSize, ResizeMethod.BILINEAR);

    final normalize = NormalizeOp(127.5, 127.5);

    final imageProcessor =
        ImageProcessorBuilder().add(crop).add(resize).add(normalize).build();

    imageProcessor.process(inputTensor);

    return inputTensor;
  }

  List<ClassifierCategory> _postProcessOutput(TensorBuffer outputBuffer) {
    final probabilityProcessor = TensorProcessorBuilder().build();

    probabilityProcessor.process(outputBuffer);

    final labelledResult =
        TensorLabel.fromList(_classifierLabels, outputBuffer);

    final categoryList = <ClassifierCategory>[];
    labelledResult.getMapWithFloatValue().forEach((key, value) {
      final category = ClassifierCategory(key, value);
      categoryList.add(category);
    });

    categoryList.sort((first, second) => (second.score > first.score ? 1 : -1));

    return categoryList;
  }
}
