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
  bool _scanned = false;

  void _handleScan(String rawData) {
    if (_scanned) return; // éviter les doubles scans
    _scanned = true;

    try {
      final Map<String, dynamic> data = jsonDecode(rawData);

      final contact = Contact(
        name: data['name'] ?? '',
        phone: data['phone'] ?? '',
        email: data['email'] ?? '',
        company: data['company'] ?? '',
      );

      Navigator.pop(context, contact);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Contact from QR')),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
        ),
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            _handleScan(barcode.rawValue!);
          }
        },
      ),
    );
  }
}
