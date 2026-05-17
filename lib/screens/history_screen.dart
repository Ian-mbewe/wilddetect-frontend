import 'package:flutter/material.dart';
import 'app_drawer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text('History'),

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      body: const Center(
        child: Text('Coming Soon'),
      ),
    );
  }
}