import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awan/features/medication/screens/medication_detail_screen.dart';
import 'dart:io';
import 'package:awan/features/medication/models/medication_model.dart'
;

class MedicationScannerScreen extends StatefulWidget {
  const MedicationScannerScreen({super.key});

  @override
  State<MedicationScannerScreen> createState() => _MedicationScannerScreenState();
}

class _MedicationScannerScreenState extends State<MedicationScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _errorMessage = '';

  Future<void> _pickImageAndProcess() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final textRecognizer = TextRecognizer();
      final InputImage inputImage = InputImage.fromFile(File(image.path));
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      String medicationName = _findMedicationName(recognizedText.text);

      if (medicationName.isNotEmpty) {
        if (mounted) {
          final dummyMedication = Medication(
            id: 'temp',
            name: medicationName,
            dosage: '',
            time: '08:00',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MedicationDetailScreen(medication: dummyMedication),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Could not recognize a medication name. Please try again.';
          _isProcessing = false;
        });
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  String _findMedicationName(String text) {
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines[0].split(' ')[0];
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Medication'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              const Text(
                'Point your camera at a medication label to get details.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _pickImageAndProcess,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Open Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}