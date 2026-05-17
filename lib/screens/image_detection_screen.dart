import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';
import 'app_drawer.dart';

class ImageDetectionScreen extends StatefulWidget {
  const ImageDetectionScreen({super.key});

  @override
  State<ImageDetectionScreen> createState() => _ImageDetectionScreenState();
}

class _ImageDetectionScreenState extends State<ImageDetectionScreen> {
  static const String backendUrl = 'http://10.195.2.21:8000';

  Uint8List? _selectedImageBytes;
  String? _selectedFileName;
  Uint8List? _resultImageBytes;
  List<dynamic> _detections = [];
  bool _isLoading = false;
  String _status = 'Pick an image to detect animals';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = picked.name;
        _resultImageBytes = null;
        _detections = [];
        _status = 'Image selected. Tap Detect!';
      });
    }
  }

  Future<void> _detectAnimals() async {
    if (_selectedImageBytes == null) return;

    setState(() {
      _isLoading = true;
      _status = 'Detecting animals...';
    });

    try {
      // Call image endpoint for annotated image
      final imageRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/predict-image'),
      );
      imageRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedImageBytes!,
          filename: _selectedFileName ?? 'image.jpg',
        ),
      );
      final imageResponse = await imageRequest.send();
      if (imageResponse.statusCode == 200) {
        final bytes = await imageResponse.stream.toBytes();
        setState(() => _resultImageBytes = bytes);
      }

      // Call JSON endpoint for detection results
      final jsonRequest = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/predict-image-json'),
      );
      jsonRequest.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedImageBytes!,
          filename: _selectedFileName ?? 'image.jpg',
        ),
      );
      final jsonResponse = await jsonRequest.send();
      if (jsonResponse.statusCode == 200) {
        final body = await jsonResponse.stream.bytesToString();
        final data = jsonDecode(body);
        setState(() {
          _detections = data['detections'];
          _status = _detections.isEmpty
              ? '⚠️ No animals detected'
              : '✅ Found ${_detections.length} animal(s)!';
        });
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Image Detection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.menu, color: Colors.black),
    onPressed: () {
      Scaffold.of(context).openDrawer();
    },
  ),
),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _selectedImageBytes = null;
              _resultImageBytes = null;
              _detections = [];
              _status = 'Pick an image to detect animals';
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF2D6A4F)),
              ),
            ),
            const SizedBox(height: 16),

            // Image display
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _resultImageBytes != null
                    ? Image.memory(_resultImageBytes!, fit: BoxFit.contain)
                    : _selectedImageBytes != null
                        ? Image.memory(_selectedImageBytes!, fit: BoxFit.contain)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No image selected',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 16),

            // Detection results
            if (_detections.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              ..._detections.map((d) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pets, color: Color(0xFF2D6A4F)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            d['label'].toString().toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(d['confidence'] * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D6A4F),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF2D6A4F)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _detectAnimals,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isLoading ? 'Detecting...' : 'Detect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6A4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}