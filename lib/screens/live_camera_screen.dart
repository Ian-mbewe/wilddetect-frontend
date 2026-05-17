import 'package:flutter/material.dart';
import 'app_drawer.dart';

class LiveCameraScreen extends StatelessWidget {
  const LiveCameraScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Camera')),
      body: const Center(child: Text('Coming Soon')),
      drawer: const AppDrawer(),
    );
  }
}