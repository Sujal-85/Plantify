import 'dart:math';

class TFLiteService {
  bool _isModelLoaded = false;
  final List<String> _labels = ['Healthy', 'Early Blight', 'Late Blight', 'Unknown'];

  Future<void> loadModel() async {
    print('Web Mode: Skipping native TFLite load. Using Simulation.');
    await Future.delayed(const Duration(milliseconds: 500));
    _isModelLoaded = true;
  }

  Future<Map<String, dynamic>> predict(String imagePath) async {
    // Web Simulation
    await Future.delayed(const Duration(seconds: 2));
    final random = Random();
    final disease = _labels[random.nextInt(_labels.length)];
    return {
      'label': disease,
      'confidence': 0.70 + (random.nextDouble() * 0.25),
      'heatmap': null,
    };
  }

  void close() {}
}
