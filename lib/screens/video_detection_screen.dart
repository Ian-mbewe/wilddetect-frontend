import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

class VideoDetectionScreen extends StatefulWidget {
  const VideoDetectionScreen({super.key});

  @override
  State<VideoDetectionScreen> createState() => _VideoDetectionScreenState();
}

class _VideoDetectionScreenState extends State<VideoDetectionScreen> {
  static const String backendUrl = 'http://10.195.2.21:8000';

  Uint8List? _selectedVideoBytes;
  String? _selectedFileName;
  List<dynamic> _detections = [];
  bool _isLoading = false;
  String _status = 'Pick a video to detect animals';
  bool _done = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedVideoBytes = bytes;
        _selectedFileName = picked.name;
        _detections = [];
        _done = false;
        _status = 'Video selected: ${picked.name}. Tap Detect!';
      });
    }
  }

  Future<void> _detectAnimals() async {
    if (_selectedVideoBytes == null) return;

    setState(() {
      _isLoading = true;
      _status = 'Processing video... this may take a while';
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/predict-video-json'),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _selectedVideoBytes!,
          filename: _selectedFileName ?? 'video.mp4',
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        final allDetections = data['detections'] as List;

        // Get unique animals with highest confidence
        final Map<String, double> best = {};
        for (var d in allDetections) {
          final label = d['label'];
          final conf = d['confidence'] as double;
          if (!best.containsKey(label) || conf > best[label]!) {
            best[label] = conf;
          }
        }

        setState(() {
          _detections = best.entries
              .map((e) => {'label': e.key, 'confidence': e.value})
              .toList();
          _done = true;
          _status = _detections.isEmpty
              ? '⚠️ No animals detected'
              : '✅ Found ${_detections.length} animal(s) in video!';
        });
      } else {
        setState(() => _status = '❌ Error: ${response.statusCode}');
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Video Detection'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _selectedVideoBytes = null;
              _detections = [];
              _done = false;
              _status = 'Pick a video to detect animals';
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

            // Video placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _done ? Icons.check_circle : Icons.video_library,
                    size: 64,
                    color: _done ? const Color(0xFF2D6A4F) : Colors.white54,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFileName ?? 'No video selected',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detection results
            if (_detections.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Detected Animals',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
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
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Pick Video'),
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
                    label: Text(_isLoading ? 'Processing...' : 'Detect'),
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