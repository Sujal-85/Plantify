# Machine Learning Models

Place your TensorFlow Lite (`.tflite`) models and label files here.

## Structure
- `model.tflite`: The main quantized TFLite model.
- `labels.txt`: Line-separated list of class names.
- `gradcam/`: (Optional) Metadata or scripts for Grad-CAM generation.

## Requirements
- Input Shape: `[1, 224, 224, 3]` (Standard) or specific to your training.
- Normalization: Ensure the app's pre-processing matches training (e.g., mean/std subtract or 0-1 scaling).
