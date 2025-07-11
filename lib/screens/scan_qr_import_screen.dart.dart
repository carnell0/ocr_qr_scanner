import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/contact.dart';

class ScanQrImportScreen extends StatefulWidget {
  const ScanQrImportScreen({super.key});

  @override
  State<ScanQrImportScreen> createState() => _ScanQrImportScreenState();
}

class _ScanQrImportScreenState extends State<ScanQrImportScreen> {
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      final data = jsonDecode(rawValue);

      final contact = Contact(
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        company: data['company'] ?? '',
      );

      if (context.mounted) {
        Navigator.pop(context, contact);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code invalide ou mal formaté')),
        );
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer contact via QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
