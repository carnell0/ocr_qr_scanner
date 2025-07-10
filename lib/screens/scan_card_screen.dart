import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'dart:async';

class ScanCardScreen extends StatefulWidget {
  const ScanCardScreen({super.key});

  @override
  State<ScanCardScreen> createState() => _ScanCardScreenState();
}

class _ScanCardScreenState extends State<ScanCardScreen> {
  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  bool _isScanning = false;
  final textRecognizer = GoogleMlKit.vision.textRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _scanCard() async {
    if (_isScanning) return;

    setState(() => _isScanning = true);

    final picture = await _cameraController.takePicture();
    final inputImage = InputImage.fromFilePath(picture.path);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String allText = recognizedText.text;
    print("📄 Text reconnu :\n$allText");

    // À faire : parser ce texte pour remplir un Contact

    setState(() => _isScanning = false);

    // Pour l’instant, retourne juste au formulaire avec le texte brut
    Navigator.pop(context, allText);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Business Card')),
      body: Stack(
        children: [
          CameraPreview(_cameraController),
          if (_isScanning)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanCard,
        child: const Icon(Icons.camera),
      ),
    );
  }
}
