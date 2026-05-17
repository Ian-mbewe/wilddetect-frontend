import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'image_detection_screen.dart';
import 'video_detection_screen.dart';
import 'live_camera_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void navigate(BuildContext context, Widget page) {
    Navigator.pop(context); // close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2D6A4F)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, color: Colors.white, size: 50),
                SizedBox(height: 10),
                Text(
                  'WildDetect Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Live Camera'),
            onTap: () => navigate(context, const LiveCameraScreen()),
          ),

          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Image Detection'),
            onTap: () => navigate(context, const ImageDetectionScreen()),
          ),

          ListTile(
            leading: const Icon(Icons.video_library),
            title: const Text('Video Detection'),
            onTap: () => navigate(context, const VideoDetectionScreen()),
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Browser History'),
            onTap: () => navigate(context, const HistoryScreen()),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}